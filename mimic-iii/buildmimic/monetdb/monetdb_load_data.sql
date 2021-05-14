-- ------------------------------------------------------------------
-- Title: Load data into the MIMIC-III schema
-- Description: More detailed description explaining the purpose.
-- ------------------------------------------------------------------


/* Set the mimic_data_dir variable to point to directory containing
   all .csv files. If using Docker, this should not be changed here.
   Rather, when running the docker container, use the -v option
   to have Docker mount a host volume to the container path /mimic_data
   as explained in the README file
*/

--------------------------------------------------------
--  Load Data for Table ADMISSIONS
--------------------------------------------------------

COPY 58976 OFFSET 2 RECORDS INTO MIMICIII.ADMISSIONS FROM '/path/to/ADMISSIONS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table CALLOUT
--------------------------------------------------------

COPY 34499 OFFSET 2 RECORDS INTO MIMICIII.CALLOUT FROM '/path/to/CALLOUT.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table CAREGIVERS
--------------------------------------------------------

COPY 7567 OFFSET 2 RECORDS INTO MIMICIII.CAREGIVERS FROM '/path/to/CAREGIVERS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table CHARTEVENTS
--------------------------------------------------------

COPY 330712483 OFFSET 2 RECORDS INTO MIMICIII.CHARTEVENTS FROM '/path/to/CHARTEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

----------------------------------------------------------------------------------------------------------------
--  Load Data for Table CPTEVENTS


COPY 573146 OFFSET 2 RECORDS INTO MIMICIII.CPTEVENTS FROM '/path/to/CPTEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table DATETIMEEVENTS
--------------------------------------------------------

COPY 4485937 OFFSET 2 RECORDS INTO MIMICIII.DATETIMEEVENTS FROM '/path/to/DATETIMEEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table DIAGNOSES_ICD
--------------------------------------------------------

COPY 651047 OFFSET 2 RECORDS INTO MIMICIII.DIAGNOSES_ICD FROM '/path/to/DIAGNOSES_ICD.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table DRGCODES
--------------------------------------------------------

COPY 125557 OFFSET 2 RECORDS INTO MIMICIII.DRGCODES FROM '/path/to/DRGCODES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_CPT
--------------------------------------------------------

COPY 134 OFFSET 2 RECORDS INTO MIMICIII.D_CPT FROM '/path/to/D_CPT.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_ICD_DIAGNOSES
--------------------------------------------------------

COPY 14567 OFFSET 2 RECORDS INTO MIMICIII.D_ICD_DIAGNOSES FROM '/path/to/D_ICD_DIAGNOSES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_ICD_PROCEDURES
--------------------------------------------------------

COPY 3882 OFFSET 2 RECORDS INTO MIMICIII.D_ICD_PROCEDURES FROM '/path/to/D_ICD_PROCEDURES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_ITEMS
--------------------------------------------------------

COPY 12478 OFFSET 2 RECORDS INTO MIMICIII.D_ITEMS FROM '/path/to/D_ITEMS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table D_LABITEMS
--------------------------------------------------------

COPY 753 OFFSET 2 RECORDS INTO MIMICIII.D_LABITEMS FROM '/path/to/D_LABITEMS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table ICUSTAYS
--------------------------------------------------------

COPY 61532 OFFSET 2 RECORDS INTO MIMICIII.ICUSTAYS FROM '/path/to/ICUSTAYS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_CV
--------------------------------------------------------

COPY 17527935 OFFSET 2 RECORDS INTO MIMICIII.INPUTEVENTS_CV FROM '/path/to/INPUTEVENTS_CV.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table INPUTEVENTS_MV
--------------------------------------------------------

COPY 3618991 OFFSET 2 RECORDS INTO MIMICIII.INPUTEVENTS_MV FROM '/path/to/INPUTEVENTS_MV.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table LABEVENTS
--------------------------------------------------------

COPY 27854055 OFFSET 2 RECORDS INTO MIMICIII.LABEVENTS FROM '/path/to/LABEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

COPY 631726 OFFSET 2 RECORDS INTO MIMICIII.MICROBIOLOGYEVENTS FROM '/path/to/MICROBIOLOGYEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table NOTEEVENTS
--------------------------------------------------------

COPY 2083180 OFFSET 2 RECORDS INTO MIMICIII.NOTEEVENTS FROM '/path/to/NOTEEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table OUTPUTEVENTS
--------------------------------------------------------

COPY 4349218 OFFSET 2 RECORDS INTO MIMICIII.OUTPUTEVENTS FROM '/path/to/OUTPUTEVENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PATIENTS
--------------------------------------------------------

COPY 46520 OFFSET 2 RECORDS INTO MIMICIII.PATIENTS FROM '/path/to/PATIENTS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PRESCRIPTIONS
--------------------------------------------------------

COPY 4156450 OFFSET 2 RECORDS INTO MIMICIII.PRESCRIPTIONS FROM '/path/to/PRESCRIPTIONS.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PROCEDUREEVENTS_MV
--------------------------------------------------------

COPY 258066 OFFSET 2 RECORDS INTO MIMICIII.PROCEDUREEVENTS_MV FROM '/path/to/PROCEDUREEVENTS_MV.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table PROCEDURES_ICD
--------------------------------------------------------

COPY 240095 OFFSET 2 RECORDS INTO MIMICIII.PROCEDURES_ICD FROM '/path/to/PROCEDURES_ICD.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table SERVICES
--------------------------------------------------------

COPY 73343 OFFSET 2 RECORDS INTO MIMICIII.SERVICES FROM '/path/to/SERVICES.csv' USING DELIMITERS ',','\n','"' NULL AS '';

--------------------------------------------------------
--  Load Data for Table TRANSFERS
--------------------------------------------------------

COPY 261897 OFFSET 2 RECORDS INTO MIMICIII.TRANSFERS FROM '/path/to/TRANSFERS.csv' USING DELIMITERS ',','\n','"' NULL AS '';
