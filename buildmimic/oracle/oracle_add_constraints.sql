-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III constraints for Oracle.
--
-- ----------------------------------------------------------------

-- The below command defines the schema where the data should reside
--ALTER SESSION SET CURRENT_SCHEMA = MIMICIII;

-- Restoring the default schema can be accomplished using the same command, replacing "MIMICIII" with your username.

-------------------
--EXPLORE INDEXES--
-------------------

-- -- List current indexes
-- select index_name, index_type, table_name, UNIQUENESS, status, COMPRESSION, TABLESPACE_NAME
-- from dba_indexes
-- where owner= MIMICIII
-- order by index_name;

-- Use to list commands to fix unusable indexes
SELECT 'alter index '||index_name||' rebuild tablespace '||tablespace_name ||';'
FROM   dba_indexes
WHERE  status = 'UNUSABLE';

-----------------------
--EXPLORE CONSTRAINTS--
-----------------------

SELECT a.table_name, a.column_name, a.constraint_name, c.owner,
       -- referenced pk
       c.r_owner, c_pk.table_name r_table_name, c_pk.constraint_name r_pk
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R'
   AND c.OWNER = 'MIMICIII';

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
  REFERENCES icustays(icustay_id);

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
  REFERENCES icustays(icustay_id);


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
--ICUSTAYS--
-----------------

-- subject_id
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

------------------
--INPUTEVENTS_CV--
------------------

-- subject_id
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT input_cv_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT input_cv_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT input_cv_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT input_cv_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

------------------
--INPUTEVENTS_MV--
------------------

-- subject_id
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT input_mv_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT input_mv_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT input_mv_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT input_mv_fk_cgid
  FOREIGN KEY (cgid)
  REFERENCES CAREGIVERS(cgid);

----------------
--OUTPUTEVENTS--
----------------

-- subject_id
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT output_fk_subject_id
  FOREIGN KEY (subject_id)
  REFERENCES patients(subject_id);

-- hadm_id
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT output_fk_hadm_id
  FOREIGN KEY (hadm_id)
  REFERENCES admissions(hadm_id);

-- icustay_id
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT output_fk_icustay_id
  FOREIGN KEY (icustay_id)
  REFERENCES icustays(icustay_id);

-- cgid
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT output_fk_cgid
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
  REFERENCES icustays(icustay_id);

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
  REFERENCES icustays(icustay_id);
