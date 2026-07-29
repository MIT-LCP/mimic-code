"""Custom DuckDB dialect for transpiling the MIMIC BigQuery concepts.

- ``NUMERIC`` is ``DECIMAL(38, 9)``, but DuckDB's bare ``DECIMAL`` defaults
to ``DECIMAL(18, 3)``, which silently rounds values to three decimal places
(e.g. ``CAST(0.0255 AS NUMERIC)`` becomes ``0.026`` before any explicit ``ROUND``).
"""
import re

from sqlglot import exp
from sqlglot.dialects.duckdb import DuckDB


# REGEXP_EXTRACT(str, pattern) semantics differ from DuckDB in two ways:
# 1. BigQuery returns the first capturing group when the pattern has one (it
#    allows at most one), otherwise the whole match. DuckDB always returns the
#    whole match unless an explicit group index is given, so patterns with a
#    capturing group must be generated as REGEXP_EXTRACT(str, pattern, 1).
# 2. BigQuery returns NULL when the pattern does not match; DuckDB returns an
#    empty string, so the result is wrapped in NULLIF(..., ''). (A matched but
#    empty capturing group also becomes NULL; the concepts never rely on that.)
# https://cloud.google.com/bigquery/docs/reference/standard-sql/string_functions#regexp_extract
def _regexp_extract_sql(self: DuckDB.Generator, expression: exp.RegexpExtract) -> str:
    this = self.sql(expression, "this")
    pattern = expression.expression
    pattern_sql = self.sql(expression, "expression")
    group = expression.args.get("group")
    if group is None and isinstance(pattern, exp.Literal) and pattern.is_string:
        try:
            if re.compile(pattern.name).groups > 0:
                group = exp.Literal.number(1)
        except re.error:
            pass
    group_sql = f", {self.sql(group)}" if group is not None else ""
    return f"NULLIF(REGEXP_EXTRACT({this}, {pattern_sql}{group_sql}), '')"


# PARSE_DATETIME(fmt, str) -> STRPTIME(str, fmt); both use %-style patterns.
def _parse_datetime_sql(self: DuckDB.Generator, expression: exp.ParseDatetime) -> str:
    this = self.sql(expression, "this")
    fmt = self.format_time(expression)
    return f"STRPTIME({this}, {fmt})"


class MimicDuckDB(DuckDB):
    class Generator(DuckDB.Generator):
        def datatype_sql(self, expression: exp.DataType) -> str:
            if expression.this == exp.DataType.Type.TIMESTAMPTZ:
                return "TIMESTAMP"
            if expression.this == exp.DataType.Type.DECIMAL and not expression.expressions:
                return "DECIMAL(38, 9)"
            return super().datatype_sql(expression)

        TRANSFORMS = {
            **DuckDB.Generator.TRANSFORMS,
            exp.RegexpExtract: _regexp_extract_sql,
            exp.ParseDatetime: _parse_datetime_sql,
        }
