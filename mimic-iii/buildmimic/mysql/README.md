# Building the MIMIC database with MySQL 

You should have MySQL installed. A user and database should be created for storing MIMIC databse.


## Step 1: Enable LOAD DATA LOCAL

By default, loading CSV file to MySQL is prohibited. The detailed instruction for enabling this feature is on:
https://dev.mysql.com/doc/refman/5.7/en/load-data-local.html

On the server side, you should use `--local_infile` and also add your folder to white list using `--secure-file-priv=CSV_FILE_DIR` to start mysql service



## Step 2: Import CSV

Copy all the .sql files to your MIMIC data directory, and `cd` to that directory.

Run `mysql` with parameter `--local_infile=1`, which enables loading CSV files from the client site.

Run `source ./1-define.sql`, `source ./2-index.sql` and `source 3-constraints.sql` to import
       
