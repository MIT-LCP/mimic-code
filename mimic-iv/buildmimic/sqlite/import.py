import os
import sys

from glob import glob
import pandas as pd

DATABASE_NAME = "mimic4.db"
THRESHOLD_SIZE = 5 * 10**7
CHUNKSIZE = 10**6
CONNECTION_STRING = "sqlite:///{}".format(DATABASE_NAME)

if os.path.exists(DATABASE_NAME):
    msg = "File {} already exists.".format(DATABASE_NAME)
    print(msg)
    sys.exit()

for f in glob("**/*.csv*", recursive=True):
    print("Starting processing {}".format(f))
    folder, filename = os.path.split(f)
    tablename = filename.strip(".gz").strip(".csv").lower()
    if os.path.getsize(f) < THRESHOLD_SIZE:
        df = pd.read_csv(f)
        df.to_sql(tablename, CONNECTION_STRING)
    else:
        # If the file is too large, let's do the work in chunks
        for chunk in pd.read_csv(f, chunksize=CHUNKSIZE, low_memory=False):
            chunk.to_sql(tablename, CONNECTION_STRING, if_exists="append")
    print("Finished processing {}".format(f))

print("Should be all done!")
