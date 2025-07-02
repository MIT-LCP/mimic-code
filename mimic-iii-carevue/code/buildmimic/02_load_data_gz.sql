-- -------------------------------------------------------------------------------
--
-- Load data into the MIMIC-III CareVue
--
-- -------------------------------------------------------------------------------

-- Change to the directory containing the data files
\cd :mimic_data_dir
\cd ./mimic-iii-clinical-database-carevue-subset-1.4

--------------------------------------------------------
--  Load Data for Table ADMISSIONS
--------------------------------------------------------

\copy ADMISSIONS FROM PROGRAM 'gzip -dc ADMISSIONS.csv.gz' DELIMITER ',' CSV HEADER NULL ''

--------------------------------------------------------
--  Load Data for Table CALLOUT
--------------------------------------------------------

\copy CALLOUT from PROGRAM 'gzip -dc CALLOUT.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table CAREGIVERS
--------------------------------------------------------

\copy CAREGIVERS from PROGRAM 'gzip -dc CAREGIVERS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table CHARTEVENTS
--------------------------------------------------------

\copy CHARTEVENTS from PROGRAM 'gzip -dc CHARTEVENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table CPTEVENTS
--------------------------------------------------------

\copy CPTEVENTS from PROGRAM 'gzip -dc CPTEVENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table DATETIMEEVENTS
--------------------------------------------------------

\copy DATETIMEEVENTS from PROGRAM 'gzip -dc DATETIMEEVENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table DIAGNOSES_ICD
--------------------------------------------------------

\copy DIAGNOSES_ICD from PROGRAM 'gzip -dc DIAGNOSES_ICD.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table DRGCODES
--------------------------------------------------------

\copy DRGCODES from PROGRAM 'gzip -dc DRGCODES.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table D_CPT
--------------------------------------------------------

\copy D_CPT from PROGRAM 'gzip -dc D_CPT.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table D_ICD_DIAGNOSES
--------------------------------------------------------

\copy D_ICD_DIAGNOSES from PROGRAM 'gzip -dc D_ICD_DIAGNOSES.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table D_ICD_PROCEDURES
--------------------------------------------------------

\copy D_ICD_PROCEDURES from PROGRAM 'gzip -dc D_ICD_PROCEDURES.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table D_ITEMS
--------------------------------------------------------

\copy D_ITEMS from PROGRAM 'gzip -dc D_ITEMS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table D_LABITEMS
--------------------------------------------------------

\copy D_LABITEMS from PROGRAM 'gzip -dc D_LABITEMS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table ICUSTAYS
--------------------------------------------------------

\copy ICUSTAYS from PROGRAM 'gzip -dc ICUSTAYS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_CV
--------------------------------------------------------

\copy INPUTEVENTS_CV from PROGRAM 'gzip -dc INPUTEVENTS_CV.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table LABEVENTS
--------------------------------------------------------

\copy LABEVENTS from PROGRAM 'gzip -dc LABEVENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

\copy MICROBIOLOGYEVENTS from PROGRAM 'gzip -dc MICROBIOLOGYEVENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table NOTEEVENTS
--------------------------------------------------------

\copy NOTEEVENTS from PROGRAM 'gzip -dc NOTEEVENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table OUTPUTEVENTS
--------------------------------------------------------

\copy OUTPUTEVENTS from PROGRAM 'gzip -dc OUTPUTEVENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table PATIENTS
--------------------------------------------------------

\copy PATIENTS from PROGRAM 'gzip -dc PATIENTS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table PRESCRIPTIONS
--------------------------------------------------------

\copy PRESCRIPTIONS from PROGRAM 'gzip -dc PRESCRIPTIONS.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table PROCEDURES_ICD
--------------------------------------------------------

\copy PROCEDURES_ICD from PROGRAM 'gzip -dc PROCEDURES_ICD.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table SERVICES
--------------------------------------------------------

\copy SERVICES from PROGRAM 'gzip -dc SERVICES.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table TRANSFERS
--------------------------------------------------------

\copy TRANSFERS from PROGRAM 'gzip -dc TRANSFERS.csv.gz' delimiter ',' csv header NULL ''
