
## Introduction to the build system

The build system for mimic code uses the GNU Makefile system. From a user's point of view this makes the whole process very straightforward. Note that the make system is only available for a PostgreSQL database build.

Starting from a fresh system which has GNU Make installed, PostgreSQL installed, and a local copy of this repository, an instance of the MIMIC database can be imported from PhysioNet by running the following from the `buildmimic/postgres` subdirectory:

```sh
export datadir="/path/to/data"
make mimic-download physionetuser=<PHYSIONETWORKS_USERNAME> datadir=$datadir
make mimic-gz datadir=$datadir
```

Note that if you have already downloaded the data, you can skip the `make mimic-download`, just be sure to set `datadir` appropriately. If you have already decompressed the data into `.csv` files, call `make mimic` instead of `make mimic-gz`, e.g. `make mimic datadir=/path/to/data`.

Optionally, additional contributed materialized views can be created afterward by running:

```
make concepts
```

Note that you may want to modify parameters at the top of the Makefile - e.g. the username (see below "non-standard username or database name").

### Authentication
In order to avoid the prompts for your database password each time, you may create a file in your home directory called .pgpass containing the following:

```
localhost:5432:*:mimic:password
```

Replace ```mimic``` with your username and ```password``` with your password. Note that this is storage of your database password in the clear and so we would recommend only doing this for installation.

Alternatively you can configure the database to use operating system level authentication. See the Postgres manual for more detail (in particular, the section(s) on "Peer Authentication"): https://www.postgresql.org/docs/9.6/static/auth-methods.html

### Non-standard username or database name
If you need to use a username or database name other than ```mimic```, then you will need to specify this by modifying the top-level Makefile:

```
DBNAME=mimic
DBUSER=mimic
```

## Contributing
If you would like to contribute code to create a materialized view to the `concepts` folder, simply add a command which calls the script to the `concepts/make-concepts.sql` file. The format is fairly straightforward: e.g. adding the `\i sepsis/angus.sql` line informs the script to call the `concepts/sepsis/angus.sql` file.
