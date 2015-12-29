# Create MIMIC-III in a local Postgres database

## Instructions for use

First ensure that Postgres is running on your computer. For installation instructions, see: [http://www.postgresql.org/docs/current/static/tutorial-install.html](http://www.postgresql.org/docs/current/static/tutorial-install.html)

Once Postgres is installed, clone the [mimic-code](https://github.com/MIT-LCP/mimic-code) repository into a local directory, using the following command:

``` bash
git clone https://github.com/MIT-LCP/mimic-code.git
```

Change to the ``` buildmimic/postgres/``` directory and use ```make``` to run the Makefile, which contains instructions for creating MIMIC in a local Postgres database. To get instructions for using the Makefile, run the following command:

``` bash
make help
```

For example, to create MIMIC from a set of zipped CSV files in the "/path/to/data/" directory, run the following command:

``` bash
make mimic datadir="/path/to/data/"    
```
