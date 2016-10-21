# Create MIMIC-III in a local Postgres database

## Instructions for use

First ensure that Postgres is running on your computer. For installation instructions, see: [http://www.postgresql.org/download/](http://www.postgresql.org/download/)

Once Postgres is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory using the following command:

``` bash
$ git clone https://github.com/MIT-LCP/mimic-code.git
```

Change to the ``` buildmimic/postgres/``` directory and use ```make``` to run the Makefile, which contains instructions for creating MIMIC in a local Postgres database. For instructions on using the Makefile, run the following command:

``` bash
$ make help
```

For example, to create MIMIC from a set of zipped CSV files in the "/path/to/data/" directory, run the following command:

``` bash
$ make mimic datadir="/path/to/data/"
```

If default connection parameters are not correct, specify in Makefile header or in environment, e.g.:

``` bash
$ DBNAME="my_db" DBPASS="my_pass" DBHOST="192.168.0.1" make mimic-build datadir="/path/to/data/"
```

When using the database be sure to switch to the mimic namespace,

```bash
$ psql mimic
mimic=# SET search_path TO mimiciii;
```

# Troubleshooting

## Error creating schema

```sql
psql:postgres_create_tables.sql:12: ERROR:  syntax error at or near "NOT"
LINE 1: CREATE SCHEMA IF NOT EXISTS mimiciii;
```

The `IF NOT EXISTS` syntax was introduced in PostgreSQL 9.3. Make sure you have the latest PostgreSQL version. While one possible option is to modify the code here to be function under earlier versions, we highly recommend upgrading as most of the code written in this repository uses materialized views (which were introduced in PostgreSQL version 9.4).
