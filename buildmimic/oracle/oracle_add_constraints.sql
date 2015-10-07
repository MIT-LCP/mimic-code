-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III constraints for Oracle.
-- 
-- ----------------------------------------------------------------

-- The below command defines the schema where the data should reside
ALTER SESSION SET CURRENT_SCHEMA = MIMICIII;

-- Restoring the default schema can be accomplished using the same command, replacing "MIMICIII" with your username.

--------------
--ADMISSIONS--
--------------

-- subject_id
ALTER TABLE ADMISSIONS
ADD CONSTRAINT admissions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-----------
--CALLOUT--
-----------

-- subject_id
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

---------------
--CHARTEVENTS--
---------------

-- subject_id
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- cgid
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

-- hadm_id
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_items(itemid);

-- icustay_id
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustayevents(icustay_id);

-------------
--CPTEVENTS--
-------------

-- subject_id
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

------------------
--DATETIMEEVENTS--
------------------

-- subject_id
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- cgid
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

-- hadm_id
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_items(itemid);

-- icustay_id
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustayevents(icustay_id);


-----------------
--DIAGNOSES_ICD--
-----------------

-- subject_id
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);
  
-- ICD9_code
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_icd9
  FOREIGN KEY (icd9_code)
  REFERENCES D_ICD_DIAGNOSES(icd9_code);

--------------
---DRGCODES---
--------------

-- subject_id
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-----------------
--ICUSTAYEVENTS--
-----------------

-- subject_id
ALTER TABLE ICUSTAYEVENTS
ADD CONSTRAINT icustayevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE ICUSTAYEVENTS
ADD CONSTRAINT icustayevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);


------------
--IOEVENTS--
------------

-- subject_id
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustayevents(icustay_id);

-- cgid
ALTER TABLE IOEVENTS
ADD CONSTRAINT ioevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

-------------
--LABEVENTS--
-------------

-- subject_id
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- item_id
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES d_labitems(itemid);

----------------------
--MICROBIOLOGYEVENTS--
----------------------

-- subject_id
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

--------------
--NOTEEVENTS--
--------------

-- subject_id
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- cgid
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

-----------------
--PRESCRIPTIONS--
-----------------

-- subject_id
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustayevents(icustay_id);

------------------
--PROCEDURES_ICD--
------------------

-- subject_id
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- ICD9_code
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_icd9
  FOREIGN KEY (icd9_code)
  REFERENCES D_ICD_PROCEDURES(icd9_code);

------------
--SERVICES--
------------

-- subject_id
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-------------
--TRANSFERS--
-------------

-- subject_id
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustayevents(icustay_id);
