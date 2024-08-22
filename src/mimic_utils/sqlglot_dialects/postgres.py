import sqlglot
import sqlglot.dialects.postgres
from sqlglot import Expression, exp
from sqlglot.expressions import array, select

# DATETIME: allow passing either a DATE directly, or multiple arguments
# there isn't a class for the Datetime function, so we have to create it ourself,
# and recast anonymous functions with the name "datetime" to this class
# https://cloud.google.com/bigquery/docs/reference/standard-sql/datetime_functions#datetime
class DateTime(exp.Func):
    arg_types = {"this": False, "zone": False, "expressions": False}
    is_var_len_args = True


# GENERATE_ARRAY(exp1, exp2) -> convert to ARRAY(SELECT * FROM generate_series(exp1, exp2))
# https://cloud.google.com/bigquery/docs/reference/standard-sql/array_functions#generate_array
# https://www.postgresql.org/docs/current/functions-srf.html
class GenerateArray(exp.Func):
    arg_types = {"this": False, "expressions": False}

class GenerateSeries(exp.Func):
    arg_types = {"this": False, "expressions": False}


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
def generate_array_sql(self: Expression, expression: Expression):
    # BigQuery's generate array returns an array data type,
    # but PostgreSQL generate series returns a set of rows,
    # so we wrap the output of generate series in an array
    # constructor.
    select_statement = array(select("*").from_(
        GenerateSeries(
            expressions=[
                expression.expressions[0],
                expression.expressions[1],
            ],
        )
    ))

    return self.generate(select_statement)
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
