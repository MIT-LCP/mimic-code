-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III indexes for MySQL.
--
-- These are indexes that were not automagically created as UNIQUE KEY
-- constraints in the define-load step as determined by csv2mysql.
-- They include non-unique keys and multi-column keys that are
-- semantically meaningful.
--
-- These index definitions should be taken as mere suggestions. Which
-- indexes make sense depend on the applications.
-- 
-- ----------------------------------------------------------------

-- The below command defines the schema where all the indexes are created
USE mimiciiiv13;
tee 2-index.log

-- -----------
-- ADMISSIONS
-- -----------

alter table ADMISSIONS
      add index ADMISSIONS_IDX01 (SUBJECT_ID,HADM_ID),
      add index ADMISSIONS_IDX02 (ADMITTIME, DISCHTIME, DEATHTIME),
      add index ADMISSIONS_IDX03 (ADMISSION_TYPE);

-- ---------
-- CALLOUT--
-- ---------

alter table CALLOUT
      add index CALLOUT_IDX01 (SUBJECT_ID, HADM_ID),
      add index CALLOUT_IDX02 (CURR_CAREUNIT),
      add index CALLOUT_IDX03 (CALLOUT_SERVICE),
      add index CALLOUT_IDX04 (CURR_WARDID, CALLOUT_WARDID, DISCHARGE_WARDID),
      add index CALLOUT_IDX05 (CALLOUT_STATUS, CALLOUT_OUTCOME),
      add index CALLOUT_IDX06 (CREATETIME, UPDATETIME, ACKNOWLEDGETIME, OUTCOMETIME);

-- -------------
-- CAREGIVERS
-- -------------

alter table CAREGIVERS
      add index CAREGIVERS_IDX01 (CGID, LABEL);

-- -------------
-- CHARTEVENTS
-- -------------
alter table CHARTEVENTS 
      add index CHARTEVENTS_idx01 (SUBJECT_ID, HADM_ID, ICUSTAY_ID),
      add index CHARTEVENTS_idx02 (ITEMID),
      add index CHARTEVENTS_idx03 (CHARTTIME, STORETIME),
      add index CHARTEVENTS_idx04 (CGID);

-- Perhaps not useful to index on just value? Index just for popular subset?
-- CREATE INDEX CHARTEVENTS_idx05 ON CHARTEVENTS (VALUE);

-- -------------
-- CPTEVENTS
-- -------------

alter table CPTEVENTS
      add index CPTEVENTS_idx01 (SUBJECT_ID, HADM_ID),
      add index CPTEVENTS_idx02  (CPT_CD, TICKET_ID_SEQ);

-- ---------
-- D_CPT
-- ---------

-- Table is 134 rows - doesn't need additional indexes.

-- ------------------
-- D_ICD_DIAGNOSES
-- ------------------

alter table D_ICD_DIAGNOSES
      add index D_ICD_DIAG_idx02 (SHORT_TITLE);

-- ------------------
-- D_ICD_PROCEDURES
-- ------------------

-- This index was already created as a UNIQUE KEY
-- alter table D_ICD_PROCEDURES
--       add index D_ICD_PROC_idx02 (SHORT_TITLE);

-- ---------
-- D_ITEMS
-- ---------

alter table D_ITEMS
      add index D_ITEMS_idx02 (LABEL(255), DBSOURCE),
      add index D_ITEMS_idx03 (CATEGORY);

-- -------------
-- D_LABITEMS
-- -------------

alter table D_LABITEMS
      add index D_LABITEMS_idx02 (LABEL, FLUID, CATEGORY),
      add index D_LABITEMS_idx03 (LOINC_CODE);

-- -----------------
-- DATETIMEEVENTS
-- -----------------

alter table DATETIMEEVENTS
      add index DATETIMEEVENTS_idx01 (SUBJECT_ID, HADM_ID, ICUSTAY_ID),
      add index DATETIMEEVENTS_idx02 (ITEMID),
      add index DATETIMEEVENTS_idx03 (CHARTTIME),
      add index DATETIMEEVENTS_idx04 (CGID),
      add index DATETIMEEVENTS_idx05 (VALUE);

-- ----------------
-- DIAGNOSES_ICD
-- ----------------

alter table DIAGNOSES_ICD 
      add index DIAGNOSES_ICD_idx01 (SUBJECT_ID, HADM_ID),
      add index DIAGNOSES_ICD_idx02 (ICD9_CODE, SEQ_NUM);

-- ------------
-- DRGCODES
-- ------------

alter table DRGCODES
      add index DRGCODES_idx01 (SUBJECT_ID, HADM_ID),
      add index DRGCODES_idx02 (DRG_CODE, DRG_TYPE),
      add index DRGCODES_idx03 (DESCRIPTION(255), DRG_SEVERITY);

-- ----------------
-- ICUSTAYS
-- ----------------

alter table ICUSTAYS
      add index ICUSTAYS_idx01 (SUBJECT_ID, HADM_ID),
      add index ICUSTAYS_idx02 (ICUSTAY_ID, DBSOURCE),
      add index ICUSTAYS_idx03 (LOS),
      add index ICUSTAYS_idx04 (FIRST_CAREUNIT),
      add index ICUSTAYS_idx05 (LAST_CAREUNIT);

-- --------------
-- INPUTEVENTS_CV
-- --------------

alter table INPUTEVENTS_CV
      add index INPUTEVENTS_CV_idx01 (SUBJECT_ID, HADM_ID),
      add index INPUTEVENTS_CV_idx03 (CHARTTIME, STORETIME),
      add index INPUTEVENTS_CV_idx04 (ITEMID),
      add index INPUTEVENTS_CV_idx05 (RATE),
      add index INPUTEVENTS_CV_idx06 (AMOUNT),
      add index INPUTEVENTS_CV_idx07 (CGID),
      add index INPUTEVENTS_CV_idx08 (LINKORDERID, ORDERID);

-- --------------
-- INPUTEVENTS_MV
-- --------------

alter table INPUTEVENTS_MV
      add index INPUTEVENTS_MV_idx01 (SUBJECT_ID, HADM_ID),
      add index INPUTEVENTS_MV_idx02 (ICUSTAY_ID),
      add index INPUTEVENTS_MV_idx03 (ENDTIME, STARTTIME),
      add index INPUTEVENTS_MV_idx04 (ITEMID),
      add index INPUTEVENTS_MV_idx05 (RATE),
      add index INPUTEVENTS_MV_idx06 (AMOUNT),
      add index INPUTEVENTS_MV_idx07 (CGID),
      add index INPUTEVENTS_MV_idx08 (LINKORDERID, ORDERID);

-- ------------
-- LABEVENTS
-- ------------

alter table LABEVENTS 
      add index LABEVENTS_idx01 (SUBJECT_ID, HADM_ID),
      add index LABEVENTS_idx02 (ITEMID),
      add index LABEVENTS_idx03 (CHARTTIME),
      add index LABEVENTS_idx04 (VALUE(255), VALUENUM);

-- --------------------
-- MICROBIOLOGYEVENTS
-- --------------------

alter table MICROBIOLOGYEVENTS 
      add index MICROBIOLOGYEVENTS_idx01 (SUBJECT_ID, HADM_ID),
      add index MICROBIOLOGYEVENTS_idx02 (CHARTDATE, CHARTTIME),
      add index MICROBIOLOGYEVENTS_idx03 (SPEC_ITEMID, ORG_ITEMID, AB_ITEMID);

-- -------------
-- NOTEEVENTS
-- -------------

alter table NOTEEVENTS
      add index NOTEEVENTS_idx01 (SUBJECT_ID, HADM_ID),
      add index NOTEEVENTS_idx02 (CHARTDATE),
      add index NOTEEVENTS_idx03 (CGID),
      add index NOTEEVENTS_idx05 (CATEGORY, DESCRIPTION);

-- --------------
-- OUTPUTEVENTS
-- --------------

alter table OUTPUTEVENTS
      add index OUTPUTEVENTS_idx01 (SUBJECT_ID, HADM_ID),
      add index OUTPUTEVENTS_idx02 (ICUSTAY_ID),
      add index OUTPUTEVENTS_idx03 (CHARTTIME, STORETIME),
      add index OUTPUTEVENTS_idx04 (ITEMID),
      add index OUTPUTEVENTS_idx05 (VALUE),
      add index OUTPUTEVENTS_idx06 (CGID);

-- -----------
-- PATIENTS
-- -----------

-- Note that SUBJECT_ID is already indexed as it is unique

alter table PATIENTS
      add index PATIENTS_idx01 (EXPIRE_FLAG);

-- ----------------
-- PRESCRIPTIONS
-- ----------------

alter table PRESCRIPTIONS
      add index PRESCRIPTIONS_idx01 (SUBJECT_ID, HADM_ID),
      add index PRESCRIPTIONS_idx02 (ICUSTAY_ID),
      add index PRESCRIPTIONS_idx03 (DRUG_TYPE),
      add index PRESCRIPTIONS_idx04 (DRUG),
      add index PRESCRIPTIONS_idx05 (STARTDATE, ENDDATE);

-- -----------------
-- PROCEDURES_MV
-- -----------------

alter table PROCEDUREEVENTS_MV
      add index PROCEDUREEVENTS_MV_idx01 (SUBJECT_ID, HADM_ID),
      add index PROCEDUREEVENTS_MV_idx02 (ICUSTAY_ID),
      add index PROCEDUREEVENTS_MV_idx03 (ITEMID),
      add index PROCEDUREEVENTS_MV_idx04 (CGID),
      add index PROCEDUREEVENTS_MV_idx05 (ORDERCATEGORYNAME);
      
-- -----------------
-- PROCEDURES_ICD
-- -----------------

alter table PROCEDURES_ICD
      add index PROCEDURES_ICD_idx01 (SUBJECT_ID, HADM_ID),
      add index PROCEDURES_ICD_idx02 (ICD9_CODE, SEQ_NUM);

-- -----------
-- SERVICES
-- -----------

alter table SERVICES
      add index SERVICES_idx01 (SUBJECT_ID, HADM_ID),
      add index SERVICES_idx02 (TRANSFERTIME),
      add index SERVICES_idx03 (CURR_SERVICE, PREV_SERVICE);

-- -----------
-- TRANSFERS
-- -----------

alter table TRANSFERS
      add index TRANSFERS_idx01 (SUBJECT_ID, HADM_ID),
      add index TRANSFERS_idx02 (ICUSTAY_ID),
      add index TRANSFERS_idx03 (CURR_CAREUNIT, PREV_CAREUNIT),
      add index TRANSFERS_idx04 (INTIME, OUTTIME),
      add index TRANSFERS_idx05 (LOS);

notee
