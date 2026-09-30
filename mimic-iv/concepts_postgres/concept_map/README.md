# Load MIMIC-IV Concept Maps into a PostgreSQL database

The scripts in this folder create the schema for MIMIC-IV concept maps and load the mapping data into the appropriate tables for PostgreSQL v10+.

Concept maps provide mappings from MIMIC-IV local codes to standard terminologies (LOINC, OMOP, RxNorm, SNOMED).

## Quickstart

Run from the `mimic-iv/concepts_postgres/concept_map/` directory:

```sh
psql -d mimiciv -f create.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -f load.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -f constraint.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -f index.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -f validate.sql
```

## Detailed guide

First ensure that Postgres is running on your computer and that the MIMIC-IV database already exists. If not, follow the instructions in `mimic-iv/buildmimic/postgres/README.md` to set up the base MIMIC-IV database first.

### Step 1: Create schema and tables

Change to the `mimic-iv/concepts_postgres/concept_map/` directory. Create the schema and tables with:

```sh
psql -d mimiciv -f create.sql
```

This creates the `mimiciv_concept_map` schema with the following tables:

| Table | Description |
|---|---|
| labevents_to_loinc | Lab items mapped to LOINC codes |
| labevents_to_omop | Lab items mapped to OMOP concepts |
| prescriptions_to_rxnorm | Prescriptions mapped to RxNorm codes |
| prescriptions_to_omop | Prescriptions mapped to OMOP concepts |
| chartevents_to_loinc | Chart items mapped to LOINC codes |
| chartevents_to_omop | Chart items mapped to OMOP concepts |
| procedureevents_to_snomed | Procedures mapped to SNOMED codes |
| procedureevents_to_omop | Procedures mapped to OMOP concepts |

**Note:** This will drop and recreate the `mimiciv_concept_map` schema, deleting any existing data.

### Step 2: Load data

The load script expects CSV files in the following structure relative to this directory:

```
../../concepts/concept_map/
    hosp/
        labevents_to_loinc.csv
        labevents_to_omop.csv
        prescriptions_to_rxnorm.csv
        prescriptions_to_omop.csv
    icu/
        chartevents_to_loinc.csv
        chartevents_to_omop.csv
        procedureevents_to_snomed.csv
        procedureevents_to_omop.csv
```

Load the data with:

```sh
psql -d mimiciv -v ON_ERROR_STOP=1 -f load.sql
```

### Step 3: Add constraints

```sh
psql -d mimiciv -v ON_ERROR_STOP=1 -f constraint.sql
```

This adds primary key constraints on `subject_id` for tables where it is unique. Prescriptions tables are excluded because multiple NDC mappings can share the same `subject_id`.

### Step 4: Create indexes

```sh
psql -d mimiciv -v ON_ERROR_STOP=1 -f index.sql
```

This creates indexes on `subject_id` and `object_id` for each table to speed up lookups.

### Step 5: Validate

```sh
psql -d mimiciv -v ON_ERROR_STOP=1 -f validate.sql
```

This checks row counts against expected values to ensure data was loaded correctly.

## Troubleshooting

### Specify a database

If your database is not the default, specify it with the `-d` argument:

```sh
psql -d mimiciv -f create.sql
```

### NOTICE: table does not exist, skipping

This is normal. The script attempts to drop tables before creating them. If the table does not yet exist, it outputs a notice.
