-- -------------------------------------------------------------------------------
--
-- This is a script to generate the MIMIC-III schema and import data for Postgres.
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


-- The below command defines the schema where all tables are created
SET search_path TO mimiciii;

-- Restoring the search path to its default value can be accomplished as follows:
--  SET search_path TO "$user",public;


-- -- Example command for importing from a CSV to a table
-- COPY admissions
--     FROM '/path/to/file/ADMISSIONS_DATA_TABLE.csv'
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
--  DDL for Table ADMISSIONS
--------------------------------------------------------

CREATE TABLE ADMISSIONS
(
  ROW_ID INT NOT NULL,
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT NOT NULL,
  ADMITTIME TIMESTAMP(0) NOT NULL,
  DISCHTIME TIMESTAMP(0) NOT NULL,
  DEATHTIME TIMESTAMP(0),
  ADMISSION_TYPE VARCHAR(50) NOT NULL,
  ADMISSION_LOCATION VARCHAR(50) NOT NULL,
  DISCHARGE_LOCATION VARCHAR(50) NOT NULL,
  INSURANCE VARCHAR(255) NOT NULL,
  LANGUAGE VARCHAR(10),
  RELIGION VARCHAR(50),
  MARITAL_STATUS VARCHAR(50),
  ETHNICITY VARCHAR(200) NOT NULL,
  EDREGTIME TIMESTAMP(0),
  EDTIMEOUT TIMESTAMP(0),
  DIAGNOSIS VARCHAR(255),
  HOSPITAL_EXPIRE_FLAG SMALLINT,
  HAS_IOEVENTS_DATA SMALLINT NOT NULL,
  HAS_CHARTEVENTS_DATA SMALLINT NOT NULL,
  CONSTRAINT adm_rowid_pk PRIMARY KEY (ROW_ID),
  CONSTRAINT adm_hadm_unique UNIQUE (HADM_ID)
) ;

/* Docker runs scripts as postgres user, so it is necessary to change table ownership to mimic user */
-- ALTER TABLE ADMISSIONS OWNER TO MIMIC;

-- Example command for importing from a CSV to a table
-- \set admissions_csv :mimic_data_dir 'ADMISSIONS_DATA_TABLE.csv'

\COPY ADMISSIONS FROM 'ADMISSIONS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table CALLOUT
--------------------------------------------------------

CREATE TABLE CALLOUT
    (   ROW_ID INT NOT NULL,
        SUBJECT_ID INT NOT NULL,
        HADM_ID INT NOT NULL,
        SUBMIT_WARDID INT,
        SUBMIT_CAREUNIT VARCHAR(15),
        CURR_WARDID INT,
        CURR_CAREUNIT VARCHAR(15),
        CALLOUT_WARDID INT,
        CALLOUT_SERVICE VARCHAR(10) NOT NULL,
        REQUEST_TELE SMALLINT NOT NULL,
        REQUEST_RESP SMALLINT NOT NULL,
        REQUEST_CDIFF SMALLINT NOT NULL,
        REQUEST_MRSA SMALLINT NOT NULL,
        REQUEST_VRE SMALLINT NOT NULL,
        CALLOUT_STATUS VARCHAR(20) NOT NULL,
        CALLOUT_OUTCOME VARCHAR(20) NOT NULL,
        DISCHARGE_WARDID INT,
        ACKNOWLEDGE_STATUS VARCHAR(20) NOT NULL,
        CREATETIME TIMESTAMP(0) NOT NULL,
        UPDATETIME TIMESTAMP(0) NOT NULL,
        ACKNOWLEDGETIME TIMESTAMP(0),
        OUTCOMETIME TIMESTAMP(0) NOT NULL,
        FIRSTRESERVATIONTIME TIMESTAMP(0),
        CURRENTRESERVATIONTIME TIMESTAMP(0),
        CONSTRAINT callout_rowid_pk PRIMARY KEY (ROW_ID)
        );

-- ALTER TABLE CALLOUT OWNER TO MIMIC;

-- \set callout_csv :mimic_data_dir 'CALLOUT_DATA_TABLE.csv'

\COPY CALLOUT FROM 'CALLOUT_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table CAREGIVERS
--------------------------------------------------------

CREATE TABLE CAREGIVERS
   (	ROW_ID INT NOT NULL,
	CGID INT NOT NULL,
	LABEL VARCHAR(15),
	DESCRIPTION VARCHAR(30),
	CONSTRAINT cg_rowid_pk  PRIMARY KEY (ROW_ID),
	CONSTRAINT cg_cgid_unique UNIQUE (CGID)
   ) ;

-- ALTER TABLE CAREGIVERS OWNER TO MIMIC;

-- \set caregivers_csv :mimic_data_dir 'CAREGIVERS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY CAREGIVERS FROM 'CAREGIVERS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table CHARTEVENTS
--------------------------------------------------------

CREATE TABLE CHARTEVENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	ITEMID INT,
	CHARTTIME TIMESTAMP(0),
	STORETIME TIMESTAMP(0),
	CGID INT,
	VALUE VARCHAR(255),
	VALUENUM DOUBLE PRECISION,
	UOM VARCHAR(50),
	WARNING INT,
	ERROR INT,
	RESULTSTATUS VARCHAR(50),
	STOPPED VARCHAR(50),
	CONSTRAINT chartevents_rowid_pk PRIMARY KEY (ROW_ID)
  );

-- ALTER TABLE CHARTEVENTS OWNER TO MIMIC;

-- \set chartevents_csv :mimic_data_dir 'CHARTEVENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY CHARTEVENTS FROM 'CHARTEVENTS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table CPTEVENTS
--------------------------------------------------------

  CREATE TABLE CPTEVENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	COSTCENTER VARCHAR(10) NOT NULL,
	CHARTDATE TIMESTAMP(0),
	CPT_CD VARCHAR(10) NOT NULL,
	CPT_NUMBER INT,
	CPT_SUFFIX VARCHAR(5),
	TICKET_ID_SEQ INT,
	SECTIONHEADER VARCHAR(50),
	SUBSECTIONHEADER VARCHAR(255),
	DESCRIPTION VARCHAR(200),
	CONSTRAINT cpt_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE CPTEVENTS OWNER TO MIMIC;

-- \set cptevents_csv :mimic_data_dir 'CPTEVENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY CPTEVENTS FROM 'CPTEVENTS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table DATETIMEEVENTS
--------------------------------------------------------

  CREATE TABLE DATETIMEEVENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	ITEMID INT NOT NULL,
	CHARTTIME TIMESTAMP(0) NOT NULL,
	STORETIME TIMESTAMP(0) NOT NULL,
	CGID INT NOT NULL,
	VALUE TIMESTAMP(0),
	UOM VARCHAR(50) NOT NULL,
	WARNING SMALLINT,
	ERROR SMALLINT,
	RESULTSTATUS VARCHAR(50),
	STOPPED VARCHAR(50),
	CONSTRAINT datetime_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE DATETIMEEVENTS OWNER TO MIMIC;

-- \set datetimeevents_csv :mimic_data_dir 'DATETIMEEVENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY DATETIMEEVENTS FROM 'DATETIMEEVENTS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table DIAGNOSES_ICD
--------------------------------------------------------

  CREATE TABLE DIAGNOSES_ICD
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	SEQ_NUM INT,
	ICD9_CODE VARCHAR(20),
	CONSTRAINT diagnosesicd_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

  -- ALTER TABLE DIAGNOSES_ICD OWNER TO MIMIC;

-- \set diagnoses_icd_csv :mimic_data_dir 'DIAGNOSES_ICD_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY DIAGNOSES_ICD FROM 'DIAGNOSES_ICD_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table DRGCODES
--------------------------------------------------------

  CREATE TABLE DRGCODES
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	DRG_TYPE VARCHAR(20) NOT NULL,
	DRG_CODE VARCHAR(20) NOT NULL,
	DESCRIPTION VARCHAR(255),
	DRG_SEVERITY SMALLINT,
	DRG_MORTALITY SMALLINT,
	CONSTRAINT drg_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE DRGCODES OWNER TO MIMIC;

-- \set drgcodes_csv :mimic_data_dir 'DRGCODES_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY DRGCODES FROM 'DRGCODES_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table D_CPT
--------------------------------------------------------

  CREATE TABLE D_CPT
   (	ROW_ID INT NOT NULL,
	CATEGORY SMALLINT NOT NULL,
	SECTIONRANGE VARCHAR(100) NOT NULL,
	SECTIONHEADER VARCHAR(50) NOT NULL,
	SUBSECTIONRANGE VARCHAR(100) NOT NULL,
	SUBSECTIONHEADER VARCHAR(255) NOT NULL,
	CODESUFFIX VARCHAR(5),
	MINCODEINSUBSECTION INT NOT NULL,
	MAXCODEINSUBSECTION INT NOT NULL,
    	CONSTRAINT dcpt_ssrange_unique UNIQUE (SUBSECTIONRANGE),
    	CONSTRAINT dcpt_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE D_CPT OWNER TO MIMIC;

-- \set d_cpt_csv :mimic_data_dir 'D_CPT_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY D_CPT FROM 'D_CPT_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table D_ICD_DIAGNOSES
--------------------------------------------------------

  CREATE TABLE D_ICD_DIAGNOSES
   (	ROW_ID INT NOT NULL,
	ICD9_CODE VARCHAR(10) NOT NULL,
	SHORT_TITLE VARCHAR(50) NOT NULL,
	LONG_TITLE VARCHAR(255) NOT NULL,
    	CONSTRAINT d_icd_diag_code_unique UNIQUE (ICD9_CODE),
    	CONSTRAINT d_icd_diag_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE D_ICD_DIAGNOSES OWNER TO MIMIC;

-- \set d_icd_diagnoses_csv :mimic_data_dir 'D_ICD_DIAGNOSES_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY D_ICD_DIAGNOSES FROM 'D_ICD_DIAGNOSES_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table D_ICD_PROCEDURES
--------------------------------------------------------

  CREATE TABLE D_ICD_PROCEDURES
   (	ROW_ID INT NOT NULL,
	ICD9_CODE VARCHAR(10) NOT NULL,
	SHORT_TITLE VARCHAR(50) NOT NULL,
	LONG_TITLE VARCHAR(255) NOT NULL,
    	CONSTRAINT d_icd_proc_code_unique UNIQUE (ICD9_CODE),
    	CONSTRAINT d_icd_proc_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE D_ICD_PROCEDURES OWNER TO MIMIC;

-- \set d_icd_procedures_csv :mimic_data_dir 'D_ICD_PROCEDURES_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY D_ICD_PROCEDURES FROM 'D_ICD_PROCEDURES_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table D_ITEMS
--------------------------------------------------------

  CREATE TABLE D_ITEMS
   (	ROW_ID INT NOT NULL,
    	ITEMID INT NOT NULL,
    	LABEL VARCHAR(200),
    	ABBREVIATION VARCHAR(100),
    	DBSOURCE VARCHAR(20),
    	LINKSTO VARCHAR(50),
    	CATEGORY VARCHAR(100),
    	UNITNAME VARCHAR(100),
    	PARAM_TYPE VARCHAR(30),
    	CONCEPTID INT,
    	CONSTRAINT ditems_itemid_unique UNIQUE (ITEMID),
    	CONSTRAINT ditems_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE D_ITEMS OWNER TO MIMIC;

-- \set d_items_csv :mimic_data_dir 'D_ITEMS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY D_ITEMS FROM 'D_ITEMS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table D_LABITEMS
--------------------------------------------------------

  CREATE TABLE D_LABITEMS
   (	ROW_ID INT NOT NULL,
	ITEMID INT NOT NULL,
	LABEL VARCHAR(100) NOT NULL,
	FLUID VARCHAR(100) NOT NULL,
	CATEGORY VARCHAR(100) NOT NULL,
	LOINC_CODE VARCHAR(100),
    	CONSTRAINT dlabitems_itemid_unique UNIQUE (ITEMID),
    	CONSTRAINT dlabitems_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE D_LABITEMS OWNER TO MIMIC;

-- \set d_labitems_csv :mimic_data_dir 'D_LABITEMS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY D_LABITEMS FROM 'D_LABITEMS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table ICUSTAYS
--------------------------------------------------------

  CREATE TABLE ICUSTAYS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT NOT NULL,
	DBSOURCE VARCHAR(20) NOT NULL,
	FIRST_CAREUNIT VARCHAR(20) NOT NULL,
	LAST_CAREUNIT VARCHAR(20) NOT NULL,
	FIRST_WARDID SMALLINT NOT NULL,
	LAST_WARDID SMALLINT NOT NULL,
	INTIME TIMESTAMP(0) NOT NULL,
	OUTTIME TIMESTAMP(0),
	LOS DOUBLE PRECISION,
    	CONSTRAINT icustay_icustayid_unique UNIQUE (ICUSTAY_ID),
    	CONSTRAINT icustay_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE ICUSTAYS OWNER TO MIMIC;

-- \set icustays_csv :mimic_data_dir 'ICUSTAYS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY ICUSTAYS FROM 'ICUSTAYS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;


--------------------------------------------------------
--  DDL for Table INPUTEVENTS_CV
--------------------------------------------------------

  CREATE TABLE INPUTEVENTS_CV
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	CHARTTIME TIMESTAMP(0),
	ITEMID INT,
	AMOUNT DOUBLE PRECISION,
	AMOUNTUOM VARCHAR(30),
	RATE DOUBLE PRECISION,
	RATEUOM VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	ORDERID INT,
	LINKORDERID INT,
	STOPPED VARCHAR(30),
	NEWBOTTLE INT,
	ORIGINALAMOUNT DOUBLE PRECISION,
	ORIGINALAMOUNTUOM VARCHAR(30),
	ORIGINALROUTE VARCHAR(30),
	ORIGINALRATE DOUBLE PRECISION,
	ORIGINALRATEUOM VARCHAR(30),
	ORIGINALSITE VARCHAR(30),
	CONSTRAINT inputevents_cv_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE INPUTEVENTS_CV OWNER TO MIMIC;

-- \set inputevents_cv_csv :mimic_data_dir 'INPUTEVENTS_CV_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY INPUTEVENTS_CV FROM 'INPUTEVENTS_CV_DATA_TABLE.csv' WITH DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table INPUTEVENTS_MV
--------------------------------------------------------

  CREATE TABLE INPUTEVENTS_MV
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	STARTTIME TIMESTAMP(0),
	ENDTIME TIMESTAMP(0),
	ITEMID INT,
	AMOUNT DOUBLE PRECISION,
	AMOUNTUOM VARCHAR(30),
	RATE DOUBLE PRECISION,
	RATEUOM VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	ORDERID INT,
	LINKORDERID INT,
	ORDERCATEGORYNAME VARCHAR(100),
	SECONDARYORDERCATEGORYNAME VARCHAR(100),
	ORDERCOMPONENTTYPEDESCRIPTION VARCHAR(200),
	ORDERCATEGORYDESCRIPTION VARCHAR(50),
	PATIENTWEIGHT DOUBLE PRECISION,
	TOTALAMOUNT DOUBLE PRECISION,
	TOTALAMOUNTUOM VARCHAR(50),
	ISOPENBAG SMALLINT,
	CONTINUEINNEXTDEPT SMALLINT,
	CANCELREASON SMALLINT,
	STATUSDESCRIPTION VARCHAR(30),
	COMMENTS_EDITEDBY VARCHAR(30),
	COMMENTS_CANCELEDBY VARCHAR(40),
	COMMENTS_DATE TIMESTAMP(0),
	ORIGINALAMOUNT DOUBLE PRECISION,
	ORIGINALRATE DOUBLE PRECISION,
	CONSTRAINT inputevents_mv_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE INPUTEVENTS_MV OWNER TO MIMIC;

-- \set inputevents_mv_csv :mimic_data_dir 'INPUTEVENTS_MV_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY INPUTEVENTS_MV FROM 'INPUTEVENTS_MV_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table LABEVENTS
--------------------------------------------------------

  CREATE TABLE LABEVENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ITEMID INT NOT NULL,
	CHARTTIME TIMESTAMP(0),
	VALUE VARCHAR(200),
	VALUENUM DOUBLE PRECISION,
	UOM VARCHAR(20),
	FLAG VARCHAR(20),
	CONSTRAINT labevents_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE LABEVENTS OWNER TO MIMIC;

-- \set labevents_csv :mimic_data_dir 'LABEVENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY LABEVENTS FROM 'LABEVENTS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

  CREATE TABLE MICROBIOLOGYEVENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	CHARTDATE TIMESTAMP(0),
	CHARTTIME TIMESTAMP(0),
	SPEC_ITEMID INT,
	SPEC_TYPE_DESC VARCHAR(100),
	ORG_ITEMID INT,
	ORG_NAME VARCHAR(100),
	ISOLATE_NUM SMALLINT,
	AB_ITEMID INT,
	AB_NAME VARCHAR(30),
	DILUTION_TEXT VARCHAR(10),
	DILUTION_COMPARISON VARCHAR(20),
	DILUTION_VALUE DOUBLE PRECISION,
	INTERPRETATION VARCHAR(5),
	CONSTRAINT micro_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE MICROBIOLOGYEVENTS OWNER TO MIMIC;

-- \set microbiologyevents_csv :mimic_data_dir 'MICROBIOLOGYEVENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY MICROBIOLOGYEVENTS FROM 'MICROBIOLOGYEVENTS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table NOTEEVENTS
--------------------------------------------------------

  CREATE TABLE NOTEEVENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	CHARTDATE TIMESTAMP(0),
	CHARTTIME TIMESTAMP(0),
	STORETIME TIMESTAMP(0),
	CATEGORY VARCHAR(50),
	DESCRIPTION VARCHAR(255),
	CGID INT,
	ISERROR CHAR(1),
	TEXT TEXT,
	CONSTRAINT noteevents_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE NOTEEVENTS OWNER TO MIMIC;

-- \set noteevents_csv :mimic_data_dir 'NOTEEVENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY NOTEEVENTS FROM 'NOTEEVENTS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table OUTPUTEVENTS
--------------------------------------------------------

  CREATE TABLE OUTPUTEVENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT,
	ICUSTAY_ID INT,
	CHARTTIME TIMESTAMP(0),
	ITEMID INT,
	VALUE DOUBLE PRECISION,
	VALUEUOM VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	STOPPED VARCHAR(30),
	NEWBOTTLE CHAR(1),
	ISERROR INT,
	CONSTRAINT outputevents_cv_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE OUTPUTEVENTS OWNER TO MIMIC;

-- \set outputevents_csv :mimic_data_dir 'OUTPUTEVENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY OUTPUTEVENTS FROM 'OUTPUTEVENTS_DATA_TABLE.csv' WITH DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table PATIENTS
--------------------------------------------------------

  CREATE TABLE PATIENTS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	GENDER VARCHAR(5) NOT NULL,
	DOB TIMESTAMP(0) NOT NULL,
	DOD TIMESTAMP(0),
	DOD_HOSP TIMESTAMP(0),
	DOD_SSN TIMESTAMP(0),
	EXPIRE_FLAG VARCHAR(5) NOT NULL,
    	CONSTRAINT pat_subid_unique UNIQUE (SUBJECT_ID),
    	CONSTRAINT pat_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE PATIENTS OWNER TO MIMIC;

-- \set patients_csv :mimic_data_dir 'PATIENTS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY PATIENTS FROM 'PATIENTS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table PRESCRIPTIONS
--------------------------------------------------------

  CREATE TABLE PRESCRIPTIONS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT,
	STARTDATE TIMESTAMP(0),
	ENDDATE TIMESTAMP(0),
	DRUG_TYPE VARCHAR(100) NOT NULL,
	DRUG VARCHAR(100) NOT NULL,
	DRUG_NAME_POE VARCHAR(100),
	DRUG_NAME_GENERIC VARCHAR(100),
	FORMULARY_DRUG_CD VARCHAR(120),
	GSN VARCHAR(200),
	NDC VARCHAR(120),
	PROD_STRENGTH VARCHAR(120),
	DOSE_VAL_RX VARCHAR(120),
	DOSE_UNIT_RX VARCHAR(120),
	FORM_VAL_DISP VARCHAR(120),
	FORM_UNIT_DISP VARCHAR(120),
	ROUTE VARCHAR(120),
	CONSTRAINT prescription_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE PRESCRIPTIONS OWNER TO MIMIC;

-- \set prescriptions_csv :mimic_data_dir 'PRESCRIPTIONS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY PRESCRIPTIONS FROM 'PRESCRIPTIONS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table PROCEDUREEVENTS_MV
--------------------------------------------------------


  CREATE TABLE PROCEDUREEVENTS_MV
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT,
	STARTTIME TIMESTAMP(0),
	ENDTIME TIMESTAMP(0),
	ITEMID INT,
	VALUE DOUBLE PRECISION,
	VALUEUOM VARCHAR(30),
	LOCATION VARCHAR(30),
	LOCATIONCATEGORY VARCHAR(30),
	STORETIME TIMESTAMP(0),
	CGID INT,
	ORDERID INT,
	LINKORDERID INT,
	ORDERCATEGORYNAME VARCHAR(100),
	SECONDARYORDERCATEGORYNAME VARCHAR(100),
	ORDERCATEGORYDESCRIPTION VARCHAR(50),
	ISOPENBAG SMALLINT,
	CONTINUEINNEXTDEPT SMALLINT,
	CANCELREASON SMALLINT,
	STATUSDESCRIPTION VARCHAR(30),
	COMMENTS_EDITEDBY VARCHAR(30),
	COMMENTS_CANCELEDBY VARCHAR(30),
	COMMENTS_DATE TIMESTAMP(0),
	CONSTRAINT procedureevents_mv_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE PROCEDUREEVENTS_MV OWNER TO MIMIC;

-- \set procedureevents_mv_csv :mimic_data_dir 'PROCEDUREEVENTS_MV_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY PROCEDUREEVENTS_MV FROM 'PROCEDUREEVENTS_MV_DATA_TABLE.csv' WITH DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table PROCEDURES_ICD
--------------------------------------------------------

  CREATE TABLE PROCEDURES_ICD
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	SEQ_NUM INT NOT NULL,
	ICD9_CODE VARCHAR(20) NOT NULL,
	CONSTRAINT proceduresicd_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE PROCEDURES_ICD OWNER TO MIMIC;

-- \set procedures_icd_csv :mimic_data_dir 'PROCEDURES_ICD_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY PROCEDURES_ICD FROM 'PROCEDURES_ICD_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table SERVICES
--------------------------------------------------------

  CREATE TABLE SERVICES
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	TRANSFERTIME TIMESTAMP(0) NOT NULL,
	PREV_SERVICE VARCHAR(20),
	CURR_SERVICE VARCHAR(20),
	CONSTRAINT services_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE SERVICES OWNER TO MIMIC;

-- \set services_csv :mimic_data_dir 'SERVICES_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY SERVICES FROM 'SERVICES_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;

--------------------------------------------------------
--  DDL for Table TRANSFERS
--------------------------------------------------------

  CREATE TABLE TRANSFERS
   (	ROW_ID INT NOT NULL,
	SUBJECT_ID INT NOT NULL,
	HADM_ID INT NOT NULL,
	ICUSTAY_ID INT,
	DBSOURCE VARCHAR(20) NOT NULL,
	EVENTTYPE VARCHAR(20),
	PREV_CAREUNIT VARCHAR(20),
	CURR_CAREUNIT VARCHAR(20),
	PREV_WARDID SMALLINT,
	CURR_WARDID SMALLINT,
	INTIME TIMESTAMP(0),
	OUTTIME TIMESTAMP(0),
	LOS DOUBLE PRECISION,
	CONSTRAINT transfers_rowid_pk PRIMARY KEY (ROW_ID)
   ) ;

-- ALTER TABLE TRANSFERS OWNER TO MIMIC;

-- \set transfers_csv :mimic_data_dir 'TRANSFERS_DATA_TABLE.csv'

-- Example command for importing from a CSV to a table
\COPY TRANSFERS FROM 'TRANSFERS_DATA_TABLE.csv' DELIMITER ',' CSV HEADER;
