# MIMIC-IV Concepts

This folder contains scripts to generate useful abstractions of raw MIMIC-IV data ("concepts"). The
scripts are intended to be run against the BigQuery instantiation of MIMIC-IV, and are written in the BigQuery Standard SQL dialect. Concepts are categorized into folders if possible, otherwise they remain in the top-level directory.

## Generating the concepts in PostgreSQL (*nix/Mac OS X)

Analogously to [MIMIC-III Concepts](https://github.com/MIT-LCP/mimic-code/tree/master/concepts), the SQL scripts here are written in BigQuery's Standard SQL syntax, so that the following changes are necessary to make them compaible with PostgreSQL:

* create postgres functions which emulate BigQuery functions (identical to MIMIC-III)
* modify SQL scripts for incompatible syntax
* run the modified SQL scripts and direct the output into tables in the PostgreSQL database

This can be done as follows (again, analogously to [MIMIC-III](https://github.com/MIT-LCP/mimic-code/tree/master/concepts):

1. Open a terminal in the `concepts` folder.
2. Run [postgres-functions.sql](postgres-functions.sql).
    * e.g. `psql -f postgres-functions.sql`
    * This script creates functions which emulate BigQuery syntax.
3. Run [postgres_make_concepts.sh](postgres_make_concepts.sh).
    * e.g. `bash postgres_make_concepts.sh`
    * This file runs the scripts after applying a few regular expressions which convert table references and date calculations appropriately.
    * This file generates all concepts on the `public` schema.

The main changes compared to MIMIC-III are slightly different regular expressions and a loop similar to [make_concepts.sh](make_concepts.sh). Also, one of them uses `perl` now, which might be necessary to install.

### Known Problems

* [postgres_make_concepts.sh](postgres_make_concepts.sh) fails for [suspicion_of_infection](sepsis/suspicion_of_infection.sql) due to `, DATETIME_TRUNC(abx.starttime, DAY) AS antibiotic_date`. As a consequence also [sepsis3](sepsis/sepsis3.sql) fails.
* The script runs repeatetly for subfolders `score` and `sepsis` to handle interdependecies between tables. Running the concept scripts in the correct order can be improved.
* The regular expressions in [postgres_make_concepts.sh](postgres_make_concepts.sh) depend on the current SQL scripts and might fail when they are changed.