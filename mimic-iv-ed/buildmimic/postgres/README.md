# Load MIMIC-IV-ED into a PostgreSQL database

The scripts in this folder create the schema for MIMIC-IV-ED and load the data into the appropriate tables for PostgreSQL v10+.
If you are having trouble, take a look at the common issues in the FAQ at the bottom of this page.

## Quickstart

```sh
# clone repo
git clone https://github.com/MIT-LCP/mimic-code.git
cd mimic-code
# download data
wget -r -N -c -np --user <USERNAME> --ask-password https://physionet.org/files/mimic-iv-ed/2.2/
mv physionet.org/files/mimiciv-iv-ed mimiciv && rmdir physionet.org/files && rm physionet.org/robots.txt && rmdir physionet.org
# if mimiciv not exists
# createdb mimiciv
psql -d mimiciv -f mimic-iv-ed/buildmimic/postgres/create.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=mimiciv/2.2/ed -f load_gz.sql
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

Finally, loading the data into this data requires specifying the database name with `-d mimic` again:

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

### Other

Please see the [issues page](https://github.com/MIT-LCP/mimic-code/issues) to discuss other issues you may be having.
