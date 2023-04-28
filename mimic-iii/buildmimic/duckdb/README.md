# MIMIC-III in DuckDB

The scripts in this folder create the schema for MIMIC-III and
loads the data into the appropriate tables for
[DuckDB](https://duckdb.org/).

The Python script (`import_duckdb.py`) also includes the option to 
add the [concepts views](../../concepts/README.md) to the database.
This makes it much easier to use the concepts views as you do not
have to install and setup PostgreSQL or use BigQuery.

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

This will make you `mimic_data_dir` be `mimiciii/1.4`.

The rest of these intructions assume the CSV files are in the folder structure as follows:
    
```
mimic_data_dir/
    ADMISSIONS.csv.gz
    CALLOUT.csv.gz
    ...
```

The CSV files can be uncompressed (end in `.csv`) or compressed (end in `.csv.gz`).


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

You can do all of this will one shell script, `import_duckdb.sh`,
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

## Python script method (`import_duckdb.py`)

This method does not require the DuckDB executable, the DuckDB Python
module, and the [sqlglot](#build-and-modify-sql), both of which can be
easily installed with `pip`.

### Install dependencies

Install the dependencies by using the included `requirements.txt` file:

```sh
python3 -m pip install -r ./requirements.txt
```

### Create DuckDB database and load data

Create the MIMIC-III database with `import_duckdb.py` like so:

```sh
python ./import_duckdb.py /path/to/mimic_data_dir ./mimic3.db
```

...where `/path/to/mimic_data_dir` is the path containing the .csv or .csv.gz
data files downloaded above.

This command will create the `mimic3.db` file in the current directory. Be aware that
for the full MIMIC-III v1.4 dataset the resulting file will be about 34GB in size.
This process will take some time, as with the shell script version.

The default options will create only the tables and load the data, and assume
that you are running the script from the same directory where this README.md
is located. See the full options below if the defaults are insufficient.

### Create the concepts views

In most cases you will want to create the concepts views at the same time as
the database. To do this, add the `--make-concepts` option:

```sh
python ./import_duckdb.py /path/to/mimic_data_dir ./mimic3.db --make-concepts
```

If you want to add the concepts to a database already created without this
option (or created with the shell script version), you can add the
`--skip-tables` option as well:

```sh
python ./import_duckdb.py /path/to/mimic_data_dir ./mimic3.db --make-concepts --skip-tables
```

### Additional options

There are a few additional options for special situations:

| Option | Description
| - | -
| `--skip-indexes` | Don't create additional indexes when creating tables and loading data. This may be useful in memory-constrained systems or to save a little time.
| `--mimic-code-root [path]` | This argument specifies the location of the mimic-code repository files. This is needed to find the concepts SQL files. This is useful if you are running the script from a different directory than the one where this README.md file is located (the default is `../../../`)
| `--schema-name [name]` | This puts the tables and concepts views into a named schema in the database. This is mainly useful to mirror the behavior of the PostgreSQL version of the database, which places objects in a schema named `mimiciii` by default--if you have existing code designed for the PostgreSQL version, this may make migration easier. Note that--like the PostgreSQL version--the `ccs_dx` view is *not* placed in the specified schema, but in the default schema (which is `main` in DuckDB, not `public` as in PostgreSQL).

# Help

Please see the [issues page](https://github.com/MIT-LCP/mimic-iii/issues) to discuss other issues you may be having.
