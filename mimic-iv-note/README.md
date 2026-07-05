# MIMIC-IV-Note

* [buildmimic](/mimic-iv-note/buildmimic) - Scripts to build MIMIC-IV-Note in various database systems
    * [postgres](/mimic-iv-note/buildmimic/postgres) - PostgreSQL (v10+)
    * [duckdb](/mimic-iv-note/buildmimic/duckdb) - DuckDB (serverless, single-file)
    * [bigquery](/mimic-iv-note/buildmimic/bigquery) - BigQuery schemas

MIMIC-IV-Note contains deidentified free-text clinical notes for patients in MIMIC-IV, including discharge summaries and radiology reports. It is a separate download from MIMIC-IV and is available on [PhysioNet](https://physionet.org/content/mimic-iv-note/).

There are currently no derived concept scripts for MIMIC-IV-Note.

## Building the database

### PostgreSQL

```sh
psql -d mimiciv -f mimic-iv-note/buildmimic/postgres/create.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=<path to mimic-iv-note>/note \
  -f mimic-iv-note/buildmimic/postgres/load_gz.sql
```

See the [postgres README](/mimic-iv-note/buildmimic/postgres/README.md) for full details.

### DuckDB

```sh
cd mimic-iv-note/buildmimic/duckdb
./import_duckdb.sh <path to mimic-iv-note>
```

See the [duckdb README](/mimic-iv-note/buildmimic/duckdb/README.md) for full details.
