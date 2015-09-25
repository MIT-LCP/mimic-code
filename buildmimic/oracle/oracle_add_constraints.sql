-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III constraints for Oracle.
-- 
-- ----------------------------------------------------------------

--------------
--ADMISSIONS--
--------------

-- subject_id
ALTER TABLE MIMICIII.ADMISSIONS
ADD CONSTRAINT admissions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-----------
--CALLOUT--
-----------

-- subject_id
ALTER TABLE MIMICIII.CALLOUT
ADD CONSTRAINT callout_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.CALLOUT
ADD CONSTRAINT callout_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

---------------
--CHARTEVENTS--
---------------

-- subject_id
ALTER TABLE MIMICIII.CHARTEVENTS
ADD CONSTRAINT chartevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- cgid
ALTER TABLE MIMICIII.CHARTEVENTS
ADD CONSTRAINT chartevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES MIMICIII.CAREGIVERS(cgid);

-- hadm_id
ALTER TABLE MIMICIII.CHARTEVENTS
ADD CONSTRAINT chartevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- item_id
ALTER TABLE MIMICIII.CHARTEVENTS
ADD CONSTRAINT chartevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES MIMICIII.d_items(itemid);

-- icustay_id
ALTER TABLE MIMICIII.CHARTEVENTS
ADD CONSTRAINT chartevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES MIMICIII.icustayevents(icustay_id);

-------------
--CPTEVENTS--
-------------

-- subject_id
ALTER TABLE MIMICIII.CPTEVENTS
ADD CONSTRAINT cptevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.CPTEVENTS
ADD CONSTRAINT cptevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

------------------
--DATETIMEEVENTS--
------------------

-- subject_id
ALTER TABLE MIMICIII.DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- cgid
ALTER TABLE MIMICIII.DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES MIMICIII.CAREGIVERS(cgid);

-- hadm_id
ALTER TABLE MIMICIII.DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- item_id
ALTER TABLE MIMICIII.DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES MIMICIII.d_items(itemid);

-- icustay_id
ALTER TABLE MIMICIII.DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES MIMICIII.icustayevents(icustay_id);


-----------------
--DIAGNOSES_ICD--
-----------------

-- subject_id
ALTER TABLE MIMICIII.DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);
  
-- ICD9_code
ALTER TABLE MIMICIII.DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_icd9
  FOREIGN KEY (icd9_code)
  REFERENCES MIMICIII.D_ICD_DIAGNOSES(icd9_code);

--------------
---DRGCODES---
--------------

-- subject_id
ALTER TABLE MIMICIII.DRGCODES
ADD CONSTRAINT drgcodes_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.DRGCODES
ADD CONSTRAINT drgcodes_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-----------------
--ICUSTAYEVENTS--
-----------------

-- subject_id
ALTER TABLE MIMICIII.ICUSTAYEVENTS
ADD CONSTRAINT icustayevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.ICUSTAYEVENTS
ADD CONSTRAINT icustayevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);


------------
--IOEVENTS--
------------

-- subject_id
ALTER TABLE MIMICIII.IOEVENTS
ADD CONSTRAINT ioevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.IOEVENTS
ADD CONSTRAINT ioevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- icustay_id
ALTER TABLE MIMICIII.IOEVENTS
ADD CONSTRAINT ioevents_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES MIMICIII.icustayevents(icustay_id);

-- cgid
ALTER TABLE MIMICIII.IOEVENTS
ADD CONSTRAINT ioevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES MIMICIII.CAREGIVERS(cgid);

-------------
--LABEVENTS--
-------------

-- subject_id
ALTER TABLE MIMICIII.LABEVENTS
ADD CONSTRAINT labevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.LABEVENTS
ADD CONSTRAINT labevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- item_id
ALTER TABLE MIMICIII.LABEVENTS
ADD CONSTRAINT labevents_fk_itemid
  FOREIGN KEY (itemid)
  REFERENCES MIMICIII.d_labitems(itemid);

----------------------
--MICROBIOLOGYEVENTS--
----------------------

-- subject_id
ALTER TABLE MIMICIII.MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

--------------
--NOTEEVENTS--
--------------

-- subject_id
ALTER TABLE MIMICIII.NOTEEVENTS
ADD CONSTRAINT noteevents_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.NOTEEVENTS
ADD CONSTRAINT noteevents_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- cgid
ALTER TABLE MIMICIII.NOTEEVENTS
ADD CONSTRAINT noteevents_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES MIMICIII.CAREGIVERS(cgid);

-----------------
--PRESCRIPTIONS--
-----------------

-- subject_id
ALTER TABLE MIMICIII.PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- icustay_id
ALTER TABLE MIMICIII.PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES MIMICIII.icustayevents(icustay_id);

------------------
--PROCEDURES_ICD--
------------------

-- subject_id
ALTER TABLE MIMICIII.PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- ICD9_code
ALTER TABLE MIMICIII.PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_icd9
  FOREIGN KEY (icd9_code)
  REFERENCES MIMICIII.D_ICD_PROCEDURES(icd9_code);

------------
--SERVICES--
------------

-- subject_id
ALTER TABLE MIMICIII.SERVICES
ADD CONSTRAINT services_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.SERVICES
ADD CONSTRAINT services_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-------------
--TRANSFERS--
-------------

-- subject_id
ALTER TABLE MIMICIII.TRANSFERS
ADD CONSTRAINT transfers_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES MIMICIII.patients(subject_id);

-- hadm_id
ALTER TABLE MIMICIII.TRANSFERS
ADD CONSTRAINT transfers_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES MIMICIII.admissions(hadm_id);

-- icustay_id
ALTER TABLE MIMICIII.TRANSFERS
ADD CONSTRAINT transfers_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES MIMICIII.icustayevents(icustay_id);
