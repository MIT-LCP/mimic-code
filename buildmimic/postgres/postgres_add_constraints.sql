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
ALTER TABLE ADMISSIONS DROP CONSTRAINT admissions_fk_subject_id;
ALTER TABLE ADMISSIONS
ADD CONSTRAINT admissions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-----------
--CALLOUT--
-----------

-- subject_id
ALTER TABLE CALLOUT DROP CONSTRAINT callout_fk_subject_id;
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE CALLOUT DROP CONSTRAINT callout_fk_hadm_id;
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

---------------
--CHARTEVENTS--
---------------

-- subject_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT chartevents_fk_subject_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- cgid
ALTER TABLE CHARTEVENTS DROP CONSTRAINT chartevents_fk_cgid;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES caregivers(cgid);

-- hadm_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT chartevents_fk_hadm_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT chartevents_fk_itemid;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_items(itemid);

-- icustay_id
ALTER TABLE CHARTEVENTS DROP CONSTRAINT chartevents_fk_icustay_id;
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-------------
--CPTEVENTS--
-------------

-- subject_id
ALTER TABLE CPTEVENTS DROP CONSTRAINT cptevents_fk_subject_id;
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE CPTEVENTS DROP CONSTRAINT cptevents_fk_hadm_id;
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

------------------
--DATETIMEEVENTS--
------------------

-- subject_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT datetimeevents_fk_subject_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- cgid
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT datetimeevents_fk_cgid;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES caregivers(cgid);

-- hadm_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT datetimeevents_fk_hadm_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT datetimeevents_fk_itemid;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_items(itemid);

-- icustay_id
ALTER TABLE DATETIMEEVENTS DROP CONSTRAINT datetimeevents_fk_icustay_id;
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);


-----------------
--DIAGNOSES_ICD--
-----------------

-- subject_id
ALTER TABLE DIAGNOSES_ICD DROP CONSTRAINT diagnoses_icd_fk_subject_id;
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE DIAGNOSES_ICD DROP CONSTRAINT diagnoses_icd_fk_hadm_id;
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);
  
-- ICD9_code
ALTER TABLE DIAGNOSES_ICD DROP CONSTRAINT diagnoses_icd_fk_icd9;
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_icd9
  FOREIGN KEY (icd9_code)
  REFERENCES d_icd_diagnoses(icd9_code);

--------------
---DRGCODES---
--------------

-- subject_id
ALTER TABLE DRGCODES DROP CONSTRAINT drgcodes_fk_subject_id;
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE DRGCODES DROP CONSTRAINT drgcodes_fk_hadm_id;
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-----------------
--ICUSTAYS--
-----------------

-- subject_id
ALTER TABLE ICUSTAYS DROP CONSTRAINT icustays_fk_subject_id;
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE ICUSTAYS DROP CONSTRAINT icustays_fk_hadm_id;
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);


------------
--IOEVENTS--
------------

-- subject_id
ALTER TABLE IOEVENTS DROP CONSTRAINT ioevents_fk_subject_id;
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE IOEVENTS DROP CONSTRAINT ioevents_fk_hadm_id;
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE IOEVENTS DROP CONSTRAINT ioevents_fk_icustay_id;
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE IOEVENTS DROP CONSTRAINT ioevents_fk_cgid;
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

-------------
--LABEVENTS--
-------------

-- subject_id
ALTER TABLE LABEVENTS DROP CONSTRAINT labevents_fk_subject_id;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE LABEVENTS DROP CONSTRAINT labevents_fk_hadm_id;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE LABEVENTS DROP CONSTRAINT labevents_fk_itemid;
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_labitems(itemid);

----------------------
--MICROBIOLOGYEVENTS--
----------------------

-- subject_id
ALTER TABLE MICROBIOLOGYEVENTS DROP CONSTRAINT microbiologyevents_fk_subject_id;
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE MICROBIOLOGYEVENTS DROP CONSTRAINT microbiologyevents_fk_hadm_id;
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

--------------
--NOTEEVENTS--
--------------

-- subject_id
ALTER TABLE NOTEEVENTS DROP CONSTRAINT noteevents_fk_subject_id;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE NOTEEVENTS DROP CONSTRAINT noteevents_fk_hadm_id;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- cgid
ALTER TABLE NOTEEVENTS DROP CONSTRAINT noteevents_fk_cgid;
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

-----------------
--PRESCRIPTIONS--
-----------------

-- subject_id
ALTER TABLE PRESCRIPTIONS DROP CONSTRAINT prescriptions_fk_subject_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE PRESCRIPTIONS DROP CONSTRAINT prescriptions_fk_hadm_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE PRESCRIPTIONS DROP CONSTRAINT prescriptions_fk_icustay_id;
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

------------------
--PROCEDURES_ICD--
------------------

-- subject_id
ALTER TABLE PROCEDURES_ICD DROP CONSTRAINT procedures_icd_fk_subject_id;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE PROCEDURES_ICD DROP CONSTRAINT procedures_icd_fk_hadm_id;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- ICD9_code
ALTER TABLE PROCEDURES_ICD DROP CONSTRAINT procedures_icd_fk_icd9;
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_icd9
  FOREIGN KEY (icd9_code)
  REFERENCES d_icd_procedures(icd9_code);

------------
--SERVICES--
------------

-- subject_id
ALTER TABLE SERVICES DROP CONSTRAINT services_fk_subject_id;
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE SERVICES DROP CONSTRAINT services_fk_hadm_id;
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-------------
--TRANSFERS--
-------------

-- subject_id
ALTER TABLE TRANSFERS DROP CONSTRAINT transfers_fk_subject_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE TRANSFERS DROP CONSTRAINT transfers_fk_hadm_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE TRANSFERS DROP CONSTRAINT transfers_fk_icustay_id;
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);
  
