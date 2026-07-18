# PostgreSQL concepts

This folder contains scripts to generate useful abstractions of raw MIMIC-IV data ("concepts"). The
scripts are intended to be run against the MIMIC-IV data in a PostgreSQL database.
If you would like to contribute a correction, it should be for the corresponding file in the concepts folder.

To generate concepts, change to this directory and run `psql`. Then within psql, run:

```sql
\i postgres-make-concepts.sql
```

... or, run the SQL files in your GUI of choice.

If you are porting your own query from BigQuery to PostgreSQL, use the transpiler rather than hand-translating it. It converts BigQuery-only constructs (`DATETIME_DIFF`, `REGEXP_EXTRACT`, `GENERATE_ARRAY`, and so on) to PostgreSQL with the same semantics used by the concepts in this folder — see [src/mimic_utils/sqlglot_dialects/postgres.py](/src/mimic_utils/sqlglot_dialects/postgres.py).