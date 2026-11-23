# Load NWICU into a PostgreSQL database

This directory contains scripts to create the schema and load the Northwestern ICU and Hospital data (NWICU) into PostgreSQL, following a structure similar to the MIMIC-IV build scripts.

## Quickstart

```sh
# clone repo
git clone https://github.com/MIT-LCP/mimic-code.git
cd mimic-code

# download NWICU data
wget -r -N -c -np --user <USERNAME> --ask-password https://physionet.org/files/nwicu-northwestern-icu/0.1.0/
# clean directory (run this command outside of physionet.org directory)
mv physionet.org/files/nwicu-northwestern-icu nwicu && rmdir physionet.org/files && rm physionet.org/robots.txt && rmdir physionet.org

# create database
createdb nw

# build and load NWICU tables
psql -d nw -f nw/buildnw/postgres/create.sql
psql -d nw -v ON_ERROR_STOP=1 -v nw_data_dir=nwicu/0.1.0 -f nw/buildnw postgres/load_gz.sql
psql -d nw -f nw/buildnw/postgres/constraint.sql
psql -d nw -f nw/buildnw/postgres/index.sql
psql -d nw -f nw/buildnw/postgres/validate.sql
```

## Detailed guide

First ensure that PostgreSQL is running on your computer. For installation instructions, see: [http://www.postgresql.org/download/](http://www.postgresql.org/download/)

### Install PostgreSQL

**On macOS (using Homebrew):**

```sh
brew update 
brew install postgresql
brew services start postgresql
```

To check which user is running the PostgreSQL service, use:

```sh
brew services list
```

The 'User' column shows the macOS account running PostgreSQL. This is usually the username you should use for database connections unless you have created a different PostgreSQL user.

**On Ubuntu/Debian:**

```sh
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo service postgresql start
```

**On Windows:**

1. Download the installer from https://www.postgresql.org/download/windows/
2. Run the installer and follow the prompts to complete the installation.
3. Start the PostgreSQL service from the Start Menu or Services app.

For more details, see the [official PostgreSQL download page](https://www.postgresql.org/download/).

### Download NWICU data

We can download Northwestern ICU (NWICU) database
from [PhysioNet](https://physionet.org/content/nwicu-northwestern-icu/0.1.0/):

```sh
wget -r -N -c -np --user <USERNAME> --ask-password https://physionet.org/files/nwicu-northwestern-icu/0.1.0/
mv physionet.org/files/nwicu-northwestern-icu nwicu && rmdir physionet.org/files && rm physionet.org/robots.txt && rmdir physionet.org
```

### Specify a database for installation

Create the database if it does not already exist:

```sh
createdb nw
```

Set PostgreSQL environment variables:

We can use the provided script to set your environment variables for the current terminal session:

```sh
source postgres_env.sh
```

Replace `your_user` and `your_password` with your actual PostgreSQL username and password in sh script.

Instead of editing the script, you can pass your username and password as arguments:

```sh
source postgres_env.sh myuser mypassword nw localhost 5432
```

Once Postgres is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory. 

``` bash
git clone https://github.com/MIT-LCP/mimic-code.git
```

Create the schemas and tables with the following psql command. **This will delete any data present in the schemas.** If you need to reload the data (for example, if you run the load scripts multiple times), simply rerun create.sql.
This will drop all existing tables and recreate them, ensuring a clean slate before reloading your data.

```sh
psql -d nw -f nw/buildnw/postgres/create.sql
```

Afterwards, we need to load the NWICU files into the database. To do so, we'll specify the location of the local CSV files (compressed).
Note that this assumes the folder structure is as follows:

```
nwicu_data_dir
	nw_hosp
		admissions.csv.gz
		patients.csv.gz
		...
	nw_icu
		icustays.csv.gz
		...
```

For example, if you downloaded and moved the files as above, your `nwicu_data_dir` would be `nwicu/0.1.0` and contain subfolders like `nw_hosp` and `nw_icu` with their respective compressed CSV files.

Once you have verified your data is stored in this structure, run:

```sh
psql -d nw -v ON_ERROR_STOP=1 -v nw_data_dir=nwicu/0.1.0 -f nw/buildnw/postgres/load_gz.sql
```

After loading the data, we can enforce data integrity by adding primary keys, foreign keys, and other constraints.

```sh
psql -d nw -f nw/buildnw/postgres/constraint.sql
```

We can also improve query performance by creating indexes, which allow the database to quickly find and retrieve data, especially in large tables.

```sh
psql -d nw -f nw/buildnw/postgres/index.sql
```

To ensure the data was loaded correctly, we can run validation checks.

```sh
psql -d nw -f nw/buildnw/postgres/validate.sql
```
