# Load MIMIC-IV-Note into a PostgreSQL database

The scripts in this folder create the schema for MIMIC-IV-Note and load the data into the appropriate tables for PostgreSQL v10+.

## Quickstart

```sh
# clone repo
git clone https://github.com/MIT-LCP/mimic-code.git
cd mimic-code
# download data
wget -r -N -c -np --user <USERNAME> --ask-password https://physionet.org/files/mimic-iv-note/2.2/
mv physionet.org/files/mimic-iv-note/ mimic-iv-note && rmdir physionet.org/files && rm physionet.org/robots.txt && rmdir physionet.org
# if mimic-iv-note not exists
# createdb mimiciv_note
psql -d mimiciv_note -f mimic-iv-note/buildmimic/postgres/create.sql
psql -d mimiciv_note -v ON_ERROR_STOP=1 -v mimic_data_dir=mimiciv-iv-note/2.2/note -f mimic-iv-note/buildmimic/postgres/load_gz.sql
```
