# MIMIC-IV Concepts

This folder contains scripts to generate useful abstractions of raw MIMIC-IV data ("concepts"):

- The script `make_concepts.sh` is intended to be run against the BigQuery instantiation of MIMIC-IV.
- The script `make_concepts_postgres.sh` is intended to be run against the PostgreSQL instantiation of MIMIC-IV.
- The script `functions-postgres.sql` defines useful Postgres functions which is needed by `make_concepts_postgres.sh`.

Concepts are categorized into folders if possible, otherwise they remain in the top-level directory.



## Generating the concepts in PostgreSQL (\*nix)

To generate all concepts as materialized views in Postgres, the `make_concepts_postgres.sh` script assumes that a database named `mimiciv` is built locally and holds all `mimic-iv` data. It also assumes that postgres service is running and listening at port `5432` (which is the default setting if you haven't changed it manually). The example user name and password to connnect to postgres are set to `postgres` and should be modified accordingly if you use other user names and passwords.

Steps to generated all concepts as materialized views, take the following steps:

1. Open a terminal in the `concepts` folder.
2. Run [make_concepts_postgres.sh](make_concepts_postgres.sh). * This file generates all concepts on the `mimic_iv_derived` schema.