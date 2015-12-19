-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III constraints for Postgres.
-- 
-- ----------------------------------------------------------------

-- The below command defines the schema where the data should reside
use mimiciiiv12;
tee 3-constraints.log

-- Restoring the search path to its default value can be accomplished as follows:
--  SET search_path TO "$user",public;

-- ------------
-- ADMISSIONS--
-- ------------

-- subject_id
ALTER TABLE ADMISSIONS DROP FOREIGN KEY admissions_fk_subject_id;
ALTER TABLE ADMISSIONS
ADD CONSTRAINT admissions_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- ---------
-- CALLOUT--
-- ---------

-- subject_id
ALTER TABLE CALLOUT DROP FOREIGN KEY callout_fk_subject_id;
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE CALLOUT DROP FOREIGN KEY callout_fk_hadm_id;
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- -------------
-- CAREGIVERS --
-- -------------

-- No foreign keys

-- -------------
-- CHARTEVENTS--
-- -------------

-- subject_id
ALTER TABLE CHARTEVENTS DROP FOREIGN KEY chartevents_fk_subject_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- cgid
ALTER TABLE CHARTEVENTS DROP FOREIGN KEY chartevents_fk_cgid;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- hadm_id
ALTER TABLE CHARTEVENTS DROP FOREIGN KEY chartevents_fk_hadm_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- item_id
ALTER TABLE CHARTEVENTS DROP FOREIGN KEY chartevents_fk_itemid;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_itemid
  FOREIGN KEY (ITEMID)
  REFERENCES D_ITEMS(ITEMID);

-- icustay_id
ALTER TABLE CHARTEVENTS DROP FOREIGN KEY chartevents_fk_icustay_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- -----------
-- CPTEVENTS--
-- -----------

-- subject_id
ALTER TABLE CPTEVENTS DROP FOREIGN KEY cptevents_fk_subject_id;
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE CPTEVENTS DROP FOREIGN KEY cptevents_fk_hadm_id;
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ----------------
-- DATETIMEEVENTS--
-- ----------------

-- subject_id
ALTER TABLE DATETIMEEVENTS DROP FOREIGN KEY datetimeevents_fk_subject_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- cgid
ALTER TABLE DATETIMEEVENTS DROP FOREIGN KEY datetimeevents_fk_cgid;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- hadm_id
ALTER TABLE DATETIMEEVENTS DROP FOREIGN KEY datetimeevents_fk_hadm_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- item_id
ALTER TABLE DATETIMEEVENTS DROP FOREIGN KEY datetimeevents_fk_itemid;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_itemid
  FOREIGN KEY (ITEMID)
  REFERENCES D_ITEMS(ITEMID);

-- icustay_id
ALTER TABLE DATETIMEEVENTS DROP FOREIGN KEY datetimeevents_fk_icustay_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);


-- ---------------
-- DIAGNOSES_ICD--
-- ---------------

-- subject_id
ALTER TABLE DIAGNOSES_ICD DROP FOREIGN KEY diagnoses_icd_fk_subject_id;
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE DIAGNOSES_ICD DROP FOREIGN KEY diagnoses_icd_fk_hadm_id;
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);
  
-- ICD9_code
-- Cannot impose this constraint because icd9_code contains 143 codes not in c_icd_diagnoses
-- See https://github.com/MIT-LCP/mimic-code/issues/20
-- ALTER TABLE DIAGNOSES_ICD DROP FOREIGN KEY diagnoses_icd_fk_icd9;
-- ALTER TABLE DIAGNOSES_ICD
-- ADD CONSTRAINT diagnoses_icd_fk_icd9
--   FOREIGN KEY (ICD9_CODE)
--   REFERENCES D_ICD_DIAGNOSES(ICD9_CODE);

-- ------------
-- DRGCODES ---
-- ------------

-- subject_id
ALTER TABLE DRGCODES DROP FOREIGN KEY drgcodes_fk_subject_id;
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE DRGCODES DROP FOREIGN KEY drgcodes_fk_hadm_id;
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ---------------
-- ICUSTAYS--
-- ---------------

-- subject_id
ALTER TABLE ICUSTAYS DROP FOREIGN KEY icustays_fk_subject_id;
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE ICUSTAYS DROP FOREIGN KEY icustays_fk_hadm_id;
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ----------
-- INPUTEVENTS_CV--
-- ----------

-- subject_id
ALTER TABLE INPUTEVENTS_CV DROP FOREIGN KEY inputevents_cv_fk_subject_id;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE INPUTEVENTS_CV DROP FOREIGN KEY inputevents_cv_fk_hadm_id;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
ALTER TABLE INPUTEVENTS_CV DROP FOREIGN KEY inputevents_cv_fk_icustay_id;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
ALTER TABLE INPUTEVENTS_CV DROP FOREIGN KEY inputevents_cv_fk_cgid;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ----------
-- INPUTEVENTS_MV--
-- ----------

-- subject_id
ALTER TABLE INPUTEVENTS_MV DROP FOREIGN KEY inputevents_mv_fk_subject_id;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE INPUTEVENTS_MV DROP FOREIGN KEY inputevents_mv_fk_hadm_id;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
ALTER TABLE INPUTEVENTS_MV DROP FOREIGN KEY inputevents_mv_fk_icustay_id;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
ALTER TABLE INPUTEVENTS_MV DROP FOREIGN KEY inputevents_mv_fk_cgid;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- -----------
-- LABEVENTS--
-- -----------

-- subject_id
ALTER TABLE LABEVENTS DROP FOREIGN KEY labevents_fk_subject_id;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE LABEVENTS DROP FOREIGN KEY labevents_fk_hadm_id;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- item_id
ALTER TABLE LABEVENTS DROP FOREIGN KEY labevents_fk_itemid;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_itemid
  FOREIGN KEY (ITEMID)
  REFERENCES D_LABITEMS(ITEMID);

-- --------------------
-- MICROBIOLOGYEVENTS--
-- --------------------

-- subject_id
ALTER TABLE MICROBIOLOGYEVENTS DROP FOREIGN KEY microbiologyevents_fk_subject_id;
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE MICROBIOLOGYEVENTS DROP FOREIGN KEY microbiologyevents_fk_hadm_id;
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ------------
-- NOTEEVENTS--
-- ------------

-- subject_id
ALTER TABLE NOTEEVENTS DROP FOREIGN KEY noteevents_fk_subject_id;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE NOTEEVENTS DROP FOREIGN KEY noteevents_fk_hadm_id;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- cgid
ALTER TABLE NOTEEVENTS DROP FOREIGN KEY noteevents_fk_cgid;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ----------
-- OUTPUTEVENTS--
-- ----------

-- subject_id
ALTER TABLE OUTPUTEVENTS DROP FOREIGN KEY outputevents_fk_subject_id;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE OUTPUTEVENTS DROP FOREIGN KEY outputevents_fk_hadm_id;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
ALTER TABLE OUTPUTEVENTS DROP FOREIGN KEY outputevents_fk_icustay_id;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
ALTER TABLE OUTPUTEVENTS DROP FOREIGN KEY outputevents_fk_cgid;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ---------------
-- PRESCRIPTIONS--
-- ---------------

-- subject_id
ALTER TABLE PRESCRIPTIONS DROP FOREIGN KEY prescriptions_fk_subject_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE PRESCRIPTIONS DROP FOREIGN KEY prescriptions_fk_hadm_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
ALTER TABLE PRESCRIPTIONS DROP FOREIGN KEY prescriptions_fk_icustay_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- ----------------
-- PROCEDUREEVENTS_MV--
-- ----------------

-- subject_id
ALTER TABLE PROCEDUREEVENTS_MV DROP FOREIGN KEY procedureevents_mv_fk_subject_id;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE PROCEDUREEVENTS_MV DROP FOREIGN KEY procedureevents_mv_fk_hadm_id;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- itemid
ALTER TABLE PROCEDUREEVENTS_MV DROP FOREIGN KEY procedureevents_mv_fk_icustay_id;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
ALTER TABLE PROCEDUREEVENTS_MV DROP FOREIGN KEY procedureevents_mv_fk_cgid;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ----------------
-- PROCEDURES_ICD--
-- ----------------

-- subject_id
ALTER TABLE PROCEDURES_ICD DROP FOREIGN KEY procedures_icd_fk_subject_id;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE PROCEDURES_ICD DROP FOREIGN KEY procedures_icd_fk_hadm_id;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ICD9_code
-- Cannot impose this constraint because icd9_code contains 1238 codes not in c_icd_diagnoses
-- See https://github.com/MIT-LCP/mimic-code/issues/20, by analogy
-- ALTER TABLE PROCEDURES_ICD DROP FOREIGN KEY procedures_icd_fk_icd9;
-- ALTER TABLE PROCEDURES_ICD
-- ADD CONSTRAINT procedures_icd_fk_icd9
--   FOREIGN KEY (icd9_code)
--   REFERENCES d_icd_procedures(icd9_code);

-- ----------
-- SERVICES--
-- ----------

-- subject_id
ALTER TABLE SERVICES DROP FOREIGN KEY services_fk_subject_id;
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE SERVICES DROP FOREIGN KEY services_fk_hadm_id;
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- -----------
-- TRANSFERS--
-- -----------

-- subject_id
ALTER TABLE TRANSFERS DROP FOREIGN KEY transfers_fk_subject_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
ALTER TABLE TRANSFERS DROP FOREIGN KEY transfers_fk_hadm_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
ALTER TABLE TRANSFERS DROP FOREIGN KEY transfers_fk_icustay_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);
  
notee
