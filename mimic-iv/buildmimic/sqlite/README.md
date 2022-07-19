# Building the MIMIC database with SQLite

Either `import.sh` or `import.py` can be used to generate a [SQLite](https://sqlite.org/index.html) database file from the MIMIC-IV demo or full dataset.

`import.sh` is a shell script that will work with any POSIX compliant shell.
It is memory efficient and does not require loading entire data files
into memory. It only needs three things to run:

1. A POSIX compliant shell (e.g., dash, bash, zsh, ksh, etc.)
2. [SQLite]([https://sqlite.org/index.html)
3. gzip (which is installed by default on any Linux/BSD/Mac variant)

**Note:** The `import.sh` script will set all data fields to *text*.

`import.py` is a python script. It requires the following to run:

1. Python 3 installed
2. SQLite
3. [pandas](https://pandas.pydata.org/)

## Step 1: Download the CSV or CSV.GZ files.

- Download the MIMIC-IV dataset from: https://physionet.org/content/mimiciv/
- Place `import.sh` or `import.py` into the same folder as the `csv` or `csv.gz` files

i.e. your folder structure should resemble:

```
path/to/mimic-iv/
├── import.sh
├── import.py
├── hosp
│   ├── admissions.csv.gz
│   ├── ...
│   └── transfers.csv.gz
└── icu
    ├── chartevents.csv.gz
    ├── ...
    └── procedureevents.csv.gz
```

## Step 2: Edit the script if needed.

`import.sh` does **not** need edits to work with either the demo or full dataset.
Please continue to Step 3.

If you are using the `import.py` script,
it may be necessary to make minor edits to the `import.py` script. For example:

- If your files are `.csv` rather than `csv.gz`, you will need to change `csv.gz` to `csv`.

## Step 3: Generate the SQLite file

To generate the SQLite file:

If you are using `import.sh`, run on the command-line:

```
$ ./import.sh
```

If you are using `import.py`, run on the command-line:

```
$ python import.py
```

If loading the full dataset, this will take some time,
particularly the `CHARTEVENTS` table.

The scripts will ultimately generate an SQLite database file called `mimic4.db`.
