-----------------------------------------
-- Load data into the MIMIC-IV schemas --
-----------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v mimic_data_dir=<PATH TO DATA DIR> -f load_gz.sql

-- core schema
\cd :mimic_data_dir/core

-- making sure that all tables are emtpy and correct encoding is defined -utf8- 
SET CLIENT_ENCODING TO 'utf8';

DELETE FROM mimic_core.admissions; 
DELETE FROM mimic_core.patients; 
DELETE FROM mimic_core.transfers;
DELETE FROM mimic_hosp.d_hcpcs;
DELETE FROM mimic_hosp.diagnoses_icd;
DELETE FROM mimic_hosp.d_icd_diagnoses;
DELETE FROM mimic_hosp.d_icd_procedures;
DELETE FROM mimic_hosp.d_labitems; 
DELETE FROM mimic_hosp.drgcodes;
DELETE FROM mimic_hosp.emar_detail;
DELETE FROM mimic_hosp.emar;
DELETE FROM mimic_hosp.hcpcsevents;
DELETE FROM mimic_hosp.labevents;
DELETE FROM mimic_hosp.microbiologyevents;
DELETE FROM mimic_hosp.pharmacy;
DELETE FROM mimic_hosp.poe_detail; 
DELETE FROM mimic_hosp.poe;
DELETE FROM mimic_hosp.prescriptions;
DELETE FROM mimic_hosp.procedures_icd;
DELETE FROM mimic_hosp.services;
DELETE FROM mimic_icu.chartevents;
DELETE FROM mimic_icu.datetimeevents;
DELETE FROM mimic_icu.d_items;
DELETE FROM mimic_icu.icustays;
DELETE FROM mimic_icu.inputevents;
DELETE FROM mimic_icu.outputevents;
DELETE FROM mimic_icu.procedureevents;


\COPY mimic_core.admissions FROM PROGRAM '7z e -so admissions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_core.patients FROM PROGRAM '7z e -so patients.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_core.transfers FROM PROGRAM '7z e -so transfers.csv.gz' DELIMITER ',' CSV HEADER NULL '';

-- hosp schema
\cd ../hosp

\COPY mimic_hosp.d_hcpcs FROM PROGRAM '7z e -so d_hcpcs.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.diagnoses_icd FROM PROGRAM '7z e -so diagnoses_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_icd_diagnoses FROM PROGRAM '7z e -so d_icd_diagnoses.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_icd_procedures FROM PROGRAM '7z e -so d_icd_procedures.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_labitems FROM PROGRAM '7z e -so d_labitems.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.drgcodes FROM PROGRAM '7z e -so drgcodes.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.emar_detail FROM PROGRAM '7z e -so emar_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.emar FROM PROGRAM '7z e -so emar.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.hcpcsevents FROM PROGRAM '7z e -so hcpcsevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.labevents FROM PROGRAM '7z e -so labevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.microbiologyevents FROM PROGRAM '7z e -so microbiologyevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.pharmacy FROM PROGRAM '7z e -so pharmacy.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe_detail FROM PROGRAM '7z e -so poe_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe FROM PROGRAM '7z e -so poe.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.prescriptions FROM PROGRAM '7z e -so prescriptions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.procedures_icd FROM PROGRAM '7z e -so procedures_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.services FROM PROGRAM '7z e -so services.csv.gz' DELIMITER ',' CSV HEADER NULL '';

-- icu schema
\cd ../icu

\COPY mimic_icu.chartevents FROM PROGRAM '7z e -so chartevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.datetimeevents FROM PROGRAM '7z e -so datetimeevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.d_items FROM PROGRAM '7z e -so d_items.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.icustays FROM PROGRAM '7z e -so icustays.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.inputevents FROM PROGRAM '7z e -so inputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.outputevents FROM PROGRAM '7z e -so outputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.procedureevents FROM PROGRAM '7z e -so procedureevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
