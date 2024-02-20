# MIMIC-III in DuckDB

The scripts in this folder create the schema for MIMIC-III and
loads the data into the appropriate tables for
[DuckDB](https://duckdb.org/).

DuckDB, like SQLite, is serverless and
stores all information in a single file.
Unlike SQLite, an OLTP database,
DuckDB is an OLAP database, and therefore optimized for analytical queries.
This will result in faster queries for researchers using MIMIC-III
with DuckDB compared to SQLite.
To learn more, please read their ["why duckdb"](https://duckdb.org/docs/why_duckdb)
page.

## Download MIMIC-III files

[Download](https://physionet.org/content/mimiciii/1.4/)
the CSV files for MIMIC-III by any method you wish.
(These scripts should also work with the much smaller
[demo version](https://physionet.org/content/mimiciii-demo/1.4/#files-panel)
of the dataset.)

The easiest way to download them is to open a terminal then run:

```
wget -r -N -c -np -nH --cut-dirs=1 --user YOURUSERNAME --ask-password https://physionet.org/files/mimiciii/1.4/
```

Replace `YOURUSERNAME` with your physionet username.

The rest of these intructions assume the CSV files are in the folder structure as follows:
    
```
mimic_data_dir/
    ADMISSIONS.csv.gz
    CALLOUT.csv.gz
    ...
```

By default, the above `wget` downloads the data into `mimiciii/1.4` (as we used `--cut-dirs=1` to remove the base folder). Thus, by default, `mimic_data_dir` is `mimiciii/1.4` (relative to the current folder). The CSV files can be uncompressed (end in `.csv`) or compressed (end in `.csv.gz`).


## Shell script method (`import_duckdb.sh`)

Using this script to load MIMIC-III into a DuckDB
only requires:
1. DuckDB to be installed (the `duckdb` executable must be in your PATH)
2. Your computer to have a POSIX-compliant terminal shell,
   which is already found by default on any Mac OSX, Linux, or BSD installation.

To use these instructions on Windows,
you need a Unix command line environment,
which you can obtain by either installing
[Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
or [Cygwin](https://www.cygwin.com/).

### Install DuckDB

Follow instructions on their website to
[install](https://duckdb.org/docs/installation/)
the CLI version of DuckDB.

You will need to place the `duckdb` binary in a folder on your environment path,
e.g. `/usr/local/bin`.


### Create DuckDB database and load data

You can do all of this with one shell script, `import_duckdb.sh`,
located in this repository.

See the help for it below:

```sh
$ ./import_duckdb.sh -h
./import_duckdb.sh:
USAGE: ./import_duckdb.sh mimic_data_dir [output_db]
WHERE:
    mimic_data_dir        directory that contains csv.gz or csv files
    output_db: optional   filename for duckdb file (default: mimic3.db)
$
```

Here's an example invocation that will make the database in the default "mimic3.db":

```sh
$ ./import_duckdb.sh physionet.org/files/mimiciii/1.4

... output removed
Successfully finished loading data into mimic3.db.

$ ls -lh mimic3.db
-rw-rw-r--. 1 myuser mygroup 26G Jan 25 16:11 mimic3.db
```

The script will print out progress as it goes.
Be patient, this can take minutes to hours to load
depending on your computer's configuration.


# Help

Please see the [issues page](https://github.com/MIT-LCP/mimic-code/issues) to discuss other issues you may be having.
