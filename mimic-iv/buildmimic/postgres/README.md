# Load MIMIC-IV into a PostgreSQL database

The scripts in this folder create the schema for MIMIC-IV and load the data into the appropriate tables for PostgreSQL v10+.
If you are having trouble, take a look at the common issues in the FAQ at the bottom of this page.

<!-- 
* You can follow the tutorial to run each file individually. Windows users can follow along [here](https://mimic.physionet.org/tutorials/install-mimic-locally-windows/), while *nix/Mac OS X users can follow along [here](https://mimic.physionet.org/tutorials/install-mimic-locally-ubuntu/)

If following the tutorials, be sure to download the scripts locally and the MIMIC-III files locally. If you choose the makefile approach, see the below section.

-->

## Quickstart

```sh
# clone repo
git clone https://github.com/MIT-LCP/mimic-code.git
cd mimic-code
# download data
wget -r -N -c -np --user <USERNAME> --ask-password https://physionet.org/files/mimiciv/2.0/
mv physionet.org/files/mimiciv mimiciv && rmdir physionet.org/files && rm physionet.org/robots.txt && rmdir physionet.org
createdb mimiciv
psql -d mimiciv -f mimic-iv/buildmimic/postgres/create.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=mimiciv -f mimic-iv/buildmimic/postgres/load_gz.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=mimiciv -f mimic-iv/buildmimic/postgres/constraint.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=mimiciv -f mimic-iv/buildmimic/postgres/index.sql
```

## Detailed guide

First ensure that Postgres is running on your computer. For installation instructions, see: [http://www.postgresql.org/download/](http://www.postgresql.org/download/)

Once Postgres is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory. We only need the contents of this directory, but it's useful to have the repository locally. You can clone the repository using the following command:

``` bash
git clone https://github.com/MIT-LCP/mimic-code.git
```

Change to the `mimic-iv/buildmimic/postgres/` directory. Create the schemas and tables with the following psql command. **This will delete any data present in the schemas.**

```sh
psql -f create.sql
```

Afterwards, we need to load the MIMIC-IV files into the database. To do so, we'll specify the location of the local CSV files (compressed or uncompressed).
Note that this assumes the folder structure is as follows:

```
mimic_data_dir
    core
        admissions.csv
        ...
    hosp
    icu
```

If you have compressed files (.csv.gz), you can leave them compressed, and use the `load_gz.sql` script instead.
Once you have verified your data is stored in this structure, run:

```sh
psql -v ON_ERROR_STOP=1 -v mimic_data_dir=<INSERT MIMIC FILE PATH HERE> -f load.sql
```


## Troubleshooting / FAQ

### Specify a database for installation

Optionally, you can specify the database name with the `-d` argument. First, you must create the database if it does not already exist:

```sh
createdb mimiciv
```

After the database exists, the schema and tables can be created under this database as follows:

```sh
psql -d mimiciv -f create.sql
```

Finally, loading the data into this data requires specifying the database name with `-d mimiciv` again:

```sh
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=<INSERT MIMIC FILE PATH HERE> -f load.sql
```

### Error creating schema

```sql
psql:postgres_create_tables.sql:12: ERROR:  syntax error at or near "NOT"
LINE 1: CREATE SCHEMA IF NOT EXISTS mimiciii;
```

The `IF NOT EXISTS` syntax was introduced in PostgreSQL 9.3. Make sure you have the latest PostgreSQL version. While one possible option is to modify the code here to be function under earlier versions, we highly recommend upgrading as most of the code written in this repository uses materialized views (which were introduced in PostgreSQL version 9.4).

### Peer authentication failed

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

### NOTICE

```sql
NOTICE:  materialized view "XXXXXX" does not exist, skipping
```

This is normal. By default, the script attempts to delete tables before rebuilding them. If it cannot find the table to delete, it outputs a notice letting the user know.

### Stuck on copy

Many users report that the scripts get stuck at the following point:

```sh
COPY 58976
COPY 34499
COPY 7567
```

This is expected. The 4th table is CHARTEVENTS, and this table can take many hours to load. Give it time, and ensure that the computer does not automatically hibernate during this time.

Also note that eventually, the 4th line will read `COPY 0`. This is expected, see https://github.com/MIT-LCP/mimic-code/issues/182

## Older versions of PostgreSQL

If you have an older version of PostgreSQL, then it is still possible to load MIMIC, but modifications to the scripts are required. In particular, the scripts use declarative partitioning for larger tables to speed up queries. To read more about [declarative partitioning, see the PostgreSQL documentation](https://www.postgresql.org/docs/10/static/ddl-partitioning.html#DDL-PARTITIONING-DECLARATIVE). You can remove declarative partitionining by modifying the create script, and removing it for each affected table. For example, chartevents uses declarative partitioning, and thus the create.sql script creates many partitions for chartevents: chartevents_01, chartevents_02, ..., etc. Replacing these with a single create statement for chartevents will make the script compatible for older versions of PostgreSQL.

### Other

Please see the [issues page](https://github.com/MIT-LCP/mimic-iv/issues) to discuss other issues you may be having.
