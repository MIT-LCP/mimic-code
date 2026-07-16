import os
import sys

from glob import glob
import pandas as pd


DATABASE_NAME = "mimic3.db"
THRESHOLD_SIZE = 5 * 10 ** 7
CHUNKSIZE = 10 ** 6
CONNECTION_STRING = "sqlite:///{}".format(DATABASE_NAME)


def _table_name_from_csv(filename: str) -> str:
    """Derive SQL table name from a CSV path (literal suffix, not str.strip)."""
    name = filename
    for suffix in (".csv.gz", ".csv"):
        if name.lower().endswith(suffix):
            name = name[: -len(suffix)]
            break
    return name.lower()


if os.path.exists(DATABASE_NAME):
    msg = "File {} already exists.".format(DATABASE_NAME)
    print(msg)
    sys.exit()

for f in glob("*.csv.gz"):
    print("Starting processing {}".format(f))
    table = _table_name_from_csv(f)
    if os.path.getsize(f) < THRESHOLD_SIZE:
        df = pd.read_csv(f, index_col="ROW_ID")
        df.to_sql(table, CONNECTION_STRING)
    else:
        # If the file is too large, let's do the work in chunks
        for chunk in pd.read_csv(f, index_col="ROW_ID", chunksize=CHUNKSIZE):
            chunk.to_sql(table, CONNECTION_STRING, if_exists="append")
    print("Finished processing {}".format(f))

print("Should be all done!")
