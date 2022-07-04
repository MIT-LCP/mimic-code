-----------------------------------------
-- Load data into the MIMIC-IV schemas --
-----------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v mimic_data_dir=<PATH TO DATA DIR> -f load_gz.sql

-- making sure that all tables are emtpy and correct encoding is defined -utf8- 
SET CLIENT_ENCODING TO 'utf8';

DELETE FROM mimic_hosp.admissions; 
DELETE FROM mimic_hosp.patients; 
DELETE FROM mimic_hosp.transfers;
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
DELETE FROM mimic_hosp.omr;
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
DELETE FROM mimic_icu.ingredientevents;
DELETE FROM mimic_icu.inputevents;
DELETE FROM mimic_icu.outputevents;
DELETE FROM mimic_icu.procedureevents;

-- hosp schema
\cd :mimic_data_dir/hosp

\COPY mimic_hosp.admissions FROM PROGRAM 'gzip -dc admissions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_hcpcs FROM PROGRAM 'gzip -dc d_hcpcs.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.diagnoses_icd FROM PROGRAM 'gzip -dc diagnoses_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_icd_diagnoses FROM PROGRAM 'gzip -dc d_icd_diagnoses.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_icd_procedures FROM PROGRAM 'gzip -dc d_icd_procedures.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_labitems FROM PROGRAM 'gzip -dc d_labitems.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.drgcodes FROM PROGRAM 'gzip -dc drgcodes.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.emar_detail FROM PROGRAM 'gzip -dc emar_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.emar FROM PROGRAM 'gzip -dc emar.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.hcpcsevents FROM PROGRAM 'gzip -dc hcpcsevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.labevents FROM PROGRAM 'gzip -dc labevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.microbiologyevents FROM PROGRAM 'gzip -dc microbiologyevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.omr FROM PROGRAM 'gzip -dc omr.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.patients FROM PROGRAM 'gzip -dc patients.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.pharmacy FROM PROGRAM 'gzip -dc pharmacy.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe_detail FROM PROGRAM 'gzip -dc poe_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe FROM PROGRAM 'gzip -dc poe.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.prescriptions FROM PROGRAM 'gzip -dc prescriptions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.procedures_icd FROM PROGRAM 'gzip -dc procedures_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.services FROM PROGRAM 'gzip -dc services.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.transfers FROM PROGRAM 'gzip -dc transfers.csv.gz' DELIMITER ',' CSV HEADER NULL '';

-- icu schema
\cd ../icu

\COPY mimic_icu.chartevents FROM PROGRAM 'gzip -dc chartevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.datetimeevents FROM PROGRAM 'gzip -dc datetimeevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.d_items FROM PROGRAM 'gzip -dc d_items.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.icustays FROM PROGRAM 'gzip -dc icustays.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.ingredientevents FROM PROGRAM 'gzip -dc ingredientevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.inputevents FROM PROGRAM 'gzip -dc inputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.outputevents FROM PROGRAM 'gzip -dc outputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.procedureevents FROM PROGRAM 'gzip -dc procedureevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
