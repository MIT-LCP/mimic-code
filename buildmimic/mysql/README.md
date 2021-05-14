# Using the MySQL load scripts to load the MIMIC-IV `csv` files into a MySQL database

These instructions accompany two load scripts to load the MIMIC-IV `csv` files into a MySQL database. This was tested using MySQL Community Server 8.0.19, but should work in earlier (or probably later) releases as well.

There are two load scripts:

* `load.sql` -- Contains table definitions and `LOAD DATA` statements to import the data.  The table definitions were created by the [`csv2mysql` tool](https://github.com/mit-medg/csv2mysql) that determines what MySQL data fields should correspond to each column of `csv` data. That output was then edited a bit.
  - The largest tables `chartevents` and `labevents` are partitioned to 50 partitions each, to speed up retrieval from them. The partition is by `hash(itemid)`.
  - The current version of MySQL considers `UTF8` to be a synonym for `UTF8MB3`, a maximum 3-byte encoding. However, using `UTF8` warns that this is planned to change to `UTF8MB4`, a maximum 4-byte encoding at some future time.  I don't believe the current data contain any characters that need such an extended encoding, but if international data become available, this might change.  You can edit `UTF8` to be either `UTF8MB3` or `UTF8MB4` to have explicit control over the length of encoding selected.
* `index.sql` -- Defines a number of indexes on the loaded tables.  I attempted to parallel the indexes that were recommended for the MIMIC-III data, though of course some tables and fields are different.  Generally, these include `UNIQUE INDEX`es for tables that define data for an item with a unique identifier, e.g., `hadm_id` for `admissions`. Large tables are also indexed by `subject_id` and related ids to support retrieval of all data about a specific patient and by `itemid` and various time stamps to support retrieval of population data of particular kinds. The right indexes to use should depend strongly on the applications to which the data are put, and this particular set is simply my guess about what might be useful.  Note that, on my MySQL version, the indexes defined here add about 46GB of MySQL storage to the 53GB taken up by the unindexed data.

## How to use

Assuming you have MySQL installed on your system, and your logged in user has administrative permissions for MySQL, I would recommend the following method of installation:

0. Make sure that `local-infile=1` is specified for the server, either in its configuration file or in the command line that starts it.
1. `gunzip` all of the distributed `.csv.gz` files and move them to a single directory.  (Unfortunately, there seems to be no direct way to `LOAD DATA` from `gzip` files in MySQL.)
2. Move the `load.sql` and `index.sql` files to the same directory.
3. `cd` to that directory.
4. Create the MIMIC-IV database (you can obviously call it anything you like, but I will use `mimic4`):
> `mysql -p -e "create database mimic4"`
5. Run the two script files:
> `mysql -p --local-infile mimic4 < load.sql > load.log`

> `mysql -p mimic4 < index.sql > index.log`

The `-p` option will prompt for your MySQL password. You can omit this if no password is needed in your installation.

6. Be patient. On a 2019 iMac Core i9, with 8-cores, lots of RAM, and MySQL's data on a Thunderbolt-3 connected NVMe drive, `load.sql` took 93 minutes, and `index.sql` took 59 minutes. These times would be much longer if loading data to a spinning drive. The MySQL server processes these scripts sequentially, so it would probably be relatively easy to speed up the process on a multi-core machine by splitting the scripts and running them in parallel, because the MySQL server is multi-threaded. (Obviously, the indexing would have to happen after the loading.)  I have not tried this, so I am unsure how much time it might save.

