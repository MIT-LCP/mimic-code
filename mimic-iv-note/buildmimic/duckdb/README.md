# DuckDB

The script in this folder creates the schema for MIMIC-IV-NOTE and
loads the data into the appropriate tables for
[DuckDB](https://duckdb.org/).
DuckDB, like SQLite, is serverless and
stores all information in a single file.
Unlike SQLite, an OLTP database,
DuckDB is an OLAP database, and therefore optimized for analytical queries.
This will result in faster queries for researchers using MIMIC-IV-NOTE
with DuckDB compared to SQLite.
To learn more, please read their ["why duckdb"](https://duckdb.org/docs/why_duckdb)
page.

The instructions to load MIMIC-IV-NOTE into a DuckDB
only require:
1. DuckDB to be installed and
2. Your computer to have a POSIX-compliant terminal shell,
   which is already found by default on any Mac OSX, Linux, or BSD installation.

To use these instructions on Windows,
you need a Unix command line environment,
which you can obtain by either installing
[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
or [Cygwin](https://www.cygwin.com/).

## Set-up

### Quick overview

1. [Install](https://duckdb.org/docs/installation/) the CLI version of DuckDB
2. [Download](https://https://physionet.org/content/mimic-iv-note/2.2/) the MIMIC-IV-NOTE files
3. Create DuckDB database and load data

### Install DuckDB

Follow instructions on their website to
[install](https://duckdb.org/docs/installation/)
the CLI version of DuckDB.

You will need to place the `duckdb` binary in a folder on your environment path,
e.g. `/usr/local/bin`.

### Download MIMIC-IV-NOTE files

Download the CSV files for [MIMIC-IV-NOTE](https://physionet.org/content/mimic-iv-note/2.2/)
by any method you wish.
These instructions were tested with MIMIC-IV-NOTE v2.2.

The CSV files should be a folder structure as follows:
    
```
mimic_data_dir
    note
        discharge.csv.gz
        ...
        radiology_detail.csv.gz
```

The CSV files can be uncompressed (end in `.csv`) or compressed (end in `.csv.gz`).

The easiest way to download them is to open a terminal then run:

```
wget -r -N -c -np --user YOURUSERNAME --ask-password https://physionet.org/files/mimic-iv-note/2.2/
```

Replace `YOURUSERNAME` with your physionet username.

This will make you `mimic_data_dir` be `physionet.org/files/mimic-iv-note/2.2`.

# Create DuckDB database and load data

The last step requires creating a DuckDB database and
loading the data into it.

You can do all of this will one shell script, `import_duckdb.sh`,
located in this repository.

See the help for it below:

```sh
$ ./import_duckdb.sh -h
./import_duckdb.sh:
USAGE: ./import_duckdb.sh mimic_data_dir [output_db]
WHERE:
    mimic_data_dir        directory that contains csv.gz or csv files
    output_db: optional   filename for duckdb file (default: mimic4_note.db)
$
```

The script will print out progress as it goes.
Be patient, this can take minutes to hours to load
depending on your computer's configuration.

* It took about a minute in an Ubuntu 24.04 container with duckdb v1.0.0 on a Windows 11 host 8-core i9 with 32GB RAM.

# Help

Please see the [issues page](https://github.com/MIT-LCP/mimic-code/issues) to discuss other issues you may be having.
