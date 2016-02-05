# Create MIMIC-III in a local apache-Drill query engine (standalone mode)

## Instructions for use

For installation instructions, see: [https://drill.apache.org/docs/installing-drill-in-embedded-mode](https://drill.apache.org/docs/installing-drill-in-embedded-mode/)

Once drill is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory using the following command:

``` bash
$ git clone https://github.com/MIT-LCP/mimic-code.git
```

## GUI

DBeaver [http://dbeaver.jkiss.org/download/](download dbeaver) works great with Drill. 

1. File>New>Choose Drill
  1. Fill JDBC URL =  jdbc:drill:drillbit=localhost:31010
  1. Host = localhost
  1. Port = 31010

## Install Mimic Data

Run drill:

``` bash
$ cd /path/to/drill
$ bin/drill-embedded
```

Configure Drill:

Default install has 2 problems: i) is it has a default storage in temporary folder => when reboot, data are lost ii) csv format does not use header by default.
Let's configure it.

1. edit /path/to/drill/conf/drill-override.conf
  1. it should look like : 
```
drill.exec: {
  cluster-id: "drillbits1",
  zk.connect: "localhost:2181",
  sys.store.provider: {
class: "org.apache.drill.exec.store.sys.zk.ZkPStoreProvider",
        zk: {
blobroot: "file:///var/log/drill"
        },
local: {
path: "/path/to/drilldata/",
      write: true
       }
  }
}
```
1. edit /path/to/drill/conf/drill-env-sh add ``` -Duser.timezone=UT ``` to DRILL_JAVA_OPTS in order understand mimic dates formats
1. You can specify the maximum memory there too thanks to DRILL_MAX_DIRECT_MEMORY
1. restart drill (ctrl + d) in the console where drill was started; then restart it as described before. 
1. go to http://localhost:8047/
1. go to onglet "storage" and update "dfs"
1. add a mimiciii (path you want to save drill table as parquet files) location after the tmp location:   `"tmp" : { "location" : "/tmp", "writable" : true, "defaultInputFormat" : null }, "mimiciii" : { "location" : "/path/to/drilldata", "writable" : true, "defaultInputFormat" : null }`
1. make sure "csv" section has extractHeader:  `"csv" : { "type" : "text", "extensions" : [ "csv" ], "extractHeader" : true, "delimiter" : "," }`
1. validate

## Create/Load the table/data

In DBeaver, connect and copy/paste:

1. drill_create_data.sql
1. create alias for all csv in temp (dfs.tmp = /tmp on linux) ln -s /path/to/mimic/csv/\* /tmp 
1. create table one by one. Otherwize, it crashes when multi query are made in one run

## Notes

* NOTEEVENTS : To be loaded there is two fixes:
  * Drill does not accept newlines in text fields (it actually splits csv based on newlines to parallelize reading processes)then replace \n with `<b>` by example or remove them before loading the csv
  * Drill has a bug when a double quote is the last character of a text field. Row_ID 387846, 982481, 1008470, 1036580 has in there DESCRIPTION field such case. Remove it and drill will be able to load NOTEEVENTS
  * For now, Drill does not have a regex operator(not a ANSI SQL). However it exists a function that cover this needs at : https://github.com/parisni/drill-simple-contains 
* Example of query: SELECT * FROM dfs.mimiciii.`CHARTEVENTS` LIMIT 10;


# Create MIMIC-III in a local apache-Drill query engine (distributed mode)

to be done
