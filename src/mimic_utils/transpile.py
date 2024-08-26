import os
from pathlib import Path
from typing import Union

import sqlglot
import sqlglot.dialects.bigquery
import sqlglot.dialects.duckdb
import sqlglot.dialects.postgres
from sqlglot import exp
from sqlglot.expressions import to_identifier

# Apply transformation monkey patches
# these modules are imported for their side effects
from mimic_utils.sqlglot_dialects import postgres
from mimic_utils.sqlglot_dialects import bigquery
from mimic_utils.sqlglot_dialects import duckdb

# sqlglot has a default convention that function names are upper-case
_FUNCTION_MAPPING = {
    'bigquery': {},
    'postgres': {
        'DATETIME': postgres.DateTime,
        'GENERATE_ARRAY': postgres.GenerateArray,
    },
    'duckdb': {
        'DATETIME': duckdb.DateTime,
    },
}

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
            # we remove quoting of the table identifiers, for consistency
            # with previously generated code
            table.args['this'] = to_identifier(
                name=table.args['this'].this,
                quoted=False,
            )
            table.args['db'] = to_identifier(
                name=table.args['db'].this,
                quoted=False,
            )
        elif table.this.name.startswith(catalog_to_remove):
            table.args['this'].args['this'] = table.this.name.replace(catalog_to_remove + '.', '')
            # sqlglot wants to output the schema/table as a single quoted identifier
            # so here we remove the quoting
            table.args['this'] = sqlglot.expressions.to_identifier(
                name=table.args['this'].args['this'],
                quoted=False
            )

    # HACK: sqlglot has a GenerateSeries transpilation in v25.13.0,
    # which is inserted during the parse of BigQuery. However, it looks
    # incorrect for postgres (at least), as it swaps GENERATE_ARRAY for GENERATE_SERIES.
    # BigQuery's GENERATE_ARRAY outputs an array, but GENERATE_SERIES outputs exploded rows.
    # We will manually replace the GENERATE_SERIES call with an anonymous function, so our
    # custom transpile code can do the correct conversion for postgres.
    if (source_dialect == 'bigquery') and (destination_dialect == 'postgres'):
        for gs_function in sql_parsed.find_all(exp.GenerateSeries):
            # rename to our anonymous generate array function, so the
            # later loop will catch it
            gs_function.replace(
                exp.Anonymous(
                    this='GENERATE_ARRAY',
                    expressions=[
                        gs_function.args['start'],
                        gs_function.args['end']
                    ]
                )
            )

    # BigQuery has a few functions which are not in sqlglot, so we have
    # created classes for them, and this loop replaces the anonymous functions
    # with the named functions
    function_mapper = _FUNCTION_MAPPING[destination_dialect]
    for anon_function in sql_parsed.find_all(exp.Anonymous):
        if anon_function.this in function_mapper:
            named_function = function_mapper[anon_function.this](**anon_function.args)
            anon_function.replace(named_function)

    # duckdb does not support the default /* ... */ comment style
    keep_comments = True
    if destination_dialect == 'duckdb':
        keep_comments = False

    # convert back to sql
    transpiled_query = sql_parsed.sql(dialect=destination_dialect, pretty=True, comments=keep_comments)

    return transpiled_query

def transpile_file(source_file: Union[str, os.PathLike], destination_file: Union[str, os.PathLike], source_dialect: str="bigquery", destination_dialect: str="postgres", derived_schema: str="mimiciv_derived"):
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
