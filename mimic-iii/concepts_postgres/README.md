# PostgreSQL concepts (MIMIC-III)

This folder contains scripts to generate useful abstractions of raw MIMIC-III data ("concepts") in a PostgreSQL database.
Almost all of these scripts were generated automatically from the BigQuery SQL dialect using the [sqlglot](https://github.com/tobymao/sqlglot) package.
If you would like to contribute a correction, do not make it here. Instead, make your correction in the [concepts folder](/mimic-iii/concepts/) using the BigQuery SQL syntax, and regenerate this folder as described in that folder's [README](/mimic-iii/concepts/README.md).

Two files are hand-written for PostgreSQL and have no BigQuery source:

* [diagnosis/ccs_multi_dx.sql](diagnosis/ccs_multi_dx.sql) loads the ICD-9 to CCS mapping from [diagnosis/ccs_multi_dx.csv.gz](diagnosis/ccs_multi_dx.csv.gz).
* [demographics/note_counts.sql](demographics/note_counts.sql) is an optional PostgreSQL-only concept which summarizes note counts per hospital admission (it is not run by the make script).

## Using these concepts

The scripts assume the MIMIC-III data have been loaded into the `mimiciii` schema, as done by the [buildmimic/postgres](/mimic-iii/buildmimic/postgres) scripts, and create the concept tables in the `mimiciii_derived` schema.

Create the derived schema if it does not exist, then run the make script from this folder (the paths are relative):

```sh
psql -c "CREATE SCHEMA IF NOT EXISTS mimiciii_derived;"
psql -v ON_ERROR_STOP=1 -f postgres-make-concepts.sql
```

The [postgres-functions.sql](postgres-functions.sql) file contains definitions for a few functions which exist in BigQuery but do not exist in PostgreSQL. It is no longer required by the generated concepts, but the functions are convenient if you find yourself switching back and forth between the two dialects.
