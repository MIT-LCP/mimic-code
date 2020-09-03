-----------------------------------------
-- Load data into the MIMIC-IV schemas --
-----------------------------------------


-- core schema
\cd :mimic_data_dir/core

\COPY mimic_core.admissions FROM PROGRAM 'gzip -dc admissions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_core.patients FROM PROGRAM 'gzip -dc patients.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_core.transfers FROM PROGRAM 'gzip -dc transfers.csv.gz' DELIMITER ',' CSV HEADER NULL '';

-- hosp schema
\cd :mimic_data_dir/hosp

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
\COPY mimic_hosp.pharmacy FROM PROGRAM 'gzip -dc pharmacy.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe_detail FROM PROGRAM 'gzip -dc poe_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.poe FROM PROGRAM 'gzip -dc poe.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.prescriptions FROM PROGRAM 'gzip -dc prescriptions.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.procedures_icd FROM PROGRAM 'gzip -dc procedures_icd.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_hosp.services FROM PROGRAM 'gzip -dc services.csv.gz' DELIMITER ',' CSV HEADER NULL '';

-- icu schema
\cd :mimic_data_dir/icu

\COPY mimic_icu.chartevents FROM PROGRAM 'gzip -dc chartevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.datetimeevents FROM PROGRAM 'gzip -dc datetimeevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.d_items FROM PROGRAM 'gzip -dc d_items.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.icustays FROM PROGRAM 'gzip -dc icustays.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.inputevents FROM PROGRAM 'gzip -dc inputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.outputevents FROM PROGRAM 'gzip -dc outputevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimic_icu.procedureevents FROM PROGRAM 'gzip -dc procedureevents.csv.gz' DELIMITER ',' CSV HEADER NULL '';
