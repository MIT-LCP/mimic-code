# duckdb concepts

This folder has SQL compatible with [DuckDB](https://duckdb.org/).
These concepts were generated automatically from the BigQuery SQL dialect using the [sqlglot](https://sqlglot.com/) package.
If you would like to contribute a correction, do not make it here. Instead, make your correction in the [concepts folder](/mimic-iv/concepts/) using the BigQuery SQL syntax.

See the [README](/mimic-iv/README.md) in the parent folder for more information.

## Using these concepts

The `duckdb.sql` file calls all the concepts in the correct order and outputs them to the `mimiciv_derived` schema.
You should connect to your DuckDB database file and run this file (make sure you are in this folder, as the paths are relative):

```sh
.read duckdb.sql
```