-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III constraints for Postgres.
--
-- ----------------------------------------------------------------

-- The below command defines the schema where the data should reside
SET search_path TO mimiciii;

-- Restoring the search path to its default value can be accomplished as follows:
--  SET search_path TO "$user",public;

--------------
--ADMISSIONS--
--------------

-- subject_id
ALTER TABLE ADMISSIONS DROP CONSTRAINT IF EXISTS admissions_fk_subject_id;
ALTER TABLE ADMISSIONS
ADD CONSTRAINT admissions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-----------
--CALLOUT--
-----------

-- subject_id
ALTER TABLE CALLOUT DROP CONSTRAINT IF EXISTS callout_fk_subject_id;
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE CALLOUT DROP CONSTRAINT IF EXISTS callout_fk_hadm_id;
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

---------------
--CHARTEVENTS--
---------------

-- subject_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT IF EXISTS chartevents_fk_subject_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- cgid
ALTER TABLE CHARTEVENTS DROP CONSTRAINT IF EXISTS chartevents_fk_cgid;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES caregivers(cgid);

-- hadm_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT IF EXISTS chartevents_fk_hadm_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT IF EXISTS chartevents_fk_itemid;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_items(itemid);

-- icustay_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT IF EXISTS chartevents_fk_icustay_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-------------
--CPTEVENTS--
-------------

-- subject_id
ALTER TABLE CPTEVENTS DROP CONSTRAINT IF EXISTS cptevents_fk_subject_id;
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE CPTEVENTS DROP CONSTRAINT IF EXISTS cptevents_fk_hadm_id;
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

------------------
--DATETIMEEVENTS--
------------------

-- subject_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT IF EXISTS datetimeevents_fk_subject_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- cgid
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT IF EXISTS datetimeevents_fk_cgid;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES caregivers(cgid);

-- hadm_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT IF EXISTS datetimeevents_fk_hadm_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT IF EXISTS datetimeevents_fk_itemid;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_items(itemid);

-- icustay_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT IF EXISTS datetimeevents_fk_icustay_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);


-----------------
--DIAGNOSES_ICD--
-----------------

-- subject_id
ALTER TABLE DIAGNOSES_ICD DROP CONSTRAINT IF EXISTS diagnoses_icd_fk_subject_id;
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE DIAGNOSES_ICD DROP CONSTRAINT IF EXISTS diagnoses_icd_fk_hadm_id;
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- -- ICD9_code
-- ALTER TABLE DIAGNOSES_ICD DROP CONSTRAINT IF EXISTS diagnoses_icd_fk_icd9;
-- ALTER TABLE DIAGNOSES_ICD
-- ADD CONSTRAINT diagnoses_icd_fk_icd9
--   FOREIGN KEY (icd9_code)
--   REFERENCES d_icd_diagnoses(icd9_code);

--------------
---DRGCODES---
--------------

-- subject_id
ALTER TABLE DRGCODES DROP CONSTRAINT IF EXISTS drgcodes_fk_subject_id;
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE DRGCODES DROP CONSTRAINT IF EXISTS drgcodes_fk_hadm_id;
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-----------------
--ICUSTAYS--
-----------------

-- subject_id
ALTER TABLE ICUSTAYS DROP CONSTRAINT IF EXISTS icustays_fk_subject_id;
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE ICUSTAYS DROP CONSTRAINT IF EXISTS icustays_fk_hadm_id;
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);


------------------
--INPUTEVENTS_CV--
------------------

-- subject_id
ALTER TABLE INPUTEVENTS_CV DROP CONSTRAINT IF EXISTS inputevents_cv_fk_subject_id;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE INPUTEVENTS_CV DROP CONSTRAINT IF EXISTS inputevents_cv_fk_hadm_id;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE INPUTEVENTS_CV DROP CONSTRAINT IF EXISTS inputevents_cv_fk_icustay_id;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE INPUTEVENTS_CV DROP CONSTRAINT IF EXISTS inputevents_cv_fk_cgid;
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);


------------------
--INPUTEVENTS_MV--
------------------

-- subject_id
ALTER TABLE INPUTEVENTS_MV DROP CONSTRAINT IF EXISTS inputevents_mv_fk_subject_id;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE INPUTEVENTS_MV DROP CONSTRAINT IF EXISTS inputevents_mv_fk_hadm_id;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE INPUTEVENTS_MV DROP CONSTRAINT IF EXISTS inputevents_mv_fk_icustay_id;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE INPUTEVENTS_MV DROP CONSTRAINT IF EXISTS inputevents_mv_fk_cgid;
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);


-------------
--LABEVENTS--
-------------

-- subject_id
ALTER TABLE LABEVENTS DROP CONSTRAINT IF EXISTS labevents_fk_subject_id;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE LABEVENTS DROP CONSTRAINT IF EXISTS labevents_fk_hadm_id;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE LABEVENTS DROP CONSTRAINT IF EXISTS labevents_fk_itemid;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_labitems(itemid);

----------------------
--MICROBIOLOGYEVENTS--
----------------------

-- subject_id
ALTER TABLE MICROBIOLOGYEVENTS DROP CONSTRAINT IF EXISTS microbiologyevents_fk_subject_id;
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE MICROBIOLOGYEVENTS DROP CONSTRAINT IF EXISTS microbiologyevents_fk_hadm_id;
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

--------------
--NOTEEVENTS--
--------------

-- subject_id
ALTER TABLE NOTEEVENTS DROP CONSTRAINT IF EXISTS noteevents_fk_subject_id;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE NOTEEVENTS DROP CONSTRAINT IF EXISTS noteevents_fk_hadm_id;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- cgid
ALTER TABLE NOTEEVENTS DROP CONSTRAINT IF EXISTS noteevents_fk_cgid;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);


----------------
--OUTPUTEVENTS--
----------------

-- subject_id
ALTER TABLE OUTPUTEVENTS DROP CONSTRAINT IF EXISTS outputevents_subject_id;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE OUTPUTEVENTS DROP CONSTRAINT IF EXISTS outputevents_hadm_id;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE OUTPUTEVENTS DROP CONSTRAINT IF EXISTS outputevents_icustay_id;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE OUTPUTEVENTS DROP CONSTRAINT IF EXISTS outputevents_cgid;
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);



-----------------
--PRESCRIPTIONS--
-----------------

-- subject_id
ALTER TABLE PRESCRIPTIONS DROP CONSTRAINT IF EXISTS prescriptions_fk_subject_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE PRESCRIPTIONS DROP CONSTRAINT IF EXISTS prescriptions_fk_hadm_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE PRESCRIPTIONS DROP CONSTRAINT IF EXISTS prescriptions_fk_icustay_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);


------------------
--PROCEDUREEVENTS_MV--
------------------

-- subject_id
ALTER TABLE PROCEDUREEVENTS_MV DROP CONSTRAINT IF EXISTS procedureevents_mv_fk_subject_id;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE PROCEDUREEVENTS_MV DROP CONSTRAINT IF EXISTS procedureevents_mv_fk_hadm_id;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE PROCEDUREEVENTS_MV DROP CONSTRAINT IF EXISTS procedureevents_mv_fk_icustay_id;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE PROCEDUREEVENTS_MV DROP CONSTRAINT IF EXISTS procedureevents_mv_fk_cgid;
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);


------------------
--PROCEDURES_ICD--
------------------

-- subject_id
ALTER TABLE PROCEDURES_ICD DROP CONSTRAINT IF EXISTS procedures_icd_fk_subject_id;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE PROCEDURES_ICD DROP CONSTRAINT IF EXISTS procedures_icd_fk_hadm_id;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- ICD9_code
ALTER TABLE PROCEDURES_ICD DROP CONSTRAINT IF EXISTS procedures_icd_fk_icd9;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_icd9
  FOREIGN KEY (icd9_code)
  REFERENCES d_icd_procedures(icd9_code);

------------
--SERVICES--
------------

-- subject_id
ALTER TABLE SERVICES DROP CONSTRAINT IF EXISTS services_fk_subject_id;
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE SERVICES DROP CONSTRAINT IF EXISTS services_fk_hadm_id;
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-------------
--TRANSFERS--
-------------

-- subject_id
ALTER TABLE TRANSFERS DROP CONSTRAINT IF EXISTS transfers_fk_subject_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE TRANSFERS DROP CONSTRAINT IF EXISTS transfers_fk_hadm_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE TRANSFERS DROP CONSTRAINT IF EXISTS transfers_fk_icustay_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);
