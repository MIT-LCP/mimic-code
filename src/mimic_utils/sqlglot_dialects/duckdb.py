"""Custom DuckDB dialect for transpiling the MIMIC BigQuery concepts.

- ``NUMERIC`` is ``DECIMAL(38, 9)``, but DuckDB's bare ``DECIMAL`` defaults
to ``DECIMAL(18, 3)``, which silently rounds values to three decimal places
(e.g. ``CAST(0.0255 AS NUMERIC)`` becomes ``0.026`` before any explicit ``ROUND``).
"""
from sqlglot import exp
from sqlglot.dialects.duckdb import DuckDB


class MimicDuckDB(DuckDB):
    class Generator(DuckDB.Generator):
        def datatype_sql(self, expression: exp.DataType) -> str:
            if expression.this == exp.DataType.Type.DECIMAL and not expression.expressions:
                return "DECIMAL(38, 9)"
            return super().datatype_sql(expression)
