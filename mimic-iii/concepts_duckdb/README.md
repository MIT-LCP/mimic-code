# DuckDB concepts (MIMIC-III)

This folder contains scripts to generate useful abstractions of raw MIMIC-III data ("concepts") in [DuckDB](https://duckdb.org/).
Almost all of these scripts were generated automatically from the BigQuery SQL dialect using the [sqlglot](https://github.com/tobymao/sqlglot) package.
If you would like to contribute a correction, do not make it here. Instead, make your correction in the [concepts folder](/mimic-iii/concepts/) using the BigQuery SQL syntax, and regenerate this folder as described in that folder's [README](/mimic-iii/concepts/README.md).

One file is hand-written for DuckDB and has no BigQuery source: [diagnosis/ccs_multi_dx.sql](diagnosis/ccs_multi_dx.sql) loads the ICD-9 to CCS mapping from [diagnosis/ccs_multi_dx.csv.gz](diagnosis/ccs_multi_dx.csv.gz).

## Using these concepts

The scripts assume the MIMIC-III data have been loaded into a `mimiciii` schema of the DuckDB database, and create the concept tables in the `mimiciii_derived` schema. For example, to load the data with the standard DDL:

```sh
duckdb mimic3.db -c "CREATE SCHEMA mimiciii; CREATE SCHEMA mimiciii_derived;"
# create the tables in the mimiciii schema and COPY each table's CSV into it,
# e.g. using mimic-iii/buildmimic/duckdb/duckdb_add_tables.sql after USE mimiciii;
```

The `duckdb.sql` file calls all the concepts in the correct order and outputs them to the `mimiciii_derived` schema.
You should connect to your DuckDB database file and run this file from this folder (the paths are relative):

```sh
cd mimic-iii/concepts_duckdb
duckdb /path/to/mimic3.db -c ".read duckdb.sql"
```
