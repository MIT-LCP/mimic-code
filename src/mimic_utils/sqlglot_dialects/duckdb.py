import sqlglot
import sqlglot.dialects.duckdb
from sqlglot.dialects.duckdb import DuckDB
from sqlglot import Expression, exp, select
from sqlglot.helper import seq_get

# Monkey patches for duckdb
# (1) date_sub / date_add
# (2) date_diff
# (3) datetime() function
# (4) date_trunc

# DATETIME_ADD / DATETIME_SUB -> quote the integer
def datetime_arithmetic_sql(self: Expression, expression: Expression, operator: str):
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
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeSub] = lambda self, expression: datetime_arithmetic_sql(self, expression, "-")
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeAdd] = lambda self, expression: datetime_arithmetic_sql(self, expression, "+")

_unit_ms_conversion_factor_map = {
    'SECOND': 1e6,
    'MINUTE': 60.0*1e6,
    'HOUR': 3600.0*1e6,
    'DAY': 24*3600.0*1e6,
    'YEAR': 365.242*24*3600.0*1e6,
}
def duckdb_date_diff_frac_sql(self, expression):
    this = self.sql(expression, "this")
    mfactor = _unit_ms_conversion_factor_map[self.sql(expression, "unit").upper() or "DAY"]
    # DuckDB DATE_DIFF operand order is start_time, end_time--not like end_time - start_time!
    return f"DATE_DIFF('microseconds', {self.sql(expression.expression)}, {this})/{mfactor:.1f}"
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeDiff] = duckdb_date_diff_frac_sql
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateDiff] = duckdb_date_diff_frac_sql

# DATETIME: duckdb has a similar function, but it's named make_timestamp
class DateTime(exp.Func):
    arg_types = {"this": True, "expressions": False}
    _sql_names = ["MAKE_TIMESTAMP", "DATETIME"]

def datetime_sql(self: DuckDB.Generator, expression: DateTime):
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

    return f'MAKE_TIMESTAMP({", ".join([self.sql(arg) for arg in expression.expressions])})'
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[DateTime] = datetime_sql


# DATE_TRUNC -> quote the unit part
def date_trunc_sql(self: DuckDB.Generator, expression: Expression):
    this = self.sql(expression, "this")
    unit = self.sql(expression, "unit") or "DAY"
    return f"DATE_TRUNC('{unit}', {this})"
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DateTrunc] = date_trunc_sql
sqlglot.dialects.duckdb.DuckDB.Generator.TRANSFORMS[exp.DatetimeTrunc] = date_trunc_sql
