import os
import sys

from glob import glob


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


def _data_files_by_table(csv_paths=None, csv_gz_paths=None):
    """Map table name → path, preferring .csv.gz when both exist.

    ``import.sh`` already accepts plain ``.csv`` and ``.csv.gz``; this loader
    previously only globbed ``*.csv.gz`` and would silently skip uncompressed
    extracts.
    """
    files_by_table = {}
    for path in csv_paths if csv_paths is not None else glob("*.csv"):
        files_by_table[_table_name_from_csv(path)] = path
    for path in csv_gz_paths if csv_gz_paths is not None else glob("*.csv.gz"):
        files_by_table[_table_name_from_csv(path)] = path
    return files_by_table


if __name__ == "__main__":
    import pandas as pd

    if os.path.exists(DATABASE_NAME):
        msg = "File {} already exists.".format(DATABASE_NAME)
        print(msg)
        sys.exit()

    files_by_table = _data_files_by_table()
    for table, f in sorted(files_by_table.items()):
        print("Starting processing {}".format(f))
        if os.path.getsize(f) < THRESHOLD_SIZE:
            df = pd.read_csv(f, index_col="ROW_ID")
            df.to_sql(table, CONNECTION_STRING)
        else:
            # If the file is too large, let's do the work in chunks
            for chunk in pd.read_csv(f, index_col="ROW_ID", chunksize=CHUNKSIZE):
                chunk.to_sql(table, CONNECTION_STRING, if_exists="append")
        print("Finished processing {}".format(f))

    print("Should be all done!")
