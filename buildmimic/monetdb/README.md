# Create MIMIC-III in a local MonetDB database

## Instructions for use

First ensure that MonetDB is running on your computer. For installation instructions, see: [https://www.monetdb.org/Documentation/Guide/Installation](https://www.monetdb.org/Documentation/Guide/Installation)

Once MonetDB is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory using the following command:

``` bash
$ git clone https://github.com/MIT-LCP/mimic-code.git
```

## GUI

DBeaver [http://dbeaver.jkiss.org/download/](download dbeaver) works great with monetDB. 

1. [https://www.monetdb.org/Documentation/Manuals/SQLreference/Programming/JDBC](Download JDBC driver for monetDB)
1. Open dbeaver>Database>Driver Manager>New>
  1. Driver Name = MonetDB
  1. Class Name = nl.cwi.monetdb.jdbc.MonetDriver
  1. Driver Type = Generic
  1. Default Port = 50000
  1. Library>Add> choose the JDBC driver jar previously downloaded
  1. Validate
1. File>New>Choose MonetDB
  1. Fill JDBC URL =  jdbc:monetdb://localhost:50000/mimic
  1. Fill user/password (The default username/password is monetdb/monetdb)
  1. Validate

## Install Mimic Data

``` bash
$ monetdbd create /path/you/want/to/store/your/monetdbdata
$ monetdbd start /path/you/want/to/store/your/monetdbdata
$ monetdb create mimic
$ monetdb start mimic
```

In DBeaver, connect and copy/paste:
1. monetdb_create_tables.sql
1. monetdb_load_data.sql

## Notes

* there is no need to add indexes, monetdb indexes itself after loading
* there are some issues with mimic v1.3 backslashes in tables chartevents & noteevents. For now, removing them thanks to `sed -i 's/\\/g' table.csv` is a workaround.
