
## Introduction to the build system

The build system for mimic code uses the GNU Makefile system. From a user's point of view this makes the whole process very straightforward.
Starting from a fresh system which has both GNU Make installed, PostgreSQL installed, and a local copy of this repository, an instance of the MIMIC database can be imported from PhysioNet by running the following:

```
make mimic-download
make mimic-gz DATADIR=/path/to/data
```

Note that if you have already downloaded the data, you can skip the `make mimic-download`. If you have already decompressed the data into `.csv` files, then you can run `make mimic DATADIR=/path/to/data`.

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

### Non-standard username or database name
If you need to use a username or database name other than ```mimic```, then you will need to specify this by modifying the top-level Makefile:

```
DBNAME=mimic
DBUSER=mimic
```

## Contributing
If you would like to contribute code to create a materialized view to the `concepts` folder, the existence of this makefile places an additional (and hopefully very minor) burden to ensure that your views are included in this build system. The top-level Makefile (i.e. the one in the root of this repository) is a wrapper that calls `concepts/make-concepts.sql`: simply add a command which calls the script to this file. The format is fairly straightforward: e.g. adding the `\i sepsis/angus.sql` line informs the script to call the `concepts/sepsis/angus.sql` file.
