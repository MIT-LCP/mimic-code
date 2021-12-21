# MIMIC-IV

## Brief introduction

The repository consists of a number of Structured Query Language (SQL) scripts which build the MIMIC-IV database in a number of systems and extract useful concepts from the raw data. Subfolders include:

* [buildmimic](/mimic-iv/buildmimic) - Scripts to build MIMIC-IV in various relational database management system (RDMS), in particular [postgres](/buildmimic/postgres) is a popular open source option
* [concepts](/mimic-iv/concepts) - Useful views/summaries of the data in MIMIC-IV, e.g. demographics, organ failure scores, severity of illness scores, durations of treatment, easier to analyze views, etc. The paper above describes these in detail, and a README in the subfolder lists concepts generated.

### Concepts

The [MIMIC-IV concepts](/mimic-iv/concepts) are written in an SQL syntax compatible with BigQuery. These scripts have been converted to PostgreSQL by a script. To generate the concepts in PostgreSQL, see the [MIMIC-IV postgresql concepts subfolder](/mimic-iv/concepts/postgres).

Tables in the BigQuery `physionet-data.mimic_derived` dataset are generated using the concepts made available in this folder. These tables are generated using the code in the [latest release on GitHub](https://github.com/MIT-LCP/mimic-code/releases).
