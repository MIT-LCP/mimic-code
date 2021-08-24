# MIMIC-IV Concepts

This folder contains scripts to generate useful abstractions of raw MIMIC-IV data ("concepts").
The scripts are written using the **BigQuery Standard SQL Dialect**. Concepts are categorized into folders if possible, otherwise they remain in the top-level directory. The [postgres](/mimic-iv/concepts/postgres) subfolder contains automatically generated PostgreSQL versions of these scripts; [see below for how these were generated](#postgresql-concepts). Concepts are categorized into folders if possible, otherwise they remain in the top-level directory.

The concepts are organized into individual SQL scripts, with each script generating a table. The BigQuery `mimic_derived` dataset under `physionet-data` contains the concepts pregenerated. Access to this dataset is available to MIMIC-IV approved users: see the [cloud instructions](https://mimic.mit.edu/docs/gettingstarted/cloud/) on how to access MIMIC-IV on BigQuery (which includes the derived concepts).

* [List of the concept folders and their content](#concept-index)
* [Generating the concept tables on BigQuery](#generating-the-concepts-on-bigquery)
* [Generating the concept tables on PostgreSQL](#generating-the-concepts-on-postgresql)

## Concept Index

## Generating the concepts on BigQuery

Generating the concepts requires the [Google Cloud SDK](https://cloud.google.com/sdk) to be installed.
A shell script, [make_concepts.sh](/mimic-iv/concepts/make_concepts.sh), is provided which iterates over each folder and creates a table with the same name as the concept file. Concept names have been chosen specifically to avoid collisions.

Generating a single concept can be done by calling the Google Cloud SDK as follows:

```sh
bq query --use_legacy_sql=False --replace --destination_table=my_bigquery_dataset.age < demographics/age.sql
```

In general the concepts may be generated in any order, except for the *first_day_sofa* and *kdigo_stages* tables, which depend on other tables.

## Generating the concepts on PostgreSQL

These instructions are used to regenerate the [postgres](/mimic-iv/concepts/postgres) scripts from the BigQuery dialect scripts in the concepts folder.

* **If you just want to create PostgreSQL concepts for your installation of MIMIC-IV, go to the [postgres](/mimic-iv/concepts/postgres) subfolder**
* If you would like to understand the process better, and possibly improve upon it, read on

Analogously to [MIMIC-III Concepts](https://github.com/MIT-LCP/mimic-code/tree/master/concepts), the SQL scripts here are written in BigQuery's Standard SQL syntax. The concepts have been carefully written to allow conversion to PostgreSQL, so that only the following changes are necessary to make them compaible with PostgreSQL:

* create postgres functions which emulate BigQuery functions
* modify SQL scripts for incompatible syntax
* run the modified SQL scripts and direct the output into tables in the PostgreSQL database

To do this, we have created a (*nix/Mac OS X) compatible shell script which performs regular expression replacements for each script. To simplify the process for users, we output these automatically generated scripts to the [postgres](/mimic-iv/concepts/postgres) folder.
Re-running this shell script can be done as follows:

1. Open a terminal in the `concepts` folder.
2. Run [convert_bigquery_to_postgres.sh](convert_bigquery_to_postgres.sh).
    * e.g. `bash convert_bigquery_to_postgres.sh`
    * This file outputs the scripts to the [postgres](/mimic-iv/concepts/postgres) subfolder after applying a few changes.
    * This also creates the `postgres_make_concepts.sql` script in the postgres subfolder.

### Known Problems

* [convert_bigquery_to_postgres.sh](convert_bigquery_to_postgres.sh) fails for [suspicion_of_infection](sepsis/suspicion_of_infection.sql) due to `, DATETIME_TRUNC(abx.starttime, DAY) AS antibiotic_date`. As a consequence also [sepsis3](sepsis/sepsis3.sql) fails.
* The script runs repeatetly for subfolders `score` and `sepsis` to handle interdependecies between tables. Running the concept scripts in the correct order can be improved.
* The regular expressions in [convert_bigquery_to_postgres.sh](convert_bigquery_to_postgres.sh) depend on the current SQL scripts and might fail when they are changed.
