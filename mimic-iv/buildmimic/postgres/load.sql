-----------------------------------------
-- Load data into the MIMIC-IV schemas --
-----------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v mimic_data_dir=<PATH TO DATA DIR> -f load.sql
-- The script assumes the files are in the core, hosp, and icu subfolders of mimic_data_dir

\cd :mimic_data_dir

-- core schema
\cd core

\COPY mimic_core.admissions FROM admissions.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_core.patients FROM patients.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_core.transfers FROM transfers.csv DELIMITER ',' CSV HEADER NULL '';

-- hosp schema
\cd ../hosp

\COPY mimic_hosp.d_hcpcs FROM d_hcpcs.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.diagnoses_icd FROM diagnoses_icd.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_icd_diagnoses FROM d_icd_diagnoses.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_icd_procedures FROM d_icd_procedures.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.d_labitems FROM d_labitems.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.drgcodes FROM drgcodes.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.emar_detail FROM emar_detail.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.emar FROM emar.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.hcpcsevents FROM hcpcsevents.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.labevents FROM labevents.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.microbiologyevents FROM microbiologyevents.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.pharmacy FROM pharmacy.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe_detail FROM poe_detail.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe FROM poe.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.prescriptions FROM prescriptions.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.procedures_icd FROM procedures_icd.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.services FROM services.csv DELIMITER ',' CSV HEADER NULL '';

-- icu schema
\cd ../icu

\COPY mimic_icu.chartevents FROM chartevents.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.datetimeevents FROM datetimeevents.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.d_items FROM d_items.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.icustays FROM icustays.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.inputevents FROM inputevents.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.outputevents FROM outputevents.csv DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.procedureevents FROM procedureevents.csv DELIMITER ',' CSV HEADER NULL '';
