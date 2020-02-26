import pandas as pd
from glob import glob
import os


DATABASE_NAME = "mimic3.db"
THRESHOLD_SIZE = 5 * 10 ** 7
CHUNKSIZE = 10 ** 6
CONNECTION_STRING = "sqlite:///{}".format(DATABASE_NAME)

if os.path.exists(DATABASE_NAME):
    print("File {} already exists. Deleting it.".format(DATABASE_NAME))
    os.remove(DATABASE_NAME)
    print("File removed. Going on...")

for f in glob("*.csv.gz"):
    print("Starting processing {}".format(f))
    if os.path.getsize(f) < THRESHOLD_SIZE:
        df = pd.read_csv(f, index_col="ROW_ID")
        df.to_sql(f.strip(".csv.gz").lower(), CONNECTION_STRING)
    else:
        # If the file is too large, let's do the work in chunks
        for chunk in pd.read_csv(f, index_col="ROW_ID", chunksize=CHUNKSIZE):
            chunk.to_sql(
                f.strip(".csv.gz").lower(), CONNECTION_STRING, if_exists="append"
            )
    print("Finished processing {}".format(f))

print("Should be all done!")
