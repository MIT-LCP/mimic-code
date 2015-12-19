-- -------------------------------------------------------------------------------
--
-- Load data into the MIMIC-III schema
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Thursday-August-27-2015
--------------------------------------------------------

-- Set the correct path to data files before running script.

-- Create the database and schema
/*MIMIC user creation moved to create_mimic_user.sh*/
/*
CREATE USER MIMIC;
CREATE DATABASE MIMIC OWNER MIMIC;
\c mimic;
CREATE SCHEMA MIMICIII;
*/

\set ON_ERROR_STOP 1

-- The below command defines the schema where all tables are created
SET search_path TO mimiciii;

-- Restoring the search path to its default value can be accomplished as follows:
--  SET search_path TO "$user",public;

-- -- Example command for importing from a CSV to a table
-- COPY admissions
--     FROM '/path/to/file/ADMISSIONS.csv'
--     DELIMITER ','
--     CSV HEADER;

/* Set the mimic_data_dir variable to point to directory containing
   all .csv files. If using Docker, this should not be changed here.
   Rather, when running the docker container, use the -v option
   to have Docker mount a host volume to the container path /mimic_data
   as explained in the README file
*/

-- include trailing slash
-- variables are not supported by \copy, so comment out for now
-- \set mimic_data_dir '/mimic_data/'

--------------------------------------------------------
--  Load Data for Table ADMISSIONS
--------------------------------------------------------

\set admissions_csv :mimic_data_dir 'ADMISSIONS.csv'
COPY ADMISSIONS FROM :'admissions_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table CALLOUT
--------------------------------------------------------

\set callout_csv :mimic_data_dir 'CALLOUT.csv'
COPY CALLOUT FROM :'callout_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table CAREGIVERS
--------------------------------------------------------

\set caregivers_csv :mimic_data_dir 'CAREGIVERS.csv'
COPY CAREGIVERS FROM :'caregivers_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table CHARTEVENTS
--------------------------------------------------------

\set chartevents_csv :mimic_data_dir 'CHARTEVENTS.csv'
COPY CHARTEVENTS FROM :'chartevents_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table CPTEVENTS
--------------------------------------------------------

\set cptevents_csv :mimic_data_dir 'CPTEVENTS.csv'
COPY CPTEVENTS FROM :'cptevents_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table DATETIMEEVENTS
--------------------------------------------------------

\set datetimeevents_csv :mimic_data_dir 'DATETIMEEVENTS.csv'
COPY DATETIMEEVENTS FROM :'datetimeevents_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table DIAGNOSES_ICD
--------------------------------------------------------

\set diagnoses_icd_csv :mimic_data_dir 'DIAGNOSES_ICD.csv'
COPY DIAGNOSES_ICD FROM :'diagnoses_icd_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table DRGCODES
--------------------------------------------------------

\set drgcodes_csv :mimic_data_dir 'DRGCODES.csv'
COPY DRGCODES FROM :'drgcodes_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table D_CPT
--------------------------------------------------------

\set d_cpt_csv :mimic_data_dir 'D_CPT.csv'
COPY D_CPT FROM :'d_cpt_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table D_ICD_DIAGNOSES
--------------------------------------------------------

\set d_icd_diagnoses_csv :mimic_data_dir 'D_ICD_DIAGNOSES.csv'
COPY D_ICD_DIAGNOSES FROM :'d_icd_diagnoses_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table D_ICD_PROCEDURES
--------------------------------------------------------

\set d_icd_procedures_csv :mimic_data_dir 'D_ICD_PROCEDURES.csv'
COPY D_ICD_PROCEDURES FROM :'d_icd_procedures_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table D_ITEMS
--------------------------------------------------------

\set d_items_csv :mimic_data_dir 'D_ITEMS.csv'
COPY D_ITEMS FROM :'d_items_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table D_LABITEMS
--------------------------------------------------------

\set d_labitems_csv :mimic_data_dir 'D_LABITEMS.csv'
COPY D_LABITEMS FROM :'d_labitems_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table ICUSTAYS
--------------------------------------------------------

\set icustays_csv :mimic_data_dir 'ICUSTAYS.csv'
COPY ICUSTAYS FROM :'icustays_csv' DELIMITER ',' CSV HEADER;


--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_CV
--------------------------------------------------------

\set inputevents_cv_csv :mimic_data_dir 'INPUTEVENTS_CV.csv'
COPY INPUTEVENTS_CV FROM :'inputevents_cv_csv' WITH DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_MV
--------------------------------------------------------

\set inputevents_mv_csv :mimic_data_dir 'INPUTEVENTS_MV.csv'
COPY INPUTEVENTS_MV FROM :'inputevents_mv_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table LABEVENTS
--------------------------------------------------------

\set labevents_csv :mimic_data_dir 'LABEVENTS.csv'
COPY LABEVENTS FROM :'labevents_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

\set microbiologyevents_csv :mimic_data_dir 'MICROBIOLOGYEVENTS.csv'
COPY MICROBIOLOGYEVENTS FROM :'microbiologyevents_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table NOTEEVENTS
--------------------------------------------------------

\set noteevents_csv :mimic_data_dir 'NOTEEVENTS.csv'
COPY NOTEEVENTS FROM :'noteevents_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table OUTPUTEVENTS
--------------------------------------------------------

\set outputevents_csv :mimic_data_dir 'OUTPUTEVENTS.csv'
COPY OUTPUTEVENTS FROM :'outputevents_csv' WITH DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table PATIENTS
--------------------------------------------------------

\set patients_csv :mimic_data_dir 'PATIENTS.csv'
COPY PATIENTS FROM :'patients_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table PRESCRIPTIONS
--------------------------------------------------------

\set prescriptions_csv :mimic_data_dir 'PRESCRIPTIONS.csv'
COPY PRESCRIPTIONS FROM :'prescriptions_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table PROCEDUREEVENTS_MV
--------------------------------------------------------

\set procedureevents_mv_csv :mimic_data_dir 'PROCEDUREEVENTS_MV.csv'
COPY PROCEDUREEVENTS_MV FROM :'procedureevents_mv_csv' WITH DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table PROCEDURES_ICD
--------------------------------------------------------

\set procedures_icd_csv :mimic_data_dir 'PROCEDURES_ICD.csv'
COPY PROCEDURES_ICD FROM :'procedures_icd_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table SERVICES
--------------------------------------------------------

\set services_csv :mimic_data_dir 'SERVICES.csv'
COPY SERVICES FROM :'services_csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  Load Data for Table TRANSFERS
--------------------------------------------------------

\set transfers_csv :mimic_data_dir 'TRANSFERS.csv'
COPY TRANSFERS FROM :'transfers_csv' DELIMITER ',' CSV HEADER;
