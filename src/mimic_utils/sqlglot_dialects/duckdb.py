"""Custom DuckDB dialect for transpiling the MIMIC BigQuery concepts.

- ``NUMERIC`` is ``DECIMAL(38, 9)``, but DuckDB's bare ``DECIMAL`` defaults
to ``DECIMAL(18, 3)``, which silently rounds values to three decimal places
(e.g. ``CAST(0.0255 AS NUMERIC)`` becomes ``0.026`` before any explicit ``ROUND``).
- ``GENERATE_ARRAY`` must remain a LIST (for later ``UNNEST``). Native sqlglot
emits ``GENERATE_SERIES``, which is a set-returning function and breaks
``UNNEST(hrs)`` with ``unnest(integer)`` / type errors (#1736).
"""
from sqlglot import exp
from sqlglot.dialects.duckdb import DuckDB


def _generate_array_sql(self: DuckDB.Generator, expression: exp.Expression) -> str:
    start = self.sql(expression, "start")
    end = self.sql(expression, "end")
    # Inclusive list, matching BigQuery GENERATE_ARRAY / Postgres ARRAY(GENERATE_SERIES).
    return f"(SELECT list(g) FROM generate_series({start}, {end}) AS t(g))"


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
            exp.GenerateSeries: _generate_array_sql,
        }
