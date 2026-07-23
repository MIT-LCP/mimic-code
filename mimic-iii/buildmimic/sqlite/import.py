import os
import sys

from glob import glob
import pandas as pd


DATABASE_NAME = "mimic3.db"
THRESHOLD_SIZE = 5 * 10 ** 7
CHUNKSIZE = 10 ** 6
CONNECTION_STRING = "sqlite:///{}".format(DATABASE_NAME)

# Column dtypes for tables that trigger pandas mixed-type warnings when
# loaded with the default low_memory chunked inference (see #1237).
# Types mirror mimic-iii/buildmimic/postgres/postgres_create_tables.sql.
TABLE_DTYPES = {
    "chartevents": {
        "WARNING": "Int64",
        "ERROR": "Int64",
        "RESULTSTATUS": "string",
        "STOPPED": "string",
    },
    "datetimeevents": {
        "WARNING": "Int64",
        "ERROR": "Int64",
        "RESULTSTATUS": "string",
        "STOPPED": "string",
    },
    "inputevents_cv": {
        "ORIGINALRATE": "float64",
        "ORIGINALRATEUOM": "string",
        "ORIGINALSITE": "string",
    },
    "noteevents": {
        "CHARTTIME": "string",
        "STORETIME": "string",
        "ISERROR": "string",
    },
}


def _table_name_from_csv(filename: str) -> str:
    """Derive SQL table name from a CSV path (literal suffix, not str.strip)."""
    name = filename
    for suffix in (".csv.gz", ".csv"):
        if name.lower().endswith(suffix):
            name = name[: -len(suffix)]
            break
    return name.lower()


def _read_csv(path, table, **kwargs):
    # low_memory=False avoids dtype re-inference across chunks; table-specific
    # dtypes pin the columns that otherwise flip between numeric/object.
    return pd.read_csv(
        path,
        index_col="ROW_ID",
        low_memory=False,
        dtype=TABLE_DTYPES.get(table),
        **kwargs,
    )


if os.path.exists(DATABASE_NAME):
    msg = "File {} already exists.".format(DATABASE_NAME)
    print(msg)
    sys.exit()

for f in glob("*.csv.gz"):
    print("Starting processing {}".format(f))
    table = _table_name_from_csv(f)
    if os.path.getsize(f) < THRESHOLD_SIZE:
        df = _read_csv(f, table)
        df.to_sql(table, CONNECTION_STRING)
    else:
        # If the file is too large, let's do the work in chunks
        for chunk in _read_csv(f, table, chunksize=CHUNKSIZE):
            chunk.to_sql(table, CONNECTION_STRING, if_exists="append")
    print("Finished processing {}".format(f))

print("Should be all done!")
