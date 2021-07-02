# Create MIMIC-III in a local Postgres database

The scripts in this folder create a database to host the MIMIC-III data. You can use these scripts in one of two ways:

* On *nix systems (such as Ubuntu or Mac OS X), you can use the make file
* You can follow the tutorial to run each file individually. Windows users can follow along [here](https://mimic.physionet.org/tutorials/install-mimic-locally-windows/), while *nix/Mac OS X users can follow along [here](https://mimic.physionet.org/tutorials/install-mimic-locally-ubuntu/)

If following the tutorials, be sure to download the scripts locally and the MIMIC-III files locally. If you choose the makefile approach, see the below section.

Note: if you are using PostgreSQL 10, then you can use the `postgres_create_tables_pg10.sql` script instead of the `postgres_create_tables.sql` script to use the new declarative partitioning syntax. To read more about declarative partitioning, see [here](https://www.postgresql.org/docs/10/static/ddl-partitioning.html#DDL-PARTITIONING-DECLARATIVE) (in the context of MIMIC, the partitioning groups data by `itemid` to speed up queries). The makefile will try to use this script if your PostgreSQL version is higher than 10.

# Hard drive space required

Loading the data into a PostgreSQL database requires around ~47 GB of space. The addition of indexes adds another 26 GB. You will likely want to reserve 100 GB for the entire database.

# Instructions for use of Makefile

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
$ make create-user mimic datadir="/path/to/data/"
```

By default, the Makefile uses the following parameters:

* Database name: `mimic`
* User name: `postgres`
* Password: `postgres`
* Schema: `mimiciii`
* Host: none (defaults to localhost)
* Port: none (defaults to 5432)

If you would like to change any of these parameters, you can do so in the make call:

``` bash
$ make create-user mimic datadir="/path/to/data/" DBNAME="my_db" DBPASS="my_pass" DBHOST="192.168.0.1"
```

Note that the `create-user` creates the user, database, and schema. If these already exist, you do not need to call it.

When using the database be sure to change the default search path to the mimic schema:

```bash
# connect to database mimic
$ psql -d mimic
# set default schema to mimiciii
mimic=# SET search_path TO mimiciii;
```

# Troubleshooting

## Error creating schema

```sql
psql:postgres_create_tables.sql:12: ERROR:  syntax error at or near "NOT"
LINE 1: CREATE SCHEMA IF NOT EXISTS mimiciii;
```

The `IF NOT EXISTS` syntax was introduced in PostgreSQL 9.3. Make sure you have the latest PostgreSQL version. While one possible option is to modify the code here to be function under earlier versions, we highly recommend upgrading as most of the code written in this repository uses materialized views (which were introduced in PostgreSQL version 9.4).

## Peer authentication failed

If during `make mimic-build` you encounter following error:

```bash
psql "dbname=mimic user=postgres options=--search_path=mimiciii" -v ON_ERROR_STOP=1 -f postgres_create_tables$(psql --version | perl -lne 'print "_pg10" if / 10.\d+/').sql
psql: FATAL:  Peer authentication failed for user "postgres"
Makefile:110: recipe for target 'mimic-build' failed
make: *** [mimic-build] Error 2
```

... this indicates that the database exists, but the script failed to login as the user `postgres`. By default, postgres installs itself with a user called `postgres`, and only allows "peer" authentication: logging in with the same username as your operating system username. Consequently, a common issue users have is being unable to access the database with the default postgres users.

There are many possible solutions, but the two easiest are (1) allowing `postgres` to login via password authentication or (2) creating the database with a username that matches your operating system username.

#### (1) Allow password authentication

Locate your `pg_hba.conf` file and update the method of access from "peer" to "md5" (md5 is password authentication), e.g. here is an example using text editor `nano`:

```bash
sudo nano /etc/postgresql/10/main/pg_hba.conf
``` 

(Path may change on different postgresql version). Change `local all postgres peer` to `local all postgres md5`.

Restart postgresql service with: 
```bash 
sudo service postgresql restart
```

#### (2) Use operating system

Specify $DBUSER to be your operating system username, e.g. on Ubuntu you can use the `$USER` environment variable directly:

`make create-user mimic-gz datadir="$datadir" DBUSER="$USER"`

## NOTICE

```sql
NOTICE:  materialized view "XXXXXX" does not exist, skipping
```

This is normal. By default, the script attempts to delete tables before rebuilding them. If it cannot find the table to delete, it outputs a notice letting the user know.

## Stuck on copy

Many users report that the scripts get stuck at the following point:

```
COPY 58976
COPY 34499
COPY 7567
```

This is expected. The 4th table is CHARTEVENTS, and this table can take many hours to load. Give it time, and ensure that the computer does not automatically hibernate during this time.

Also note that eventually, the 4th line will read `COPY 0`. This is expected, see https://github.com/MIT-LCP/mimic-code/issues/182

## Other

Please see the issues page to discuss other issues you may be having: https://github.com/MIT-LCP/mimic-code/issues
