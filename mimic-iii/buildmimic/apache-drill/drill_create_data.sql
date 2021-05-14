-- ------------------------------------------------------------------
-- Title: Create the MIMIC-III tables
-- Description: More detailed description explaining the purpose.
-- ------------------------------------------------------------------



-- run queries one by one



--------------------------------------------------------
--  DDL for Table ADMISSIONS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`ADMISSIONS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when ADMITTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(ADMITTIME as TIMESTAMP(0)) end as ADMITTIME,
case when DISCHTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(DISCHTIME as TIMESTAMP(0)) end as DISCHTIME,
case when DEATHTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(DEATHTIME as TIMESTAMP(0)) end as DEATHTIME,
ADMISSION_TYPE,
ADMISSION_LOCATION,
DISCHARGE_LOCATION,
INSURANCE,
`LANGUAGE`,
RELIGION,
MARITAL_STATUS,
ETHNICITY,
case when EDREGTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(EDREGTIME as TIMESTAMP(0)) end as EDREGTIME,
case when EDOUTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(EDOUTTIME as TIMESTAMP(0)) end as EDOUTTIME,
DIAGNOSIS,
case when HOSPITAL_EXPIRE_FLAG = '' then cast(NULL as INT) else cast(HOSPITAL_EXPIRE_FLAG as INT) end as HOSPITAL_EXPIRE_FLAG,
case when HAS_CHARTEVENTS_DATA = '' then cast(NULL as INT ) else cast(HAS_CHARTEVENTS_DATA as INT) end as HAS_CHARTEVENTS_DATA
FROM dfs.tmp.`ADMISSIONS.csv` ;

--------------------------------------------------------
--  DDL for Table CALLOUT
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`CALLOUT` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when SUBMIT_WARDID = '' then cast(NULL as INT) else cast(SUBMIT_WARDID as INT) end as SUBMIT_WARDID,
SUBMIT_CAREUNIT,
case when CURR_WARDID = '' then cast(NULL as INT) else cast(CURR_WARDID as INT) end as CURR_WARDID,
CURR_CAREUNIT,
case when CALLOUT_WARDID = '' then cast(NULL as INT) else cast(CALLOUT_WARDID as INT) end as CALLOUT_WARDID,
CALLOUT_SERVICE,
case when REQUEST_TELE = '' then cast(NULL as INT ) else cast(REQUEST_TELE as INT) end as REQUEST_TELE,
case when REQUEST_RESP = '' then cast(NULL as INT ) else cast(REQUEST_RESP as INT) end as REQUEST_RESP,
case when REQUEST_CDIFF = '' then cast(NULL as INT ) else cast(REQUEST_CDIFF as INT) end as REQUEST_CDIFF,
case when REQUEST_MRSA = '' then cast(NULL as INT ) else cast(REQUEST_MRSA as INT) end as REQUEST_MRSA,
case when REQUEST_VRE = '' then cast(NULL as INT ) else cast(REQUEST_VRE as INT) end as REQUEST_VRE,
CALLOUT_STATUS,
CALLOUT_OUTCOME,
case when DISCHARGE_WARDID = '' then cast(NULL as INT) else cast(DISCHARGE_WARDID as INT) end as DISCHARGE_WARDID,
ACKNOWLEDGE_STATUS,
case when CREATETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CREATETIME as TIMESTAMP(0)) end as CREATETIME,
case when UPDATETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(UPDATETIME as TIMESTAMP(0)) end as UPDATETIME,
case when ACKNOWLEDGETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(ACKNOWLEDGETIME as TIMESTAMP(0)) end as ACKNOWLEDGETIME,
case when OUTCOMETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(OUTCOMETIME as TIMESTAMP(0)) end as OUTCOMETIME,
case when FIRSTRESERVATIONTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(FIRSTRESERVATIONTIME as TIMESTAMP(0)) end as FIRSTRESERVATIONTIME,
case when CURRENTRESERVATIONTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CURRENTRESERVATIONTIME as TIMESTAMP(0)) end as CURRENTRESERVATIONTIME
FROM dfs.tmp.`CALLOUT.csv`;

--------------------------------------------------------
--  DDL for Table CAREGIVERS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`CAREGIVERS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when CGID = '' then cast(NULL as INT ) else cast(CGID as INT) end as CGID,
LABEL,
DESCRIPTION
FROM dfs.tmp.`CAREGIVERS.csv`;

--------------------------------------------------------
--  DDL for Table CHARTEVENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`CHARTEVENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
case when ITEMID = '' then cast(NULL as INT) else cast(ITEMID as INT) end as ITEMID,
case when CHARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTTIME as TIMESTAMP(0)) end as CHARTTIME,
case when STORETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STORETIME as TIMESTAMP(0)) end as STORETIME,
case when CGID = '' then cast(NULL as INT) else cast(CGID as INT) end as CGID,
`VALUE`,
case when VALUENUM = '' then cast(NULL as DOUBLE ) else cast(VALUENUM as DOUBLE) end as VALUENUM,
VALUEUOM,
case when WARNING = '' then cast(NULL as INT) else cast(WARNING as INT) end as WARNING,
case when ERROR = '' then cast(NULL as INT) else cast(ERROR as INT) end as ERROR,
RESULTSTATUS,
STOPPED
FROM dfs.tmp.`CHARTEVENTS.csv`;



--------------------------------------------------------
--  DDL for Table CPTEVENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`CPTEVENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
COSTCENTER,
case when CHARTDATE = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTDATE as TIMESTAMP(0)) end as CHARTDATE,
CPT_CD,
case when CPT_NUMBER = '' then cast(NULL as INT) else cast(CPT_NUMBER as INT) end as CPT_NUMBER,
CPT_SUFFIX,
case when TICKET_ID_SEQ = '' then cast(NULL as INT) else cast(TICKET_ID_SEQ as INT) end as TICKET_ID_SEQ,
SECTIONHEADER,
SUBSECTIONHEADER,
DESCRIPTION
FROM dfs.tmp.`CPTEVENTS.csv`;

--------------------------------------------------------
--  DDL for Table DATETIMEEVENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`DATETIMEEVENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
case when ITEMID = '' then cast(NULL as INT ) else cast(ITEMID as INT) end as ITEMID,
case when CHARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTTIME as TIMESTAMP(0)) end as CHARTTIME,
case when STORETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STORETIME as TIMESTAMP(0)) end as STORETIME,
case when CGID = '' then cast(NULL as INT ) else cast(CGID as INT) end as CGID,
case when `VALUE` = '' then cast(NULL as TIMESTAMP(0)) else cast(`VALUE` as TIMESTAMP(0)) end as `VALUE`,
VALUEUOM,
case when WARNING = '' then cast(NULL as INT) else cast(WARNING as INT) end as WARNING,
case when ERROR = '' then cast(NULL as INT) else cast(ERROR as INT) end as ERROR,
RESULTSTATUS,
STOPPED
FROM dfs.tmp.`DATETIMEEVENTS.csv`;

--------------------------------------------------------
--  DDL for Table DIAGNOSES_ICD
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`DIAGNOSES_ICD` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when SEQ_NUM = '' then cast(NULL as INT) else cast(SEQ_NUM as INT) end as SEQ_NUM,
ICD9_CODE
FROM dfs.tmp.`DIAGNOSES_ICD.csv`;

--------------------------------------------------------
--  DDL for Table DRGCODES
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`DRGCODES` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
DRG_TYPE,
DRG_CODE,
DESCRIPTION,
case when DRG_SEVERITY = '' then cast(NULL as INT) else cast(DRG_SEVERITY as INT) end as DRG_SEVERITY,
case when DRG_MORTALITY = '' then cast(NULL as INT) else cast(DRG_MORTALITY as INT) end as DRG_MORTALITY
FROM dfs.tmp.`DRGCODES.csv`;

--------------------------------------------------------
--  DDL for Table D_CPT
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`D_CPT` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when CATEGORY = '' then cast(NULL as INT ) else cast(CATEGORY as INT) end as CATEGORY,
SECTIONRANGE,
SECTIONHEADER,
SUBSECTIONRANGE,
SUBSECTIONHEADER,
CODESUFFIX,
case when MINCODEINSUBSECTION = '' then cast(NULL as INT ) else cast(MINCODEINSUBSECTION as INT) end as MINCODEINSUBSECTION,
case when MAXCODEINSUBSECTION = '' then cast(NULL as INT ) else cast(MAXCODEINSUBSECTION as INT) end as MAXCODEINSUBSECTION
FROM dfs.tmp.`D_CPT.csv`;

--------------------------------------------------------
--  DDL for Table D_ICD_DIAGNOSES
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`D_ICD_DIAGNOSES` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
ICD9_CODE,
SHORT_TITLE,
LONG_TITLE
FROM dfs.tmp.`D_ICD_DIAGNOSES.csv`;

--------------------------------------------------------
--  DDL for Table D_ICD_PROCEDURES
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`D_ICD_PROCEDURES` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
ICD9_CODE,
SHORT_TITLE,
LONG_TITLE
FROM dfs.tmp.`D_ICD_PROCEDURES.csv`;

--------------------------------------------------------
--  DDL for Table D_ITEMS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`D_ITEMS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when ITEMID = '' then cast(NULL as INT ) else cast(ITEMID as INT) end as ITEMID,
LABEL,
ABBREVIATION,
DBSOURCE,
LINKSTO,
CATEGORY,
UNITNAME,
PARAM_TYPE,
case when CONCEPTID = '' then cast(NULL as INT) else cast(CONCEPTID as INT) end as CONCEPTID
FROM dfs.tmp.`D_ITEMS.csv`;

--------------------------------------------------------
--  DDL for Table D_LABITEMS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`D_LABITEMS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when ITEMID = '' then cast(NULL as INT ) else cast(ITEMID as INT) end as ITEMID,
LABEL,
FLUID,
CATEGORY,
LOINC_CODE
FROM dfs.tmp.`D_LABITEMS.csv`;

--------------------------------------------------------
--  DDL for Table ICUSTAYS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`ICUSTAYS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT ) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
DBSOURCE,
FIRST_CAREUNIT,
LAST_CAREUNIT,
case when FIRST_WARDID = '' then cast(NULL as INT ) else cast(FIRST_WARDID as INT) end as FIRST_WARDID,
case when LAST_WARDID = '' then cast(NULL as INT ) else cast(LAST_WARDID as INT) end as LAST_WARDID,
case when INTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(INTIME as TIMESTAMP(0)) end as INTIME,
case when OUTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(OUTTIME as TIMESTAMP(0)) end as OUTTIME,
case when LOS = '' then cast(NULL as DOUBLE ) else cast(LOS as DOUBLE) end as LOS
FROM dfs.tmp.`ICUSTAYS.csv`;

--------------------------------------------------------
--  DDL for Table INPUTEVENTS_CV
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`INPUTEVENTS_CV` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
case when CHARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTTIME as TIMESTAMP(0)) end as CHARTTIME,
case when ITEMID = '' then cast(NULL as INT) else cast(ITEMID as INT) end as ITEMID,
case when AMOUNT = '' then cast(NULL as DOUBLE ) else cast(AMOUNT as DOUBLE) end as AMOUNT,
AMOUNTUOM,
case when RATE = '' then cast(NULL as DOUBLE ) else cast(RATE as DOUBLE) end as RATE,
RATEUOM,
case when STORETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STORETIME as TIMESTAMP(0)) end as STORETIME,
case when CGID = '' then cast(NULL as INT) else cast(CGID as INT) end as CGID,
case when ORDERID = '' then cast(NULL as INT) else cast(ORDERID as INT) end as ORDERID,
case when LINKORDERID = '' then cast(NULL as INT) else cast(LINKORDERID as INT) end as LINKORDERID,
STOPPED,
case when NEWBOTTLE = '' then cast(NULL as INT) else cast(NEWBOTTLE as INT) end as NEWBOTTLE,
case when ORIGINALAMOUNT = '' then cast(NULL as DOUBLE ) else cast(ORIGINALAMOUNT as DOUBLE) end as ORIGINALAMOUNT,
ORIGINALAMOUNTUOM,
ORIGINALROUTE,
case when ORIGINALRATE = '' then cast(NULL as DOUBLE ) else cast(ORIGINALRATE as DOUBLE) end as ORIGINALRATE,
ORIGINALRATEUOM,
ORIGINALSITE
FROM dfs.tmp.`INPUTEVENTS_CV.csv`;

--------------------------------------------------------
--  DDL for Table INPUTEVENTS_MV
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`INPUTEVENTS_MV` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
case when STARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STARTTIME as TIMESTAMP(0)) end as STARTTIME,
case when ENDTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(ENDTIME as TIMESTAMP(0)) end as ENDTIME,
case when ITEMID = '' then cast(NULL as INT) else cast(ITEMID as INT) end as ITEMID,
case when AMOUNT = '' then cast(NULL as DOUBLE ) else cast(AMOUNT as DOUBLE) end as AMOUNT,
AMOUNTUOM,
case when RATE = '' then cast(NULL as DOUBLE ) else cast(RATE as DOUBLE) end as RATE,
RATEUOM,
case when STORETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STORETIME as TIMESTAMP(0)) end as STORETIME,
case when CGID = '' then cast(NULL as INT) else cast(CGID as INT) end as CGID,
case when ORDERID = '' then cast(NULL as INT) else cast(ORDERID as INT) end as ORDERID,
case when LINKORDERID = '' then cast(NULL as INT) else cast(LINKORDERID as INT) end as LINKORDERID,
ORDERCATEGORYNAME,
SECONDARYORDERCATEGORYNAME,
ORDERCOMPONENTTYPEDESCRIPTION,
ORDERCATEGORYDESCRIPTION,
case when PATIENTWEIGHT = '' then cast(NULL as DOUBLE ) else cast(PATIENTWEIGHT as DOUBLE) end as PATIENTWEIGHT,
case when TOTALAMOUNT = '' then cast(NULL as DOUBLE ) else cast(TOTALAMOUNT as DOUBLE) end as TOTALAMOUNT,
TOTALAMOUNTUOM,
case when ISOPENBAG = '' then cast(NULL as INT) else cast(ISOPENBAG as INT) end as ISOPENBAG,
case when CONTINUEINNEXTDEPT = '' then cast(NULL as INT) else cast(CONTINUEINNEXTDEPT as INT) end as CONTINUEINNEXTDEPT,
case when CANCELREASON = '' then cast(NULL as INT) else cast(CANCELREASON as INT) end as CANCELREASON,
STATUSDESCRIPTION,
COMMENTS_EDITEDBY,
COMMENTS_CANCELEDBY,
case when COMMENTS_DATE = '' then cast(NULL as TIMESTAMP(0)) else cast(COMMENTS_DATE as TIMESTAMP(0)) end as COMMENTS_DATE,
case when ORIGINALAMOUNT = '' then cast(NULL as DOUBLE ) else cast(ORIGINALAMOUNT as DOUBLE) end as ORIGINALAMOUNT,
case when ORIGINALRATE = '' then cast(NULL as DOUBLE ) else cast(ORIGINALRATE as DOUBLE) end as ORIGINALRATE
FROM dfs.tmp.`INPUTEVENTS_MV.csv`;

--------------------------------------------------------
--  DDL for Table LABEVENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`LABEVENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when ITEMID = '' then cast(NULL as INT ) else cast(ITEMID as INT) end as ITEMID,
case when CHARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTTIME as TIMESTAMP(0)) end as CHARTTIME,
`VALUE`,
case when VALUENUM = '' then cast(NULL as DOUBLE ) else cast(VALUENUM as DOUBLE) end as VALUENUM,
VALUEUOM,
FLAG
FROM dfs.tmp.`LABEVENTS.csv`;

--------------------------------------------------------
--  DDL for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`MICROBIOLOGYEVENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when CHARTDATE = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTDATE as TIMESTAMP(0)) end as CHARTDATE,
case when CHARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTTIME as TIMESTAMP(0)) end as CHARTTIME,
case when SPEC_ITEMID = '' then cast(NULL as INT) else cast(SPEC_ITEMID as INT) end as SPEC_ITEMID,
SPEC_TYPE_DESC,
case when ORG_ITEMID = '' then cast(NULL as INT) else cast(ORG_ITEMID as INT) end as ORG_ITEMID,
ORG_NAME,
case when ISOLATE_NUM = '' then cast(NULL as INT) else cast(ISOLATE_NUM as INT) end as ISOLATE_NUM,
case when AB_ITEMID = '' then cast(NULL as INT) else cast(AB_ITEMID as INT) end as AB_ITEMID,
AB_NAME,
DILUTION_TEXT,
DILUTION_COMPARISON,
case when DILUTION_VALUE = '' then cast(NULL as DOUBLE ) else cast(DILUTION_VALUE as DOUBLE) end as DILUTION_VALUE,
INTERPRETATION
FROM dfs.tmp.`MICROBIOLOGYEVENTS.csv`;

--------------------------------------------------------
--  DDL for Table NOTEEVENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`NOTEEVENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when CHARTDATE = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTDATE as TIMESTAMP(0)) end as CHARTDATE,
case when CHARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTTIME as TIMESTAMP(0)) end as CHARTTIME,
case when STORETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STORETIME as TIMESTAMP(0)) end as STORETIME,
CATEGORY,
DESCRIPTION,
case when CGID = '' then cast(NULL as INT) else cast(CGID as INT) end as CGID,
case when ISERROR = '' then cast(NULL as CHARACTER) else cast(ISERROR as CHARACTER) end as ISERROR,
`TEXT`
FROM dfs.tmp.`NOTEEVENTS.csv`;

--------------------------------------------------------
--  DDL for Table OUTPUTEVENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`OUTPUTEVENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
case when CHARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(CHARTTIME as TIMESTAMP(0)) end as CHARTTIME,
case when ITEMID = '' then cast(NULL as INT) else cast(ITEMID as INT) end as ITEMID,
case when `VALUE` = '' then cast(NULL as DOUBLE ) else cast(`VALUE` as DOUBLE) end as `VALUE`,
VALUEUOM,
case when STORETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STORETIME as TIMESTAMP(0)) end as STORETIME,
case when CGID = '' then cast(NULL as INT) else cast(CGID as INT) end as CGID,
STOPPED,
case when NEWBOTTLE = '' then cast(NULL as CHAR) else cast(NEWBOTTLE as CHAR) end as NEWBOTTLE,
case when ISERROR = '' then cast(NULL as INT) else cast(ISERROR as INT) end as ISERROR
FROM dfs.tmp.`OUTPUTEVENTS.csv`;

--------------------------------------------------------
--  DDL for Table PATIENTS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`PATIENTS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
GENDER,
case when DOB = '' then cast(NULL as TIMESTAMP(0)) else cast(DOB as TIMESTAMP(0)) end as DOB,
case when DOD = '' then cast(NULL as TIMESTAMP(0)) else cast(DOD as TIMESTAMP(0)) end as DOD,
case when DOD_HOSP = '' then cast(NULL as TIMESTAMP(0)) else cast(DOD_HOSP as TIMESTAMP(0)) end as DOD_HOSP,
case when DOD_SSN = '' then cast(NULL as TIMESTAMP(0)) else cast(DOD_SSN as TIMESTAMP(0)) end as DOD_SSN,
EXPIRE_FLAG
FROM dfs.tmp.`PATIENTS.csv`;

--------------------------------------------------------
--  DDL for Table PRESCRIPTIONS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`PRESCRIPTIONS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
case when STARTDATE = '' then cast(NULL as TIMESTAMP(0)) else cast(STARTDATE as TIMESTAMP(0)) end as STARTDATE,
case when ENDDATE = '' then cast(NULL as TIMESTAMP(0)) else cast(ENDDATE as TIMESTAMP(0)) end as ENDDATE,
DRUG_TYPE,
DRUG,
DRUG_NAME_POE,
DRUG_NAME_GENERIC,
FORMULARY_DRUG_CD GSN,
NDC,
PROD_STRENGTH,
DOSE_VAL_RX,
DOSE_UNIT_RX,
FORM_VAL_DISP,
FORM_UNIT_DISP,
ROUTE
FROM dfs.tmp.`PRESCRIPTIONS.csv`;


--------------------------------------------------------
--  DDL for Table PROCEDUREEVENTS_MV
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`PROCEDUREEVENTS_MV` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
case when STARTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STARTTIME as TIMESTAMP(0)) end as STARTTIME,
case when ENDTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(ENDTIME as TIMESTAMP(0)) end as ENDTIME,
case when ITEMID = '' then cast(NULL as INT) else cast(ITEMID as INT) end as ITEMID,
case when `VALUE` = '' then cast(NULL as DOUBLE ) else cast(`VALUE` as DOUBLE) end as `VALUE`,
VALUEUOM,
LOCATION,
LOCATIONCATEGORY,
case when STORETIME = '' then cast(NULL as TIMESTAMP(0)) else cast(STORETIME as TIMESTAMP(0)) end as STORETIME,
case when CGID = '' then cast(NULL as INT) else cast(CGID as INT) end as CGID,
case when ORDERID = '' then cast(NULL as INT) else cast(ORDERID as INT) end as ORDERID,
case when LINKORDERID = '' then cast(NULL as INT) else cast(LINKORDERID as INT) end as LINKORDERID,
ORDERCATEGORYNAME,
SECONDARYORDERCATEGORYNAME,
ORDERCATEGORYDESCRIPTION,
case when ISOPENBAG = '' then cast(NULL as INT) else cast(ISOPENBAG as INT) end as ISOPENBAG,
case when CONTINUEINNEXTDEPT = '' then cast(NULL as INT) else cast(CONTINUEINNEXTDEPT as INT) end as CONTINUEINNEXTDEPT,
case when CANCELREASON = '' then cast(NULL as INT) else cast(CANCELREASON as INT) end as CANCELREASON,
STATUSDESCRIPTION,
COMMENTS_EDITEDBY,
COMMENTS_CANCELEDBY,
case when COMMENTS_DATE = '' then cast(NULL as TIMESTAMP(0)) else cast(COMMENTS_DATE as TIMESTAMP(0)) end as COMMENTS_DATE
FROM dfs.tmp.`PROCEDUREEVENTS_MV.csv`;

--------------------------------------------------------
--  DDL for Table PROCEDURES_ICD
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`PROCEDURES_ICD` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when SEQ_NUM = '' then cast(NULL as INT ) else cast(SEQ_NUM as INT) end as SEQ_NUM,
ICD9_CODE
FROM dfs.tmp.`PROCEDURES_ICD.csv`;

--------------------------------------------------------
--  DDL for Table SERVICES
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`SERVICES` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when TRANSFERTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(TRANSFERTIME as TIMESTAMP(0)) end as TRANSFERTIME,
PREV_SERVICE,
CURR_SERVICE
FROM dfs.tmp.`SERVICES.csv`;

--------------------------------------------------------
--  DDL for Table TRANSFERS
--------------------------------------------------------

CREATE TABLE dfs.mimiciii.`TRANSFERS` AS
SELECT
case when ROW_ID = '' then cast(NULL as INT ) else cast(ROW_ID as INT) end as ROW_ID,
case when SUBJECT_ID = '' then cast(NULL as INT ) else cast(SUBJECT_ID as INT) end as SUBJECT_ID,
case when HADM_ID = '' then cast(NULL as INT ) else cast(HADM_ID as INT) end as HADM_ID,
case when ICUSTAY_ID = '' then cast(NULL as INT) else cast(ICUSTAY_ID as INT) end as ICUSTAY_ID,
DBSOURCE,
EVENTTYPE,
PREV_CAREUNIT,
CURR_CAREUNIT,
case when PREV_WARDID = '' then cast(NULL as INT) else cast(PREV_WARDID as INT) end as PREV_WARDID,
case when CURR_WARDID = '' then cast(NULL as INT) else cast(CURR_WARDID as INT) end as CURR_WARDID,
case when INTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(INTIME as TIMESTAMP(0)) end as INTIME,
case when OUTTIME = '' then cast(NULL as TIMESTAMP(0)) else cast(OUTTIME as TIMESTAMP(0)) end as OUTTIME,
case when LOS = '' then cast(NULL as DOUBLE ) else cast(LOS as DOUBLE) end as LOS
FROM dfs.tmp.`TRANSFERS.csv`;
