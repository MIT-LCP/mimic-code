# Create MIMIC-III in a local MonetDB database

## Instructions for use

First ensure that MonetDB is running on your computer. For installation instructions, see: [https://www.monetdb.org/Documentation/Guide/Installation](https://www.monetdb.org/Documentation/Guide/Installation)

Once MonetDB is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory using the following command:

``` bash
$ git clone https://github.com/MIT-LCP/mimic-code.git
```

## GUI

DBeaver works great with monetDB. Download and install it from here: [http://dbeaver.jkiss.org/download/](download dbeaver).

1. [https://www.monetdb.org/Documentation/Manuals/SQLreference/Programming/JDBC](Download JDBC driver for monetDB)
    * Under the "Getting the driver Jar" header, click "download area" to find the latest JDBC drivers
    * Download the monetdb-\*.jar file somewhere memorable
1. Open dbeaver>Database>Driver Manager>New>
  1. Driver Name = MonetDB
  1. Class Name = nl.cwi.monetdb.jdbc.MonetDriver
  1. Driver Type = Generic
  1. Default Port = 50000
  1. Library>Add> choose the JDBC driver jar previously downloaded
  1. Click OK - MonetDB should now appear in the list
  1. Close the window
1. File>New>Connection>MonetDB
  1. Fill JDBC URL =  jdbc:monetdb://localhost:50000/mimic
  1. Fill user/password (The default username/password is monetdb/monetdb)
  1. Click "Next"
  1. You don't need an SSH tunnel.. click "next" again
  1. Click "Finish"

## Install Mimic Data

Note that the Windows instructions require the data to be unzipped, but the *nix instructions allow you to build from zipped data. It is possible to import the data on Windows when it is compressed, but 


### Windows

(Optional) These instructions require uncompressing the data. In principle it is possible to install the data directly from the compressed files. First you must install a command line tool which can unzip data and add it to your environment path in command prompt (good examples include 7zip or GnuWin32 gzip). After that you'll need to create a .bat script to use the command line tool, e.g.:

`mclient -d mimic -s "COPY INTO MIMICIII.ADMISSIONS FROM STDIN USING DELIMITERS ',','\n','\"' NULL AS ''" - < gzip -dck /path/to/ADMISSIONS.csv.gz`

You'll also need to add an appropriate fix for CHARTEVENTS and NOTEEVENTS that escapes backslashes with an extra backslash (see `monetdb_load_data.sh`).

(Optional) You may want to change where MonetDB stores the data, which is accomplished by modifying the .bat files directly. Open up WordPad by right clicking and selecting "Run as Administrator" (needed in order to edit the .bat file). Open up M5server.bat, and add the following after `:skipuservar`:

```bash
rem ------- Change DB path ---------
rem We move the database directory to a local folder
set MONETDBDIR=C:\\path\\you\\want
set MONETDBFARM="--dbpath=%MONETDBDIR%\dbfarm\demo"
```

After changing the db path (or not), you can launch MonetDB by running Start -> Programs -> MonetDB5 -> MonetDB Server. Another option is calling the bat file directly from command prompt or powershell, as follows:

```sh
.\\M5server.bat --dbpath=/path/you/want/to/store/your/monetdbdata --daemon=yes
```

Once the server is launched, open up DBeaver.

1. Right click the connection, click "Edit Connection"
2. Change the URL to jdbc:monetdb://localhost:50000/demo
    * I haven't figured out how to make MonetDB serve a different database
3. Connect to the database
4. Open `monetdb_create_tables.sql` (SQL Editor -> Load SQL script or Ctrl+O ), execute the script
5. Open `monetdb_load_data.sql`, **modify the path used to load the data**
6. Execute the script

### \*nix systems

``` bash
$ monetdbd create /path/you/want/to/store/your/monetdbdata
$ monetdbd start /path/you/want/to/store/your/monetdbdata
$ monetdb create mimic
$ monetdb start mimic
```


1. Copy both `monetdb_create_tables.sql` \& `monetdb_load_data.sh` into the mimic compressed files directory
1. Go in that folder
1. Create a `.monetdb` file containing:
```
user=monetdb
password=monetdb
```
1. Run `mclient -d mimic < monetdb_create_tables.sql`
1. Execute `monetdb_load_data.sh`

## Notes

* there is no need to add indexes, monetdb indexes itself after loading
* monetDB has issues importing backslashes in tables chartevents & noteevents. For now, escaping them thanks to `sed -i 's/\\/\\\\/g' table.csv` is a workaround.
