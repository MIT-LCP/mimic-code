# Loading data in Oracle

This folder contains scripts for loading the data into an Oracle database system.
There are three steps to loading the data into Oracle:

1. The tables are created using an SQL script
2. `sqlldr` is used to load data into these tables (either individually or with a shell script)
3. Indices and constraints are added using an SQL script

The largest challenge in loading in data in Oracle is NOTEEVENTS. Oracle cannot handle reasonably standard formatted CSVs: instead it requires a special character to delineate a newline from a new row (most database systems can handle newlines if they are quoted, which is how the data for MIMIC-III is distributed). As a result, we have provided an additional Python script which will run through NOTEEVENTS and append a unique string of characters to the end of each row. The script can be called as follows:

```python
python add_oracle_rowdelimiter.py -d ',' -i 'NOTEEVENTS.csv' -r '><><?~`;;`'
```

The function will output a file called `NOTEEVENTS_output.csv`. You may then use the noteevents_output.ctl file to load in the data, e.g. where the tables are on the MIMICIII user's schema:

```sqlldr '\ as SYSDBA' control=noteevents_output.ctl log=noteevents_output.log```

# Step by step guide for loading data

A shell script called `build_mimic_oracle.sh` is provided to build MIMIC on an Oracle database, but note you will likely need to customize this script for your own purposes, including:

* modifying the default schema
* changing your authentication

Alternatively, you can follow this step by step guide:

1. Download the MIMIC-III data and extract it to a working folder
2. Add the control files, SQL scripts, and python script to the working folder
3. Open up either `sqlplus` or SQLDeveloper
4. Convert NOTEEVENTS.csv into a workable format: `python add_oracle_rowdelimiter.py -d ',' -i 'NOTEEVENTS.csv' -r '><><?~`;;`'`
5. Run `oracle_create_tables.sql`
6. Add permissions to run the bash script: `chmod a+x load_data_oracle.sh`
7. Run the bash script: `./load_data_oracle.sh`
    * It helps to be logged in as the Oracle user, as the script uses OS authentication to speed things up
    * If you do not know how to use OS authentication, remove '/ as SYSDBA' from the beginning of each line in the script
8. Run the `oracle_add_indexes.sql` and `oracle_add_constrants.sql` files

These scripts have yet to be fully tested and we would welcome pull requests, bug reports, or suggestions via GitHub.

# Load time

Load time for chartevents (the largest table) with partitions is ~30min

Elapsed time was:     00:33:46.44
CPU time was:         00:28:30.03
