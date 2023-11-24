import os
from pathlib import Path
from typing import Union

import sqlglot
import sqlglot.dialects.bigquery
import sqlglot.dialects.duckdb
import sqlglot.dialects.postgres
from sqlglot import Expression, exp, select
from sqlglot.helper import seq_get

#=== BigQuery monkey patches
sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["PARSE_DATETIME"] = lambda args: exp.StrToTime(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.FUNCTIONS["FORMAT_DATE"] = lambda args: exp.TimeToStr(
    this=seq_get(args, 1), format=seq_get(args, 0)
)
sqlglot.dialects.bigquery.BigQuery.Parser.STRICT_CAST = False

#=== PSQL monkey patches
# DATETIME_ADD / DATETIME_SUB -> quote the integer
def date_arithmetic_sql(self: Expression, expression: Expression, operator: str):
    """Render DATE_ADD and DATE_SUB functions as a addition or subtraction of an interval."""
    this = self.sql(expression, "this")
    unit = self.sql(expression, "unit") or "DAY"
    # for psql, we need to quote the number
    interval_exp = expression.expression
    if isinstance(interval_exp, exp.Literal):
        interval_exp = exp.Literal(this=expression.expression.this, is_string=True)
        return f"{this} {operator} {self.sql(exp.Interval(this=interval_exp, unit=unit))}"
    
    # if the interval number is an expression, we multiply it by an interval instead
    # e.g. if it is CAST(column AS INT), it becomes CAST(column AS INT) * INTERVAL '1' HOUR
    one_interval = exp.Interval(
        this=exp.Literal(this="1", is_string=True),
        unit=unit
    )
    return f"{this} {operator} {self.sql(exp.Mul(this=interval_exp, expression=one_interval))}"
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[exp.DatetimeSub] = lambda self, expression: date_arithmetic_sql(self, expression, "-")
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[exp.DatetimeAdd] = lambda self, expression: date_arithmetic_sql(self, expression, "+")

# DATETIME_DIFF / DATE_DIFF -> use EXTRACT(EPOCH ...) with a custom conversion factor
_unit_second_conversion_factor_map = {
    'SECOND': 1,
    'MINUTE': 60.0,
    'HOUR': 3600.0,
    'DAY': 24*3600.0,
    'YEAR': 365.242*24*3600.0,
}
def date_diff_sql(self: Expression, expression: Expression):
    this = self.sql(expression, "this")
    mfactor = _unit_second_conversion_factor_map[self.sql(expression, "unit").upper() or "DAY"]
    return f"EXTRACT(EPOCH FROM {this} - {self.sql(expression.expression)}) / {mfactor:.1f}"

sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[exp.DatetimeDiff] = date_diff_sql
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[exp.DateDiff] = date_diff_sql

# DATE_TRUNC -> quote the unit part
def date_trunc_sql(self: Expression, expression: Expression):
    this = self.sql(expression, "this")
    unit = self.sql(expression, "unit") or "DAY"
    return f"DATE_TRUNC('{unit}', {this})"
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[exp.DateTrunc] = date_trunc_sql
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[exp.DatetimeTrunc] = date_trunc_sql

# DATETIME: allow passing either a DATE directly, or multiple arguments
# there isn't a class for the Datetime function, so we have to create it ourself,
# and recast anonymous functions with the name "datetime" to this class
class DateTime(exp.Func):
    arg_types = {"this": False, "zone": False, "expressions": False}
    is_var_len_args = True

def datetime_sql(self: Expression, expression: Expression):
    # https://cloud.google.com/bigquery/docs/reference/standard-sql/datetime_functions#datetime
    # BigQuery supports three overloaded arguments to DATETIME, but we will only accept
    #   (1) the version which accepts integer valued arguments
    #   (2) the version which accepts a DATE directly (no optional 2nd argument allowed)
    if not isinstance(expression.expressions, list):
        raise NotImplementedError("Transpile only supports DATETIME(date) OR DATETIME(year, month, day, hour, minute, second)")
    if len(expression.expressions) == 1:
        # handle the case where we are passing a DATE directly
        return f"CAST({self.sql(expression.expressions[0])} AS TIMESTAMP)"
        
    if len(expression.expressions) != 6:
        raise NotImplementedError("Transpile only supports DATETIME(date) OR DATETIME(year, month, day, hour, minute, second)")

    # we will now map the args for passing to the TO_TIMESTAMP(string, format) PSQL function
    args = [self.sql(arg) for arg in expression.expressions]
    # pad the arguments with zeros
    args = [f"TO_CHAR({arg}, '{'0000' if i == 0 else '00'}')" for i, arg in enumerate(args)]
    # concatenate the arguments
    args = " || ".join(args)
    # convert the concatenated string to a timestamp
    return f"TO_TIMESTAMP({args}, 'yyyymmddHH24MISS')"
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[DateTime] = datetime_sql

# GENERATE_ARRAY(exp1, exp2) -> convert to ARRAY(SELECT * FROM generate_series(exp1, exp2))
# https://cloud.google.com/bigquery/docs/reference/standard-sql/array_functions#generate_array
# https://www.postgresql.org/docs/current/functions-srf.html
class GenerateArray(exp.Func):
    arg_types = {"this": False, "expressions": False}

class GenerateSeries(exp.Func):
    arg_types = {"this": False, "expressions": False}

def generate_array_sql(self: Expression, expression: Expression):
    # first create a select statement which selects from generate_series
    select_statement = select("*").from_(
        GenerateSeries(
            expressions=[
                expression.expressions[0],
                expression.expressions[1],
            ],
        )
    )

    # now convert the select statement to an array
    return f"ARRAY({self.sql(select_statement)})"
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[GenerateArray] = generate_array_sql

# we need to prevent the wrapping of the table alias in brackets for UNNEST
# e.g. UNNEST(array) AS (alias) -> UNNEST(array) AS alias
def unnest_sql(self: Expression, expression: Expression):
    alias = self.sql(expression, "alias")
    # remove the brackets
    if alias.startswith("(") and alias.endswith(")"):
        alias = alias[1:-1]
    sql_text = expression.sql()
    # substitute the alias
    sql_text = sql_text.replace(f' AS {self.sql(expression, "alias")}', f' AS {alias}')
    return sql_text
sqlglot.dialects.postgres.Postgres.Generator.TRANSFORMS[exp.Unnest] = unnest_sql

def transpile_query(query: str, source_dialect: str="bigquery", destination_dialect: str="postgres"):
    """
    Transpiles the SQL file from BigQuery to the specified dialect.
    """
    sql_parsed = sqlglot.parse_one(query, read=source_dialect)

    # Remove "physionet-data" as the catalog name
    catalog_to_remove = 'physionet-data'
    for table in sql_parsed.find_all(exp.Table):
        if table.catalog == catalog_to_remove:
            table.args['catalog'] = None
        elif table.this.name.startswith(catalog_to_remove):
            table.args['this'].args['this'] = table.this.name.replace(catalog_to_remove + '.', '')
            # sqlglot wants to output the schema/table as a single quoted identifier
            # so here we remove the quoting
            table.args['this'] = sqlglot.expressions.to_identifier(
                name=table.args['this'].args['this'],
                quoted=False
            )

    if source_dialect == 'bigquery':
        # BigQuery has a few functions which are not in sqlglot, so we have
        # created classes for them, and this loop replaces the anonymous functions
        # with the named functions
        for anon_function in sql_parsed.find_all(exp.Anonymous):
            if anon_function.this == 'DATETIME':
                named_function = DateTime(
                    **anon_function.args,
                )
                anon_function.replace(named_function)
            elif anon_function.this == 'GENERATE_ARRAY':
                named_function = GenerateArray(
                    **anon_function.args,
                )
                anon_function.replace(named_function)

    # convert back to sql
    transpiled_query = sql_parsed.sql(dialect=destination_dialect, pretty=True)
    
    return transpiled_query

def transpile_file(source_file: Union[str, os.PathLike], destination_file: Union[str, os.PathLike], source_dialect: str="bigquery", destination_dialect: str="postgres"):
    """
    Reads an SQL file in from file, transpiles it, and outputs it to file.
    """
    with open(source_file, "r") as read_file:
        sql_query = read_file.read()
    
    transpiled_query = transpile_query(sql_query, source_dialect, destination_dialect)
    # add "create" statement based on the file stem
    transpiled_query = (
        "-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.\n"
        f"DROP TABLE IF EXISTS {Path(source_file).stem}; "
        f"CREATE TABLE {Path(source_file).stem} AS\n"
    ) + transpiled_query

    with open(destination_file, "w") as write_file:
        write_file.write(transpiled_query)

def transpile_folder(source_folder: Union[str, os.PathLike], destination_folder: Union[str, os.PathLike], source_dialect: str="bigquery", destination_dialect: str="postgres"):
    """
    Transpiles each file in the folder from BigQuery to the specified dialect.
    """
    source_folder = Path(source_folder).resolve()
    for filename in source_folder.rglob("*.sql"):
        source_file = filename
        destination_file = Path(destination_folder).resolve() / filename.relative_to(source_folder)
        destination_file.parent.mkdir(parents=True, exist_ok=True)

        transpile_file(source_file, destination_file, source_dialect, destination_dialect)
