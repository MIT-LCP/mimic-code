# Load MIMIC-IV-Note into a PostgreSQL database

The scripts in this folder create the schema for MIMIC-IV-Note and load the data into the appropriate tables for PostgreSQL v10+.

## Quickstart

```sh
# clone repo
git clone https://github.com/MIT-LCP/mimic-code.git
cd mimic-code
# download data
wget -r -N -c -np --user <USERNAME> --ask-password https://physionet.org/files/mimic-iv-note/2.2/
mv physionet.org/files/mimic-iv-note mimic-iv && rmdir physionet.org/files && rm physionet.org/robots.txt && rmdir physionet.org
# if mimiciv not exists
# createdb mimiciv
psql -d mimiciv -f mimic-iv-note/buildmimic/postgres/create.sql
psql -d mimiciv -v ON_ERROR_STOP=1 -v mimic_data_dir=mimic-iv/mimic-iv-note/2.2/note -f mimic-iv-note/buildmimic/postgres/load_gz.sql
# if you want to remove raw data
# rm mimic-iv/mimic-iv-note/*.txt && rm mimic-iv/mimic-iv-note/index.html && rm mimic-iv/mimic-iv-note/note/*.gz && rm mimic-iv/mimic-iv-note/note/index.html && rmdir rm mimic-iv/mimic-iv-note/note && rmdir mimic-iv/mimic-iv-note
```
