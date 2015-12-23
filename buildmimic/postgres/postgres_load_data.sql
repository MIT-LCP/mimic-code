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

\copy ADMISSIONS FROM 'ADMISSIONS.csv' DELIMITER ',' CSV HEADER

--------------------------------------------------------
--  Load Data for Table CALLOUT
--------------------------------------------------------

\copy CALLOUT from 'CALLOUT.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table CAREGIVERS
--------------------------------------------------------

\copy CAREGIVERS from 'CAREGIVERS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table CHARTEVENTS
--------------------------------------------------------

\copy CHARTEVENTS from 'CHARTEVENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table CPTEVENTS
--------------------------------------------------------

\copy CPTEVENTS from 'CPTEVENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table DATETIMEEVENTS
--------------------------------------------------------

\copy DATETIMEEVENTS from 'DATETIMEEVENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table DIAGNOSES_ICD
--------------------------------------------------------

\copy DIAGNOSES_ICD from 'DIAGNOSES_ICD.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table DRGCODES
--------------------------------------------------------

\copy DRGCODES from 'DRGCODES.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table D_CPT
--------------------------------------------------------

\copy D_CPT from 'D_CPT.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table D_ICD_DIAGNOSES
--------------------------------------------------------

\copy D_ICD_DIAGNOSES from 'D_ICD_DIAGNOSES.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table D_ICD_PROCEDURES
--------------------------------------------------------

\copy D_ICD_PROCEDURES from 'D_ICD_PROCEDURES.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table D_ITEMS
--------------------------------------------------------

\copy D_ITEMS from 'D_ITEMS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table D_LABITEMS
--------------------------------------------------------

\copy D_LABITEMS from 'D_LABITEMS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table ICUSTAYS
--------------------------------------------------------

\copy ICUSTAYS from 'ICUSTAYS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_CV
--------------------------------------------------------

\copy INPUTEVENTS_CV from 'INPUTEVENTS_CV.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_MV
--------------------------------------------------------

\copy INPUTEVENTS_MV from 'INPUTEVENTS_MV.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table LABEVENTS
--------------------------------------------------------

\copy LABEVENTS from 'LABEVENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

\copy MICROBIOLOGYEVENTS from 'MICROBIOLOGYEVENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table NOTEEVENTS
--------------------------------------------------------

\copy NOTEEVENTS from 'NOTEEVENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table OUTPUTEVENTS
--------------------------------------------------------

\copy OUTPUTEVENTS from 'OUTPUTEVENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table PATIENTS
--------------------------------------------------------

\copy PATIENTS from 'PATIENTS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table PRESCRIPTIONS
--------------------------------------------------------

\copy PRESCRIPTIONS from 'PRESCRIPTIONS.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table PROCEDUREEVENTS_MV
--------------------------------------------------------

\copy PROCEDUREEVENTS_MV from 'PROCEDUREEVENTS_MV.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table PROCEDURES_ICD
--------------------------------------------------------

\copy PROCEDURES_ICD from 'PROCEDURES_ICD.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table SERVICES
--------------------------------------------------------

\copy SERVICES from 'SERVICES.csv' delimiter ',' csv header

--------------------------------------------------------
--  Load Data for Table TRANSFERS
--------------------------------------------------------

\copy TRANSFERS from 'TRANSFERS.csv' delimiter ',' csv header
