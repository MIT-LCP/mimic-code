
-- The below command defines the schema where all tables are created
--ALTER SESSION SET CURRENT_SCHEMA = MIMICIII;

-- Restoring the default schema can be accomplished using the same command, replacing "MIMICIII" with your username.


--------------------------------------------------------
--  DDL for Table ADMISSIONS
--------------------------------------------------------

  CREATE TABLE "ADMISSIONS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ADMITTIME" DATE,
	"DISCHTIME" DATE,
	"DEATHTIME" DATE,
	"ADMISSION_TYPE" VARCHAR2(25),
	"ADMISSION_LOCATION" VARCHAR2(25),
	"DISCHARGE_LOCATION" VARCHAR2(30),
	"INSURANCE" VARCHAR2(255),
	"LANGUAGE" VARCHAR2(4),
	"RELIGION" VARCHAR2(25),
	"MARITAL_STATUS" VARCHAR2(25),
	"ETHNICITY" VARCHAR2(80),
	"EDREGTIME" DATE,
	"EDOUTTIME" DATE,
	"DIAGNOSIS" VARCHAR2(200),
	"HOSPITAL_EXPIRE_FLAG" NUMBER(1,0),
	"HAS_CHARTEVENTS_DATA" NUMBER(1,0)
   );

--------------------------------------------------------
--  DDL for Table CALLOUT
--------------------------------------------------------

  CREATE TABLE "CALLOUT"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"SUBMIT_WARDID" NUMBER(5,0),
	"SUBMIT_CAREUNIT" VARCHAR2(15),
	"CURR_WARDID" NUMBER(5,0),
	"CURR_CAREUNIT" VARCHAR2(15),
	"CALLOUT_WARDID" NUMBER(5,0),
	"CALLOUT_SERVICE" VARCHAR2(10),
	"REQUEST_TELE" NUMBER(3,0),
	"REQUEST_RESP" NUMBER(3,0),
	"REQUEST_CDIFF" NUMBER(3,0),
	"REQUEST_MRSA" NUMBER(3,0),
	"REQUEST_VRE" NUMBER(3,0),
	"CALLOUT_STATUS" VARCHAR2(20),
	"CALLOUT_OUTCOME" VARCHAR2(20),
	"DISCHARGE_WARDID" NUMBER(5,0),
	"ACKNOWLEDGE_STATUS" VARCHAR2(20),
	"CREATETIME" DATE,
	"UPDATETIME" DATE,
	"ACKNOWLEDGETIME" DATE,
	"OUTCOMETIME" DATE,
	"FIRSTRESERVATIONTIME" DATE,
	"CURRENTRESERVATIONTIME" DATE
   );

--------------------------------------------------------
--  DDL for Table CAREGIVERS
--------------------------------------------------------

  CREATE TABLE "CAREGIVERS"
   (	"ROW_ID" NUMBER(5,0),
	"CGID" NUMBER(6,0),
	"LABEL" VARCHAR2(10),
	"DESCRIPTION" VARCHAR2(22)
   );

--------------------------------------------------------
--  DDL for Table CHARTEVENTS
--------------------------------------------------------

  CREATE TABLE "CHARTEVENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"ITEMID" NUMBER(7,0),
	"CHARTTIME" DATE,
	"STORETIME" DATE,
	"CGID" NUMBER(7,0),
	"VALUE" VARCHAR2(200),
	"VALUENUM" NUMBER,
	"VALUEUOM" VARCHAR2(20),
	"WARNING" NUMBER(1,0),
	"ERROR" NUMBER(1,0),
	"RESULTSTATUS" VARCHAR2(20),
	"STOPPED" VARCHAR2(20)
  )
  PARTITION BY RANGE(itemid)
(PARTITION chartevents_1 VALUES LESS THAN (210)
,PARTITION chartevents_2 VALUES LESS THAN (250)
,PARTITION chartevents_3 VALUES LESS THAN (614)
,PARTITION chartevents_4 VALUES LESS THAN (640)
,PARTITION chartevents_5 VALUES LESS THAN (742)
,PARTITION chartevents_6 VALUES LESS THAN (1800)
,PARTITION chartevents_7 VALUES LESS THAN (2700)
,PARTITION chartevents_8 VALUES LESS THAN (3700)
,PARTITION chartevents_9 VALUES LESS THAN (4700)
,PARTITION chartevents_10 VALUES LESS THAN (6000)
,PARTITION chartevents_11 VALUES LESS THAN (7000)
,PARTITION chartevents_12 VALUES LESS THAN (8000)
,PARTITION chartevents_13 VALUES LESS THAN (220074)
,PARTITION chartevents_14 VALUES LESS THAN (MAXVALUE));

--------------------------------------------------------
--  DDL for Table CPTEVENTS
--------------------------------------------------------

  CREATE TABLE "CPTEVENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"COSTCENTER" VARCHAR2(4),
	"CHARTDATE" DATE,
	"CPT_CD" VARCHAR2(5),
	"CPT_NUMBER" NUMBER(5,0),
	"CPT_SUFFIX" VARCHAR2(1),
	"TICKET_ID_SEQ" NUMBER(5,0),
	"SECTIONHEADER" VARCHAR2(30),
	"SUBSECTIONHEADER" VARCHAR2(180),
	"DESCRIPTION" VARCHAR2(100)
   );

--------------------------------------------------------
--  DDL for Table D_CPT
--------------------------------------------------------

  CREATE TABLE "D_CPT"
   (	"ROW_ID" NUMBER(5,0),
	"CATEGORY" NUMBER(1,0),
	"SECTIONRANGE" VARCHAR2(40 CHAR),
	"SECTIONHEADER" VARCHAR2(30),
	"SUBSECTIONRANGE" VARCHAR2(50),
	"SUBSECTIONHEADER" VARCHAR2(180),
	"CODESUFFIX" VARCHAR2(1),
	"MINCODEINSUBSECTION" NUMBER(5,0),
	"MAXCODEINSUBSECTION" NUMBER(5,0)
   );

--------------------------------------------------------
--  DDL for Table D_ICD_DIAGNOSES
--------------------------------------------------------

  CREATE TABLE "D_ICD_DIAGNOSES"
   (	"ROW_ID" NUMBER(5,0),
	"ICD9_CODE" VARCHAR2(6),
	"SHORT_TITLE" VARCHAR2(24),
	"LONG_TITLE" VARCHAR2(222)
   );

--------------------------------------------------------
--  DDL for Table D_ICD_PROCEDURES
--------------------------------------------------------

  CREATE TABLE "D_ICD_PROCEDURES"
   (	"ROW_ID" NUMBER(5,0),
	"ICD9_CODE" VARCHAR2(6),
	"SHORT_TITLE" VARCHAR2(24),
	"LONG_TITLE" VARCHAR2(222)
   );

--------------------------------------------------------
--  DDL for Table D_ITEMS
--------------------------------------------------------

  CREATE TABLE "D_ITEMS"
   (	"ROW_ID" NUMBER(10,0),
	"ITEMID" NUMBER(7,0),
	"LABEL" VARCHAR2(100),
	"ABBREVIATION" VARCHAR2(50),
	"DBSOURCE" VARCHAR2(12),
	"LINKSTO" VARCHAR2(30),
	"CATEGORY" VARCHAR2(50),
	"UNITNAME" VARCHAR2(50),
	"PARAM_TYPE" VARCHAR2(20),
	"CONCEPTID" NUMBER(7,0)
   );

--------------------------------------------------------
--  DDL for Table D_LABITEMS
--------------------------------------------------------

  CREATE TABLE "D_LABITEMS"
   (	"ROW_ID" NUMBER(5,0),
	"ITEMID" NUMBER(7,0),
	"LABEL" VARCHAR2(50),
	"FLUID" VARCHAR2(50),
	"CATEGORY" VARCHAR2(50),
	"LOINC_CODE" VARCHAR2(50)
   );

--------------------------------------------------------
--  DDL for Table DATETIMEEVENTS
--------------------------------------------------------

  CREATE TABLE "DATETIMEEVENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"ITEMID" NUMBER(7,0),
	"CHARTTIME" DATE,
	"STORETIME" DATE,
	"CGID" NUMBER(7,0),
	"VALUE" DATE,
	"VALUEUOM" VARCHAR2(20),
	"WARNING" NUMBER(1,0),
	"ERROR" NUMBER(1,0),
	"RESULTSTATUS" VARCHAR2(20),
	"STOPPED" VARCHAR2(20)
   );

--------------------------------------------------------
--  DDL for Table DIAGNOSES_ICD
--------------------------------------------------------

  CREATE TABLE "DIAGNOSES_ICD"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"SEQ_NUM" NUMBER(5,0),
	"ICD9_CODE" VARCHAR2(7)
   );

--------------------------------------------------------
--  DDL for Table DRGCODES
--------------------------------------------------------

  CREATE TABLE "DRGCODES"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"DRG_TYPE" VARCHAR2(4),
	"DRG_CODE" VARCHAR2(10),
	"DESCRIPTION" VARCHAR2(195),
	"DRG_SEVERITY" NUMBER(1,0),
	"DRG_MORTALITY" NUMBER(1,0)
   );

--------------------------------------------------------
--  DDL for Table ICUSTAYS
--------------------------------------------------------

  CREATE TABLE "ICUSTAYS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"DBSOURCE" VARCHAR2(10),
	"FIRST_CAREUNIT" VARCHAR2(15),
	"LAST_CAREUNIT" VARCHAR2(15),
	"FIRST_WARDID" NUMBER(5,0),
	"LAST_WARDID" NUMBER(5,0),
	"INTIME" DATE,
	"OUTTIME" DATE,
	"LOS" NUMBER
   );

--------------------------------------------------------
--  DDL for Table INPUTEVENTS_CV
--------------------------------------------------------

  CREATE TABLE "INPUTEVENTS_CV"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"CHARTTIME" DATE,
	"ITEMID" NUMBER(7,0),
	"AMOUNT" NUMBER(20,10),
	"AMOUNTUOM" VARCHAR2(20),
	"RATE" NUMBER(20,10),
	"RATEUOM" VARCHAR2(20),
	"STORETIME" DATE,
	"CGID" NUMBER(7,0),
	"ORDERID" NUMBER(10,0),
	"LINKORDERID" NUMBER(10,0),
	"STOPPED" VARCHAR2(20),
	"NEWBOTTLE" NUMBER(1,0),
	"ORIGINALAMOUNT" NUMBER(20,10),
	"ORIGINALAMOUNTUOM" VARCHAR2(20),
	"ORIGINALROUTE" VARCHAR2(20),
	"ORIGINALRATE" NUMBER(20,10),
	"ORIGINALRATEUOM" VARCHAR2(20),
	"ORIGINALSITE" VARCHAR2(20)
   );

--------------------------------------------------------
--  DDL for Table INPUTEVENTS_MV
--------------------------------------------------------

  CREATE TABLE "INPUTEVENTS_MV"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"STARTTIME" DATE,
	"ENDTIME" DATE,
	"ITEMID" NUMBER(7,0),
	"AMOUNT" NUMBER(20,10),
	"AMOUNTUOM" VARCHAR2(20),
	"RATE" NUMBER(20,10),
	"RATEUOM" VARCHAR2(20),
	"STORETIME" DATE,
	"CGID" NUMBER(7,0),
	"ORDERID" NUMBER(10,0),
	"LINKORDERID" NUMBER(10,0),
	"ORDERCATEGORYNAME" VARCHAR2(50),
	"SECONDARYORDERCATEGORYNAME" VARCHAR2(50),
	"ORDERCOMPONENTTYPEDESCRIPTION" VARCHAR2(100),
	"ORDERCATEGORYDESCRIPTION" VARCHAR2(30),
	"PATIENTWEIGHT" NUMBER(8,4),
	"TOTALAMOUNT" NUMBER(20,10),
	"TOTALAMOUNTUOM" VARCHAR2(50),
	"ISOPENBAG" NUMBER(1,0),
	"CONTINUEINNEXTDEPT" NUMBER(1,0),
	"CANCELREASON" NUMBER(1,0),
	"STATUSDESCRIPTION" VARCHAR2(20),
	"COMMENTS_EDITEDBY" VARCHAR2(50),
	"COMMENTS_CANCELEDBY" VARCHAR2(50),
	"COMMENTS_DATE" DATE,
	"ORIGINALAMOUNT" NUMBER(20,10),
	"ORIGINALRATE" NUMBER(20,10)
   );

--------------------------------------------------------
--  DDL for Table LABEVENTS
--------------------------------------------------------

  CREATE TABLE "LABEVENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ITEMID" NUMBER(7,0),
	"CHARTTIME" DATE,
	"VALUE" VARCHAR2(100),
	"VALUENUM" NUMBER,
	"VALUEUOM" VARCHAR2(10),
	"FLAG" VARCHAR2(10)
   );

--------------------------------------------------------
--  DDL for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

  CREATE TABLE "MICROBIOLOGYEVENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"CHARTDATE" DATE,
	"CHARTTIME" DATE,
	"SPEC_ITEMID" NUMBER(7,0),
	"SPEC_TYPE_DESC" VARCHAR2(60),
	"ORG_ITEMID" NUMBER(7,0),
	"ORG_NAME" VARCHAR2(70),
	"ISOLATE_NUM" NUMBER(1,0),
	"AB_ITEMID" NUMBER(7,0),
	"AB_NAME" VARCHAR2(20),
	"DILUTION_TEXT" VARCHAR2(6),
	"DILUTION_COMPARISON" VARCHAR2(10),
	"DILUTION_VALUE" NUMBER(3,0),
	"INTERPRETATION" VARCHAR2(1)
   );

--------------------------------------------------------
--  DDL for Table NOTEEVENTS
--------------------------------------------------------

  CREATE TABLE "NOTEEVENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"CHARTDATE" DATE,
	"CHARTTIME" DATE,
	"STORETIME" DATE,
	"CATEGORY" VARCHAR2(26),
	"DESCRIPTION" VARCHAR2(255),
	"CGID" NUMBER(7,0),
	"ISERROR" CHAR(1),
	"TEXT" CLOB
   );

--------------------------------------------------------
--  DDL for Table OUTPUTEVENTS
--------------------------------------------------------

  CREATE TABLE "OUTPUTEVENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"CHARTTIME" DATE,
	"ITEMID" NUMBER(7,0),
	"VALUE" NUMBER(20,10),
	"VALUEUOM" VARCHAR2(20),
	"STORETIME" DATE,
	"CGID" NUMBER(7,0),
	"STOPPED" VARCHAR2(20),
	"NEWBOTTLE" NUMBER(1,0),
	"ISERROR" NUMBER(1,0)
   );

--------------------------------------------------------
--  DDL for Table PATIENTS
--------------------------------------------------------

  CREATE TABLE "PATIENTS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"GENDER" VARCHAR2(1),
	"DOB" DATE,
	"DOD" DATE,
	"DOD_HOSP" DATE,
	"DOD_SSN" DATE,
	"EXPIRE_FLAG" NUMBER(1,0)
   );

--------------------------------------------------------
--  DDL for Table PRESCRIPTIONS
--------------------------------------------------------

  CREATE TABLE "PRESCRIPTIONS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"STARTDATE" DATE,
	"ENDDATE" DATE,
	"DRUG_TYPE" VARCHAR2(80),
	"DRUG" VARCHAR2(80),
	"DRUG_NAME_POE" VARCHAR2(80),
	"DRUG_NAME_GENERIC" VARCHAR2(50),
	"FORMULARY_DRUG_CD" VARCHAR2(90),
	"GSN" VARCHAR2(180),
	"NDC" VARCHAR2(90),
	"PROD_STRENGTH" VARCHAR2(90),
	"DOSE_VAL_RX" VARCHAR2(90),
	"DOSE_UNIT_RX" VARCHAR2(90),
	"FORM_VAL_DISP" VARCHAR2(90),
	"FORM_UNIT_DISP" VARCHAR2(90),
	"ROUTE" VARCHAR2(60)
   );

--------------------------------------------------------
--  DDL for Table PROCEDUREEVENTS_MV
--------------------------------------------------------

  CREATE TABLE "PROCEDUREEVENTS_MV"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"STARTTIME" DATE,
	"ENDTIME" DATE,
	"ITEMID" NUMBER(7,0),
	"VALUE" NUMBER(20,10),
	"VALUEUOM" VARCHAR2(20),
	"LOCATION" VARCHAR2(100),
	"LOCATIONCATEGORY" VARCHAR2(50),
	"STORETIME" DATE,
	"CGID" NUMBER(7,0),
	"ORDERID" NUMBER(10,0),
	"LINKORDERID" NUMBER(10,0),
	"ORDERCATEGORYNAME" VARCHAR2(50),
	"SECONDARYORDERCATEGORYNAME" VARCHAR2(50),
	"ORDERCATEGORYDESCRIPTION" VARCHAR2(30),
	"ISOPENBAG" NUMBER(1,0),
	"CONTINUEINNEXTDEPT" NUMBER(1,0),
	"CANCELREASON" NUMBER(1,0),
	"STATUSDESCRIPTION" VARCHAR2(20),
	"COMMENTS_EDITEDBY" VARCHAR2(50),
	"COMMENTS_CANCELEDBY" VARCHAR2(50),
	"COMMENTS_DATE" DATE
   );

--------------------------------------------------------
--  DDL for Table PROCEDURES_ICD
--------------------------------------------------------

  CREATE TABLE "PROCEDURES_ICD"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"SEQ_NUM" NUMBER(3,0),
	"ICD9_CODE" VARCHAR2(10)
   );

--------------------------------------------------------
--  DDL for Table SERVICES
--------------------------------------------------------

  CREATE TABLE "SERVICES"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"TRANSFERTIME" DATE,
	"PREV_SERVICE" VARCHAR2(10),
	"CURR_SERVICE" VARCHAR2(10)
   );

--------------------------------------------------------
--  DDL for Table TRANSFERS
--------------------------------------------------------

  CREATE TABLE "TRANSFERS"
   (	"ROW_ID" NUMBER(10,0),
	"SUBJECT_ID" NUMBER(7,0),
	"HADM_ID" NUMBER(7,0),
	"ICUSTAY_ID" NUMBER(7,0),
	"DBSOURCE" VARCHAR2(10),
	"EVENTTYPE" VARCHAR2(10),
	"PREV_CAREUNIT" VARCHAR2(15),
	"CURR_CAREUNIT" VARCHAR2(15),
	"PREV_WARDID" NUMBER(5,0),
	"CURR_WARDID" NUMBER(5,0),
	"INTIME" DATE,
	"OUTTIME" DATE,
	"LOS" NUMBER
   );
