--------------------------------------
-- Load data into the NW schemas --
--------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v nw_data_dir=<PATH TO DATA DIR> -f load_gz.sql
\cd :nw_data_dir

-- making sure that all tables are empty and correct encoding is defined -utf8-
SET CLIENT_ENCODING TO 'utf8';

-- hosp schema
\cd nw_hosp

\COPY nw_hosp.admissions FROM PROGRAM 'gzip -dc admissions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_hosp.patients FROM PROGRAM 'gzip -dc patients.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_hosp.d_icd_diagnoses FROM PROGRAM 'gzip -dc d_icd_diagnoses.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_hosp.d_labitems FROM PROGRAM 'gzip -dc d_labitems.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_hosp.diagnoses_icd FROM PROGRAM 'gzip -dc diagnoses_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_hosp.emar FROM PROGRAM 'gzip -dc emar.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_hosp.labevents FROM PROGRAM 'gzip -dc labevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_hosp.prescriptions FROM PROGRAM 'gzip -dc prescriptions.csv.gz' DELIMITER ',' CSV HEADER NULL '';

-- icu schema
\cd ../nw_icu

\COPY nw_icu.chartevents FROM PROGRAM 'gzip -dc chartevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_icu.d_items FROM PROGRAM 'gzip -dc d_items.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_icu.icustays FROM PROGRAM 'gzip -dc icustays.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY nw_icu.procedureevents FROM PROGRAM 'gzip -dc procedureevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
