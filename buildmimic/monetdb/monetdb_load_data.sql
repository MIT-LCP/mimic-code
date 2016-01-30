-- -------------------------------------------------------------------------------
--
-- Load data into the MIMIC-III schema
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Thursday-August-27-2015
--------------------------------------------------------




/* Set the mimic_data_dir variable to point to directory containing
   all .csv files. If using Docker, this should not be changed here.
   Rather, when running the docker container, use the -v option
   to have Docker mount a host volume to the container path /mimic_data
   as explained in the README file
*/

--------------------------------------------------------
--  Load Data for Table ADMISSIONS
--------------------------------------------------------

COPY 58976 OFFSET 2 RECORDS INTO MIMICIII.ADMISSIONS FROM '/home/natus/Projets/mimic/mimic3/csv/ADMISSIONS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table CALLOUT
--------------------------------------------------------

COPY 34499 OFFSET 2 RECORDS INTO MIMICIII.CALLOUT FROM '/home/natus/Projets/mimic/mimic3/csv/CALLOUT.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table CAREGIVERS
--------------------------------------------------------

COPY 7567 OFFSET 2 RECORDS INTO MIMICIII.CAREGIVERS FROM '/home/natus/Projets/mimic/mimic3/csv/CAREGIVERS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table CHARTEVENTS
--------------------------------------------------------

COPY 263201375 OFFSET 2 RECORDS INTO MIMICIII.CHARTEVENTS FROM '/home/natus/Projets/mimic/mimic3/csv/CHARTEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table CPTEVENTS
--------------------------------------------------------

COPY 573146 OFFSET 2 RECORDS INTO MIMICIII.CPTEVENTS FROM '/home/natus/Projets/mimic/mimic3/csv/CPTEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table DATETIMEEVENTS
--------------------------------------------------------

COPY 4486049 OFFSET 2 RECORDS INTO MIMICIII.DATETIMEEVENTS FROM '/home/natus/Projets/mimic/mimic3/csv/DATETIMEEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table DIAGNOSES_ICD
--------------------------------------------------------

COPY 651048 OFFSET 2 RECORDS INTO MIMICIII.DIAGNOSES_ICD FROM '/home/natus/Projets/mimic/mimic3/csv/DIAGNOSES_ICD.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table DRGCODES
--------------------------------------------------------

COPY 125557 OFFSET 2 RECORDS INTO MIMICIII.DRGCODES FROM '/home/natus/Projets/mimic/mimic3/csv/DRGCODES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_CPT
--------------------------------------------------------

COPY 134 OFFSET 2 RECORDS INTO MIMICIII.D_CPT FROM '/home/natus/Projets/mimic/mimic3/csv/D_CPT.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_ICD_DIAGNOSES
--------------------------------------------------------

COPY 14567 OFFSET 2 RECORDS INTO MIMICIII.D_ICD_DIAGNOSES FROM '/home/natus/Projets/mimic/mimic3/csv/D_ICD_DIAGNOSES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_ICD_PROCEDURES
--------------------------------------------------------

COPY 3882 OFFSET 2 RECORDS INTO MIMICIII.D_ICD_PROCEDURES FROM '/home/natus/Projets/mimic/mimic3/csv/D_ICD_PROCEDURES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_ITEMS
--------------------------------------------------------

COPY 12478 OFFSET 2 RECORDS INTO MIMICIII.D_ITEMS FROM '/home/natus/Projets/mimic/mimic3/csv/D_ITEMS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_LABITEMS
--------------------------------------------------------

COPY 755 OFFSET 2 RECORDS INTO MIMICIII.D_LABITEMS FROM '/home/natus/Projets/mimic/mimic3/csv/D_LABITEMS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table ICUSTAYS
--------------------------------------------------------

COPY 61532 OFFSET 2 RECORDS INTO MIMICIII.ICUSTAYS FROM '/home/natus/Projets/mimic/mimic3/csv/ICUSTAYS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_CV
--------------------------------------------------------

COPY 17528894 OFFSET 2 RECORDS INTO MIMICIII.INPUTEVENTS_CV FROM '/home/natus/Projets/mimic/mimic3/csv/INPUTEVENTS_CV.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_MV
--------------------------------------------------------

COPY 3618991 OFFSET 2 RECORDS INTO MIMICIII.INPUTEVENTS_MV FROM '/home/natus/Projets/mimic/mimic3/csv/INPUTEVENTS_MV.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table LABEVENTS
--------------------------------------------------------

COPY 27872575 OFFSET 2 RECORDS INTO MIMICIII.LABEVENTS FROM '/home/natus/Projets/mimic/mimic3/csv/LABEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

COPY 328446 OFFSET 2 RECORDS INTO MIMICIII.MICROBIOLOGYEVENTS FROM '/home/natus/Projets/mimic/mimic3/csv/MICROBIOLOGYEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table NOTEEVENTS
--------------------------------------------------------

COPY 2078704 OFFSET 2 RECORDS INTO MIMICIII.NOTEEVENTS FROM '/home/natus/Projets/mimic/mimic3/csv/NOTEEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table OUTPUTEVENTS
--------------------------------------------------------

COPY 349339 OFFSET 2 RECORDS INTO MIMICIII.OUTPUTEVENTS FROM '/home/natus/Projets/mimic/mimic3/csv/OUTPUTEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PATIENTS
--------------------------------------------------------

COPY 46520 OFFSET 2 RECORDS INTO MIMICIII.PATIENTS FROM '/home/natus/Projets/mimic/mimic3/csv/PATIENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PRESCRIPTIONS
--------------------------------------------------------

COPY 156848 OFFSET 2 RECORDS INTO MIMICIII.PRESCRIPTIONS FROM '/home/natus/Projets/mimic/mimic3/csv/PRESCRIPTIONS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PROCEDUREEVENTS_MV
--------------------------------------------------------

COPY 258066 OFFSET 2 RECORDS INTO MIMICIII.PROCEDUREEVENTS_MV FROM '/home/natus/Projets/mimic/mimic3/csv/PROCEDUREEVENTS_MV.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PROCEDURES_ICD
--------------------------------------------------------

COPY 240095 OFFSET 2 RECORDS INTO MIMICIII.PROCEDURES_ICD FROM '/home/natus/Projets/mimic/mimic3/csv/PROCEDURES_ICD.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table SERVICES
--------------------------------------------------------

COPY 73343 OFFSET 2 RECORDS INTO MIMICIII.SERVICES FROM '/home/natus/Projets/mimic/mimic3/csv/SERVICES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table TRANSFERS
--------------------------------------------------------

COPY 261897 OFFSET 2 RECORDS INTO MIMICIII.TRANSFERS FROM '/home/natus/Projets/mimic/mimic3/csv/TRANSFERS.csv' USING DELIMITERS ',','\n','"' NULL AS '';
