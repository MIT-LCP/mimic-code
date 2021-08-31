# Load MIMIC-IV-ED into a PostgreSQL database

The scripts in this folder create the schema for MIMIC-IV-ED and load the data into the appropriate tables for PostgreSQL v10+.

<!-- 
* You can follow the tutorial to run each file individually. Windows users can follow along [here](https://mimic.physionet.org/tutorials/install-mimic-locally-windows/), while *nix/Mac OS X users can follow along [here](https://mimic.physionet.org/tutorials/install-mimic-locally-ubuntu/)

If following the tutorials, be sure to download the scripts locally and the MIMIC-IV-ED files locally. If you choose the makefile approach, see the below section.

-->

First ensure that Postgres is running on your computer. For installation instructions, see: [http://www.postgresql.org/download/](http://www.postgresql.org/download/)

Once Postgres is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory. We only need the contents of the `mimic-iv-ed/buildmimic/postgres/` directory, but it's useful to have the repository locally. You can clone the repository using the following command:

``` bash
git clone https://github.com/MIT-LCP/mimic-code.git
```

Change to the `mimic-iv-ed/buildmimic/postgres/` directory. Create the schemas and tables with the following psql command. **This will delete any data present in the schemas.**

```sh
psql -f create.sql
```

Afterwards, we need to load the MIMIC-IV-ED files into the database. To do so, we'll specify the location of the local CSV files (compressed or uncompressed).
Note that this assumes the folder `mimic_data_dir` contains all the `csv` or `csv.gz` files. If using compressed files (`.csv.gz`), use the `load_gz.sql` script instead of the `load.sql` script.

Once you have verified all data files are present, run:

```sh
psql -v ON_ERROR_STOP=1 -v mimic_data_dir=<INSERT MIMIC FILE PATH HERE> -f load.sql
```


## Troubleshooting / FAQ

### Specify a database for installation

Optionally, you can specify the database name with the `-d` argument. First, you must create the database if it does not already exist:

```sh
createdb mimic
```

After the database exists, the schema and tables can be created under this database as follows:

```sh
psql -d mimic -f create.sql
```

Finally, loading the data into this data requires specifying the database name with `-d mimicived` again:

```sh
psql -d mimic -v ON_ERROR_STOP=1 -v mimic_data_dir=<INSERT MIMIC FILE PATH HERE> -f load.sql
```

### Peer authentication failed

If you encounter following error:

```bash
psql "dbname=mimic user=postgres options=--search_path=mimic_ed" -v ON_ERROR_STOP=1 -f create.sql
psql: FATAL:  Peer authentication failed for user "postgres"
```

... this indicates that the database exists, but the script failed to login as the user `postgres`. By default, postgres installs itself with a user called `postgres`, and only allows "peer" authentication: logging in with the same username as your operating system username. Consequently, a common issue users have is being unable to access the database with the default postgres users.

There are many possible solutions, but the two easiest are (1) allowing `postgres` to login via password authentication or (2) creating the database with a username that matches your operating system username.

#### (1) Allow password authentication

Locate your `pg_hba.conf` file and update the method of access from "peer" to "md5" (md5 is password authentication), e.g. here is an example using text editor `nano`:

```bash
sudo nano /etc/postgresql/10/main/pg_hba.conf
```

(Path may change on different postgresql version). Change `local all postgres peer` to `local all postgres md5`.

Restart postgresql service with (command may change depending on system you use):

```bash 
systemctl restart postgresql.service 
```


### NOTICE

```sql
NOTICE:  table "XXXXXX" does not exist, skipping
```

This is normal. By default, the script attempts to delete tables before rebuilding them. If it cannot find the table to delete, it outputs a notice letting the user know.

## Older versions of PostgreSQL

If you have an older version of PostgreSQL, then it is still possible to load MIMIC, but modifications to the scripts are required. In particular, the scripts use declarative partitioning for larger tables to speed up queries. To read more about [declarative partitioning, see the PostgreSQL documentation](https://www.postgresql.org/docs/10/static/ddl-partitioning.html#DDL-PARTITIONING-DECLARATIVE). You can remove declarative partitionining by modifying the create script, and removing it for each affected table. For example, chartevents in the `mimic_icu` schema uses declarative partitioning, and thus the create.sql script creates many partitions for chartevents: chartevents_01, chartevents_02, ..., etc. Replacing these with a single create statement for chartevents will make the script compatible for older versions of PostgreSQL.

### Other

Please see the [issues page](https://github.com/MIT-LCP/mimic-code/issues) to discuss other issues you may be having.
