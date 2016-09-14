
## Introduction to the build system

The build system for mimic code uses the GNU Makefile system. From a user's point of view this makes the whole process very straightforward: in order to import data they may run "make mimic DATADIR=/path" and in order to build all of the community contributed views and tables they may simply run "make extra".

```
# Import data from .csv files
make mimic DATADIR=/path/to/data

# Alternative to import data using .csv.gz files
make mimic-gz DATADIR=/path/to/data

# Import user contributed scripts
make extra
```

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
From a contributor's point of view this places an additional (and hopefully very minor) burden to ensure that their views are included in this build system. The top-level Makefile (i.e. the one in the root of this repository) is mostly a wrapper that calls each of the various subdirectorys' own Makefiles; running "make extra" will change directory to etc, run "make etc", which changes directory to "etc/firstday" and runs "make firstday" and so on. This also tells you which Makefile you need to modify: it's the one in the same directory as your script.

You do not have to specifically tell the Makefile how to build your SQL script: this is handled by an "implicit rule" that covers all SQL files. You do have to tell Makefile that there's an SQL script there to be built though. This is achieved by adding the name of the file (without the .sql extension) to the "extra" build target.

### clean.sql
Do not call "DROP MATERIALIZED VIEW" or "DROP TABLE" from within your contributed SQL script. This is a specific requirement to ensure that make can build its dependencies quickly. Instead add a "DROP ..." command to the shared clean.sql in that subdirectory. This is there for when "make clean" is run.

