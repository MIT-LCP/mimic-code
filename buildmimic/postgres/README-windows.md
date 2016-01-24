# Instructions for windows users

Install PostgreSQL using the installer linked to here:
http://www.postgresql.org/download/windows/

Run through the entire install process - remember your postgres user password.

# Run SQL Shell (psql)

Log-in as user postgres (and the password you specified during the install process)

Run the following commands:

```sql
DROP DATABASE IF EXISTS mimic;
CREATE DATABASE mimic OWNER postgres;
```

This creates the database `mimic`, owned by user `postgres`. Of course you are welcome to change these values if you like - you will need to change the following. Next, connect to the `mimic` database.

```sql
\c mimic;
```

Run the create tables script (note: this assumes that the create table script is in the current directory - if it is not, see below).

```sql
\i postgres_create_tables.sql
```

If you get the error `postgres_create_tables.sql: No such file or directory` that means that the file `postgres_create_tables.sql` is not in your current directory. Specify the path to the file. In my case, I wrote:

```sql
\i D:/work/mimic-code/buildmimic/postgres/postgres_create_tables.sql
```

If you see a lot of "NOTICE: table does not exist" don't worry, that's normal. The script tries to delete the table before it creates it. Next, import the data into these tables.

-v mimic_data_dir=${datadir} --dbname="$(DBNAME)" --username="$(DBUSER)"

```sql
\set ON_ERROR_STOP 1
\set mimic_data_dir 'D:/mimic/v1_3'
SET search_path TO mimiciii;
\i D:/work/mimic-code/buildmimic/postgres/postgres_load_data.sql
```
