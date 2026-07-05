"""Custom PostgreSQL dialect for transpiling the MIMIC BigQuery concepts.

Only the handful of BigQuery functions that sqlglot does not already translate
to valid PostgreSQL are overridden here. As of sqlglot 30.x the following are
handled natively and need no custom code: ``DATETIME(date)`` -> ``CAST(.. AS
TIMESTAMP)``, ``DATETIME(y, m, d, ..)`` -> ``MAKE_TIMESTAMP(..)``, ``CAST(x AS
INT64)`` -> ``CAST(x AS BIGINT)``, and ``UNNEST(arr) AS x``.
"""
from sqlglot import exp
from sqlglot.dialects.postgres import Postgres

def _unit(expression: exp.Expression, default: str = "DAY") -> str:
    """Return the upper-cased time unit (e.g. ``'HOUR'``) of a date expression."""
    unit = expression.args.get("unit")
    return (unit.name if unit else default).upper()


# DATETIME_DIFF / DATE_DIFF
# -------------------------
# BigQuery's DATETIME_DIFF returns an INT64 equal to the number of `part`
# boundaries crossed between the two datetimes
# PostgreSQL has no equivalent function.
# The logic is as follows:
#   * DAY  -> difference of the two calendar dates (date subtraction = whole days)
#   * YEAR -> difference of the two calendar years
#   * sub-day units -> truncate both operands to the unit (which makes the
#     elapsed seconds an exact multiple of the unit) then divide.
# https://cloud.google.com/bigquery/docs/reference/standard-sql/datetime_functions#datetime_diff
_SECONDS_PER_UNIT = {"SECOND": 1, "MINUTE": 60, "HOUR": 3600}


def _datetime_diff_sql(self: Postgres.Generator, expression: exp.Expression) -> str:
    # operand order matches BigQuery: DATETIME_DIFF(end, start, part) = end - start
    end = self.sql(expression, "this")
    start = self.sql(expression, "expression")
    unit = _unit(expression)

    if unit == "DAY":
        return f"(CAST({end} AS DATE) - CAST({start} AS DATE))"
    if unit == "YEAR":
        return f"CAST(EXTRACT(YEAR FROM {end}) - EXTRACT(YEAR FROM {start}) AS BIGINT)"

    lo = unit.lower()
    factor = _SECONDS_PER_UNIT[unit]
    return (
        f"CAST(EXTRACT(EPOCH FROM DATE_TRUNC('{lo}', {end}) "
        f"- DATE_TRUNC('{lo}', {start})) / {factor} AS BIGINT)"
    )


# DATETIME_ADD / DATETIME_SUB
# ---------------------------
# Rendered as addition/subtraction of an INTERVAL. A literal quantity is quoted
# directly (``+ INTERVAL '6' HOUR``); a non-literal quantity is multiplied by a
# unit interval (``+ CAST(h AS BIGINT) * INTERVAL '1' HOUR``).
def _datetime_add_sql(self: Postgres.Generator, expression: exp.Expression, op: str) -> str:
    this = self.sql(expression, "this")
    unit = _unit(expression)
    quantity = expression.expression
    if isinstance(quantity, exp.Literal):
        return f"{this} {op} INTERVAL '{quantity.name}' {unit}"
    return f"{this} {op} {self.sql(quantity)} * INTERVAL '1' {unit}"


# DATETIME_TRUNC(x, HOUR) -> DATE_TRUNC('hour', x)  (function name + quoted unit)
def _datetime_trunc_sql(self: Postgres.Generator, expression: exp.Expression) -> str:
    return f"DATE_TRUNC('{_unit(expression).lower()}', {self.sql(expression, 'this')})"


# GENERATE_ARRAY(a, b) -> ARRAY(SELECT * FROM GENERATE_SERIES(a, b))
# BigQuery's GENERATE_ARRAY returns an ARRAY; PostgreSQL's GENERATE_SERIES
# returns a set of rows, so we wrap it in an ARRAY constructor to preserve the
# array semantics (e.g. for a later CROSS JOIN UNNEST).
# https://cloud.google.com/bigquery/docs/reference/standard-sql/array_functions#generate_array
def _generate_array_sql(self: Postgres.Generator, expression: exp.Expression) -> str:
    start = self.sql(expression, "start")
    end = self.sql(expression, "end")
    return f"ARRAY(SELECT * FROM GENERATE_SERIES({start}, {end}))"


class MimicPostgres(Postgres):
    class Generator(Postgres.Generator):
        def datatype_sql(self, expression: exp.DataType) -> str:
            if expression.this == exp.DataType.Type.TIMESTAMPTZ:
                return "TIMESTAMP"
            return super().datatype_sql(expression)

        TRANSFORMS = {
            **Postgres.Generator.TRANSFORMS,
            exp.DatetimeDiff: _datetime_diff_sql,
            exp.DateDiff: _datetime_diff_sql,
            exp.DatetimeAdd: lambda self, e: _datetime_add_sql(self, e, "+"),
            exp.DatetimeSub: lambda self, e: _datetime_add_sql(self, e, "-"),
            exp.DatetimeTrunc: _datetime_trunc_sql,
            exp.GenerateSeries: _generate_array_sql,
        }
