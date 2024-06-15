-----------------------------------------
-- Load data into the MIMIC-IV schemas --
-----------------------------------------

SET CLIENT_ENCODING TO 'utf8';
\cd /data
\COPY mimiciv_hosp.admissions FROM PROGRAM 'gzip -dc admissions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.d_hcpcs FROM PROGRAM 'gzip -dc d_hcpcs.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.diagnoses_icd FROM PROGRAM 'gzip -dc diagnoses_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.d_icd_diagnoses FROM PROGRAM 'gzip -dc d_icd_diagnoses.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.d_icd_procedures FROM PROGRAM 'gzip -dc d_icd_procedures.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.d_labitems FROM PROGRAM 'gzip -dc d_labitems.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.drgcodes FROM PROGRAM 'gzip -dc drgcodes.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.emar_detail FROM PROGRAM 'gzip -dc emar_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.emar FROM PROGRAM 'gzip -dc emar.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.hcpcsevents FROM PROGRAM 'gzip -dc hcpcsevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.labevents FROM PROGRAM 'gzip -dc labevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.microbiologyevents FROM PROGRAM 'gzip -dc microbiologyevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.omr FROM PROGRAM 'gzip -dc omr.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.patients FROM PROGRAM 'gzip -dc patients.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.pharmacy FROM PROGRAM 'gzip -dc pharmacy.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.poe_detail FROM PROGRAM 'gzip -dc poe_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.poe FROM PROGRAM 'gzip -dc poe.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.prescriptions FROM PROGRAM 'gzip -dc prescriptions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.procedures_icd FROM PROGRAM 'gzip -dc procedures_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.provider FROM PROGRAM 'gzip -dc provider.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.services FROM PROGRAM 'gzip -dc services.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_hosp.transfers FROM PROGRAM 'gzip -dc transfers.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.caregiver FROM PROGRAM 'gzip -dc caregiver.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.chartevents FROM PROGRAM 'gzip -dc chartevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.datetimeevents FROM PROGRAM 'gzip -dc datetimeevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.d_items FROM PROGRAM 'gzip -dc d_items.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.icustays FROM PROGRAM 'gzip -dc icustays.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.ingredientevents FROM PROGRAM 'gzip -dc ingredientevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.inputevents FROM PROGRAM 'gzip -dc inputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.outputevents FROM PROGRAM 'gzip -dc outputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_icu.procedureevents FROM PROGRAM 'gzip -dc procedureevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
