# Instructions for windows users

This guide will run through installing MIMIC on a Windows based system. The guide has been tested on Windows 7 and will include any necessary software that must be installed, including PostgreSQL. The process steps are:

1. Install PostgreSQL
2. (Optional) Install a command line program for extracting compressed files (allows you to directly import data from compressed files)
3. (Optional) Install Git (allows easy download of the mimic-code repository)
4. Launch the PostgreSQL shell and run the scripts to build, load, and check the data integrity

If you have experience automating install processes on Windows, we would greatly appreciate any contribution you have time for.

## Install PostgreSQL

Install PostgreSQL using the installer linked to here:
http://www.postgresql.org/download/windows/

Run through the entire install process. Keeping the defaults will work, but make note of your postgres password, as we will need this later to login to the database system. For convenience, one option is to keep the default username "postgres" and use the password "postgres".

## (Optional) Install a command line program to extract compressed files

It is convenient to install MIMIC directly from the compressed files, as they take up a large amount of space uncompressed. One method of doing this is to install a command line program which can extract compressed files - we can incorporate this program into the load process of PostgreSQL tables. If you would like to, you can skip this step by decompressing your files to a folder now (though note this will take some time).
Otherwise, you there are two programs which you could use: 7-zip or GNU gzip. 7-zip is a GNU LGPL licensed utility with good Windows integration. GNU gzip is a GPL licensed program which will be very familiar to GNU/Linux users. Once you have made your choice, install one of these utilities as follows:

If you are installing 7-zip:

* Go to ( http://www.7-zip.org )
* Click the download link at the top (you are likely using 64-bit Windows)
* Run through the installer (keeping all the defaults)
* If you changed the install path, then note it down. Otherwise, your executable path will be `C:\Program Files\7-zip`

If you are installing gzip:

* Go to http://gnuwin32.sourceforge.net/packages/gzip.htm
* Next to "Complete package, except sources", click the "Setup" button to download the installer
* Run through the installer (keeping all the defaults)
* If you changed the install path, then note it down. Otherwise, your executable path will be `C:\Program Files (x86)\GnuWin32\bin`

Now, we will need to add the program to our environment PATH variable. Briefly, the PATH variable tells Windows which folders to look in when it wants to run a program. Since we will later want to run these from the command line, we need to first tell Windows where they are. This process is the same for both 7-zip and gzip, though the exact path will differ.

* Click the start menu, right click Computer, and click Properties
    * (if you are on Windows 10, this may be different).
* Click `Advanced System Settings`
* Click `Environment Variables...`
* In the bottom box, scroll down until you see `Path`. Click `Path`, then click `Edit...`
* In the `Variable value:` box, add the path name to the end
    * The default for 7-zip is `C:\Program Files\7-zip`
    * The default for gzip is `C:\Program Files (x86)\GnuWin32\bin`
* Click `OK` on all the open windows.

Windows will now know where to look when extracting the data. It's sensible test it out first though. Click the start menu, and type `cmd`, then run the program `cmd`.

* If you installed 7-zip, type: `7z`
* If you installed gzip, type: `gzip --version`

This command should give you a bunch of information: if it says something like `7z not found` or `gzip not found` then there is a mistake in your install: one comman issue is a typographical error in the path text.



## Run SQL Shell (psql)

Launch the SQL shell.


You will receive many prompts for input at the SQL shell: you can simply hit "enter" without typing anything to insert the default for all these fields *except* the password: you will need to type in the password you specified during the install.

Run the following commands:

```sql
DROP DATABASE IF EXISTS mimic;
CREATE DATABASE mimic OWNER postgres;
```

If this is the first time you are installing MIMIC, the "DROP DATABASE" command will warn you that no database existed - this is expected behaviour.
We have now created the database `mimic`, owned by user `postgres`. For experienced users: these defaults are not required, and the subsequent load scripts will work regardless of what values you set, as long as you adjust the upcoming code appropriately. Ultimately, we will load the data into a `mimiciii` schema of whatever database we are connected to. The rest of this document will assume the default values are used, i.e. a database `mimic` owned by user `postgres`.

Now, connect to the `mimic` database.

```sql
\c mimic;
```

## Create the tables

Run the create tables script (note: this assumes that the create table script is in the current directory - if it is not, see below). This script creates the `mimiciii` schema and populates the schema with empty tables which will eventually store the data.

```sql
\i postgres_create_tables.sql
```

If you get the error `postgres_create_tables.sql: No such file or directory` that means that the file `postgres_create_tables.sql` is not in your current directory. Specify the path to the file. In my case, I wrote:

```sql
\i D:/work/mimic-code/buildmimic/postgres/postgres_create_tables.sql
```

If you see a lot of "NOTICE: table does not exist" don't worry, that's normal. The script tries to delete the table before it creates it.

## Prepare to load the data into the tables

First, let's prepare to load the data by specifying running a few commands:

```sql
\set ON_ERROR_STOP 1
SET search_path TO mimiciii;
```

The first command above tells the script to stop execution upon any error: we'd rather stop at an error so we know that our database has not loaded fully. The second command informs the program that our tables are located on the `mimiciii` schema (this schema was created in `postgres_create_tables.sql`)

Next we will specify the location of our data. You'll likely need to change this to where you store your MIMIC data.

```sql
\set mimic_data_dir 'D:/mimic/v1_3'
```

## Load the data into the tables

Depending on your configuration, you now have three options for loading the data.

* If you have uncompressed data files (i.e. your data folder is full of `.csv` files), run the basic load script: `\i postgres_load_data.sql`
* If you have compressed data files, and installed 7-zip, run the 7-zip load script: `\i postgres_load_data_7zip.sql`
* If you have compressed data files, and installed gzip, run the gzip load script: `\i postgres_load_data_gz.sql`

You should now see that the row copying process has begun. Be aware that this can take some time, as there are almost 500 million rows in the entire database.

## (Optional but recommended) Build indexes

Indexes are needed to make the data more performant. Run the index script as follows:

```sql
\i postgres_add_indexes.sql
```

## Check the data works

Finally, verify that the data works by running the check script, which validates the row count against what we expect:

```sql
\i postgres_checks.sql
```

If all the tests pass, congratulations, you are ready to begin querying MIMIC!
