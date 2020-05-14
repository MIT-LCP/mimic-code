# Building the MIMIC database with SQLite

`import.py` can be used to generate an SQLite database file from the MIMIC-III. We recommend that you test the process first with the MIMIC-III demo files available at: https://doi.org/10.13026/C2HM2Q

## Step 1: Download the CSV or CSV.GZ files.

- Downlod the MIMIC-III demo from https://doi.org/10.13026/C2HM2Q or the full MIMIC-III dataset from: https://doi.org/10.13026/C2XW26
- Place the files in the same folder as the `import.py` script.

## Step 2: Edit the script if needed.

It may be necessary to make minor edits to the `import.py` script. For example:

- If you are loading the demo, you may need to change `ROW_ID` to lowercase.
- If your files are `.CSV` rather than `CSV.GZ`, you will need to change `CSV.GZ` to `CSV`.

## Step 3: Generate the SQLite file with `import.py`

To generate the SQLite file, run `import.py` from the command line with: `python import.py`. The script should generate a database file called "mimic3.db".