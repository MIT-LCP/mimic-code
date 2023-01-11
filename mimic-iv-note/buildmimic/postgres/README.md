# Load MIMIC-IV-Note into a PostgreSQL database

The scripts in this folder create the schema for MIMIC-IV-Note and load the data into the appropriate tables for PostgreSQL v10+.

## Quickstart

```sh
# clone repo
git clone https://github.com/MIT-LCP/mimic-code.git
cd mimic-code
# download data
wget -r -N -c -np --user <USERNAME> --ask-password https://physionet.org/files/mimiciv/2.2/
mv physionet.org/files/mimiciv mimiciv && rmdir physionet.org/files && rm physionet.org/robots.txt && rmdir physionet.org
# if mimiciv not exists
# createdb mimiciv
psql -d mimiciv -f mimic-iv-note/buildmimic/postgres/create.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=mimiciv/2.2 -f mimic-iv-note/buildmimic/postgres/load_gz.sql
```
