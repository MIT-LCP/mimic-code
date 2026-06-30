import os
from pathlib import Path
from typing import Union

import sqlglot
from sqlglot import exp
from sqlglot.expressions import to_identifier

# Subclass sqlglot dialects to allow patching of specific functions
from mimic_utils.sqlglot_dialects.postgres import MimicPostgres
from mimic_utils.sqlglot_dialects.duckdb import MimicDuckDB

_DESTINATION_DIALECTS = {
    "postgres": MimicPostgres,
    "duckdb": MimicDuckDB,
}

# BigQuery catalog ("project") that qualifies the source tables, e.g.
# `physionet-data.mimiciv_icu.chartevents`. It has no analogue in the target
# databases and is stripped, leaving `schema.table`.
_CATALOG_TO_REMOVE = "physionet-data"


def _strip_catalog(parsed: exp.Expression) -> None:
    """Remove the ``physionet-data`` catalog from every table reference in place."""
    for table in parsed.find_all(exp.Table):
        if table.catalog != _CATALOG_TO_REMOVE:
            continue
        table.set("catalog", None)
        # drop quoting of the remaining schema/table identifiers, for
        # consistency with the previously generated code
        table.set("this", to_identifier(table.name, quoted=False))
        if table.args.get("db"):
            table.set("db", to_identifier(table.args["db"].name, quoted=False))


def transpile_query(query: str, source_dialect: str = "bigquery", destination_dialect: str = "postgres") -> str:
    """Transpile a SQL string from ``source_dialect`` to ``destination_dialect``."""
    if destination_dialect not in _DESTINATION_DIALECTS:
        raise ValueError(f"Unsupported destination dialect: {destination_dialect}")

    parsed = sqlglot.parse_one(query, read=source_dialect)
    _strip_catalog(parsed)

    # DuckDB does not accept the default /* ... */ block comment style, so we
    # drop comments when targeting it.
    keep_comments = destination_dialect != "duckdb"

    return parsed.sql(
        dialect=_DESTINATION_DIALECTS[destination_dialect],
        pretty=True,
        comments=keep_comments,
    )


def transpile_file(
        source_file: Union[str, os.PathLike],
        destination_file: Union[str, os.PathLike],
        source_dialect: str = "bigquery",
        destination_dialect: str = "postgres",
        derived_schema: str = "mimiciv_derived"
    ):
    """
    Reads an SQL file in from file, transpiles it, and outputs it to file.
    """
    with open(source_file, "r") as read_file:
        sql_query = read_file.read()

    if derived_schema is not None:
        derived_schema = derived_schema.rstrip('.') + "."
    else:
        derived_schema = ""

    transpiled_query = transpile_query(sql_query, source_dialect, destination_dialect)
    # add "create" statement based on the file stem
    transpiled_query = (
        "-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.\n"
        f"DROP TABLE IF EXISTS {derived_schema}{Path(source_file).stem}; "
        f"CREATE TABLE {derived_schema}{Path(source_file).stem} AS\n"
    ) + transpiled_query

    with open(destination_file, "w") as write_file:
        write_file.write(transpiled_query)


def transpile_folder(source_folder: Union[str, os.PathLike], destination_folder: Union[str, os.PathLike], source_dialect: str = "bigquery", destination_dialect: str = "postgres"):
    """
    Transpiles each file in the folder from BigQuery to the specified dialect.
    """
    source_folder = Path(source_folder).resolve()
    for filename in source_folder.rglob("*.sql"):
        source_file = filename
        destination_file = Path(destination_folder).resolve() / filename.relative_to(source_folder)
        destination_file.parent.mkdir(parents=True, exist_ok=True)

        transpile_file(source_file, destination_file, source_dialect, destination_dialect)
