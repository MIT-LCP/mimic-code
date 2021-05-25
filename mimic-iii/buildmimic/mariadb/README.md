# Building the MIMIC database with MariaDB 

You should have XAMPP installed. A user and database should be created for storing MIMIC databse.


## Step 1: LOAD DATA WITH SQL

### Enable LOAD DATA LOCAL(Optional)
By default, loading CSV file to MySQL is prohibited. The detailed instruction for enabling this feature is on:
https://dev.mysql.com/doc/refman/5.7/en/load-data-local.html
On the server side, you should use `--local_infile` and also add your folder to white list using `--secure-file-priv=CSV_FILE_DIR` to start mysql service

#### using XAMPP Customize SQL import file with 1-define.sql
To avoid the situation which cannot import with `LOAD DATA LOCAL` in XAMPP and the specific encode, we do the customize with it.
This customize can do the right import by without changing system environment.
PLZ put the mimic file under C:\xampp\mysql\data

## Step 2: Import CSV

Copy all the .sql files to your MIMIC data directory, and `cd` to that directory.
Run `source ./1-define.sql`, `source ./2-index.sql` and `source 3-constraints.sql` to import
Example:
- cd in C:\xampp\mysql\bin
- mysql -u root -p -pmysql mimiciiiv14 < C:\Users\_\Documents\Project\Python\Datasets\mimiciii\1.4\1-define.sql
- mysql -u root -p -pmysql mimiciiiv14 < C:\Users\_\Documents\Project\Python\Datasets\mimiciii\1.4\2-index.sql
- mysql -u root -p -pmysql mimiciiiv14 < C:\Users\_\Documents\Project\Python\Datasets\mimiciii\1.4\3-constraints.sql

