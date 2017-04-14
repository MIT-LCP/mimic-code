-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III indexes for Postgres.
--
-- ----------------------------------------------------------------

\set ON_ERROR_STOP 1

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

-- Restoring the search path to its default value can be accomplished as follows:
-- SET search_path TO "$user",public;

-------------
-- ADMISSIONS
-------------

drop index IF EXISTS ADMISSIONS_idx01;
CREATE INDEX ADMISSIONS_IDX01
  ON ADMISSIONS (SUBJECT_ID);

drop index IF EXISTS ADMISSIONS_idx02;
CREATE INDEX ADMISSIONS_IDX02
  ON ADMISSIONS (HADM_ID);

-- drop index IF EXISTS ADMISSIONS_idx03;
-- CREATE INDEX ADMISSIONS_IDX03
--   ON ADMISSIONS (ADMISSION_TYPE);


-----------
--CALLOUT--
-----------

drop index IF EXISTS CALLOUT_idx01;
CREATE INDEX CALLOUT_IDX01
  ON CALLOUT (SUBJECT_ID);

drop index IF EXISTS CALLOUT_idx02;
CREATE INDEX CALLOUT_IDX02
  ON CALLOUT (HADM_ID);

-- drop index IF EXISTS CALLOUT_idx03;
-- CREATE INDEX CALLOUT_IDX03
--   ON CALLOUT (CALLOUT_SERVICE);

-- drop index IF EXISTS CALLOUT_idx04;
-- CREATE INDEX CALLOUT_IDX04
--   ON CALLOUT (CURR_WARDID, CALLOUT_WARDID,
--     DISCHARGE_WARDID);

-- drop index IF EXISTS CALLOUT_idx05;
-- CREATE INDEX CALLOUT_IDX05
--   ON CALLOUT (CALLOUT_STATUS,
--     CALLOUT_OUTCOME);

-- drop index IF EXISTS CALLOUT_idx06;
-- CREATE INDEX CALLOUT_IDX06
--   ON CALLOUT (CREATETIME, UPDATETIME,
--     ACKNOWLEDGETIME, OUTCOMETIME);

---------------
-- CAREGIVERS
---------------

-- drop index IF EXISTS CAREGIVERS_idx01;
-- CREATE INDEX CAREGIVERS_IDX01
--   ON CAREGIVERS (CGID, LABEL);

---------------
-- CHARTEVENTS
---------------

-- CHARTEVENTS is built in 10 partitions which are inherited by a single mother table, "CHARTEVENTS"
-- Therefore, indices need to be added on every single inherited (or partitioned) table.

-- index on itemid --

drop index IF EXISTS chartevents_1_idx01;
CREATE INDEX chartevents_1_idx01 ON chartevents_1 (itemid);
drop index IF EXISTS chartevents_2_idx01;
CREATE INDEX chartevents_2_idx01 ON chartevents_2 (itemid);
drop index IF EXISTS chartevents_3_idx01;
CREATE INDEX chartevents_3_idx01 ON chartevents_3 (itemid);
drop index IF EXISTS chartevents_4_idx01;
CREATE INDEX chartevents_4_idx01 ON chartevents_4 (itemid);
drop index IF EXISTS chartevents_5_idx01;
CREATE INDEX chartevents_5_idx01 ON chartevents_5 (itemid);
drop index IF EXISTS chartevents_6_idx01;
CREATE INDEX chartevents_6_idx01 ON chartevents_6 (itemid);
drop index IF EXISTS chartevents_7_idx01;
CREATE INDEX chartevents_7_idx01 ON chartevents_7 (itemid);
drop index IF EXISTS chartevents_8_idx01;
CREATE INDEX chartevents_8_idx01 ON chartevents_8 (itemid);
drop index IF EXISTS chartevents_9_idx01;
CREATE INDEX chartevents_9_idx01 ON chartevents_9 (itemid);
drop index IF EXISTS chartevents_10_idx01;
CREATE INDEX chartevents_10_idx01 ON chartevents_10 (itemid);
drop index IF EXISTS chartevents_11_idx01;
CREATE INDEX chartevents_11_idx01 ON chartevents_11 (itemid);
drop index IF EXISTS chartevents_12_idx01;
CREATE INDEX chartevents_12_idx01 ON chartevents_12 (itemid);
drop index IF EXISTS chartevents_13_idx01;
CREATE INDEX chartevents_13_idx01 ON chartevents_13 (itemid);
drop index IF EXISTS chartevents_14_idx01;
CREATE INDEX chartevents_14_idx01 ON chartevents_14 (itemid);

-- index on subject_id --

drop index IF EXISTS chartevents_1_idx02;
CREATE INDEX chartevents_1_idx02 ON chartevents_1 (SUBJECT_ID);
drop index IF EXISTS chartevents_2_idx02;
CREATE INDEX chartevents_2_idx02 ON chartevents_2 (SUBJECT_ID);
drop index IF EXISTS chartevents_3_idx02;
CREATE INDEX chartevents_3_idx02 ON chartevents_3 (SUBJECT_ID);
drop index IF EXISTS chartevents_4_idx02;
CREATE INDEX chartevents_4_idx02 ON chartevents_4 (SUBJECT_ID);
drop index IF EXISTS chartevents_5_idx02;
CREATE INDEX chartevents_5_idx02 ON chartevents_5 (SUBJECT_ID);
drop index IF EXISTS chartevents_6_idx02;
CREATE INDEX chartevents_6_idx02 ON chartevents_6 (SUBJECT_ID);
drop index IF EXISTS chartevents_7_idx02;
CREATE INDEX chartevents_7_idx02 ON chartevents_7 (SUBJECT_ID);
drop index IF EXISTS chartevents_8_idx02;
CREATE INDEX chartevents_8_idx02 ON chartevents_8 (SUBJECT_ID);
drop index IF EXISTS chartevents_9_idx02;
CREATE INDEX chartevents_9_idx02 ON chartevents_9 (SUBJECT_ID);
drop index IF EXISTS chartevents_10_idx02;
CREATE INDEX chartevents_10_idx02 ON chartevents_10 (SUBJECT_ID);
drop index IF EXISTS chartevents_11_idx02;
CREATE INDEX chartevents_11_idx02 ON chartevents_11 (SUBJECT_ID);
drop index IF EXISTS chartevents_12_idx02;
CREATE INDEX chartevents_12_idx02 ON chartevents_12 (SUBJECT_ID);
drop index IF EXISTS chartevents_13_idx02;
CREATE INDEX chartevents_13_idx02 ON chartevents_13 (SUBJECT_ID);
drop index IF EXISTS chartevents_14_idx02;
CREATE INDEX chartevents_14_idx02 ON chartevents_14 (SUBJECT_ID);

-- index on hadm_id --

drop index IF EXISTS chartevents_1_idx04;
CREATE INDEX chartevents_1_idx04 ON chartevents_1 (HADM_ID);
drop index IF EXISTS chartevents_2_idx04;
CREATE INDEX chartevents_2_idx04 ON chartevents_2 (HADM_ID);
drop index IF EXISTS chartevents_3_idx04;
CREATE INDEX chartevents_3_idx04 ON chartevents_3 (HADM_ID);
drop index IF EXISTS chartevents_4_idx04;
CREATE INDEX chartevents_4_idx04 ON chartevents_4 (HADM_ID);
drop index IF EXISTS chartevents_5_idx04;
CREATE INDEX chartevents_5_idx04 ON chartevents_5 (HADM_ID);
drop index IF EXISTS chartevents_6_idx04;
CREATE INDEX chartevents_6_idx04 ON chartevents_6 (HADM_ID);
drop index IF EXISTS chartevents_7_idx04;
CREATE INDEX chartevents_7_idx04 ON chartevents_7 (HADM_ID);
drop index IF EXISTS chartevents_8_idx04;
CREATE INDEX chartevents_8_idx04 ON chartevents_8 (HADM_ID);
drop index IF EXISTS chartevents_9_idx04;
CREATE INDEX chartevents_9_idx04 ON chartevents_9 (HADM_ID);
drop index IF EXISTS chartevents_10_idx04;
CREATE INDEX chartevents_10_idx04 ON chartevents_10 (HADM_ID);
drop index IF EXISTS chartevents_11_idx04;
CREATE INDEX chartevents_11_idx04 ON chartevents_11 (HADM_ID);
drop index IF EXISTS chartevents_12_idx04;
CREATE INDEX chartevents_12_idx04 ON chartevents_12 (HADM_ID);
drop index IF EXISTS chartevents_13_idx04;
CREATE INDEX chartevents_13_idx04 ON chartevents_13 (HADM_ID);
drop index IF EXISTS chartevents_14_idx04;
CREATE INDEX chartevents_14_idx04 ON chartevents_14 (HADM_ID);


-- index on icustay_id --

drop index IF EXISTS chartevents_1_idx06;
CREATE INDEX chartevents_1_idx06 ON chartevents_1 (ICUSTAY_ID);
drop index IF EXISTS chartevents_2_idx06;
CREATE INDEX chartevents_2_idx06 ON chartevents_2 (ICUSTAY_ID);
drop index IF EXISTS chartevents_3_idx06;
CREATE INDEX chartevents_3_idx06 ON chartevents_3 (ICUSTAY_ID);
drop index IF EXISTS chartevents_4_idx06;
CREATE INDEX chartevents_4_idx06 ON chartevents_4 (ICUSTAY_ID);
drop index IF EXISTS chartevents_5_idx06;
CREATE INDEX chartevents_5_idx06 ON chartevents_5 (ICUSTAY_ID);
drop index IF EXISTS chartevents_6_idx06;
CREATE INDEX chartevents_6_idx06 ON chartevents_6 (ICUSTAY_ID);
drop index IF EXISTS chartevents_7_idx06;
CREATE INDEX chartevents_7_idx06 ON chartevents_7 (ICUSTAY_ID);
drop index IF EXISTS chartevents_8_idx06;
CREATE INDEX chartevents_8_idx06 ON chartevents_8 (ICUSTAY_ID);
drop index IF EXISTS chartevents_9_idx06;
CREATE INDEX chartevents_9_idx06 ON chartevents_9 (ICUSTAY_ID);
drop index IF EXISTS chartevents_10_idx06;
CREATE INDEX chartevents_10_idx06 ON chartevents_10 (ICUSTAY_ID);
drop index IF EXISTS chartevents_11_idx06;
CREATE INDEX chartevents_11_idx06 ON chartevents_11 (ICUSTAY_ID);
drop index IF EXISTS chartevents_12_idx06;
CREATE INDEX chartevents_12_idx06 ON chartevents_12 (ICUSTAY_ID);
drop index IF EXISTS chartevents_13_idx06;
CREATE INDEX chartevents_13_idx06 ON chartevents_13 (ICUSTAY_ID);
drop index IF EXISTS chartevents_14_idx06;
CREATE INDEX chartevents_14_idx06 ON chartevents_14 (ICUSTAY_ID);


---------------
-- CPTEVENTS
---------------

drop index IF EXISTS CPTEVENTS_idx01;
CREATE INDEX CPTEVENTS_idx01
  ON CPTEVENTS (SUBJECT_ID);

drop index IF EXISTS CPTEVENTS_idx02;
CREATE INDEX CPTEVENTS_idx02
  ON CPTEVENTS (CPT_CD);

-----------
-- D_CPT
-----------

-- Table is 134 rows - doesn't need an index.

--------------------
-- D_ICD_DIAGNOSES
--------------------

drop index IF EXISTS D_ICD_DIAG_idx01;
CREATE INDEX D_ICD_DIAG_idx01
  ON D_ICD_DIAGNOSES (ICD9_CODE);

drop index IF EXISTS D_ICD_DIAG_idx02;
CREATE INDEX D_ICD_DIAG_idx02
  ON D_ICD_DIAGNOSES (LONG_TITLE);

--------------------
-- D_ICD_PROCEDURES
--------------------

drop index IF EXISTS D_ICD_PROC_idx01;
CREATE INDEX D_ICD_PROC_idx01
  ON D_ICD_PROCEDURES (ICD9_CODE);

drop index IF EXISTS D_ICD_PROC_idx02;
CREATE INDEX D_ICD_PROC_idx02
  ON D_ICD_PROCEDURES (LONG_TITLE);

-----------
-- D_ITEMS
-----------

drop index IF EXISTS D_ITEMS_idx01;
CREATE INDEX D_ITEMS_idx01
  ON D_ITEMS (ITEMID);

drop index IF EXISTS D_ITEMS_idx02;
CREATE INDEX D_ITEMS_idx02
  ON D_ITEMS (LABEL);

-- drop index IF EXISTS D_ITEMS_idx03;
-- CREATE INDEX D_ITEMS_idx03
--   ON D_ITEMS (CATEGORY);

---------------
-- D_LABITEMS
---------------

drop index IF EXISTS D_LABITEMS_idx01;
CREATE INDEX D_LABITEMS_idx01
  ON D_LABITEMS (ITEMID);

drop index IF EXISTS D_LABITEMS_idx02;
CREATE INDEX D_LABITEMS_idx02
  ON D_LABITEMS (LABEL);

drop index IF EXISTS D_LABITEMS_idx03;
CREATE INDEX D_LABITEMS_idx03
  ON D_LABITEMS (LOINC_CODE);

-------------------
-- DATETIMEEVENTS
-------------------

drop index IF EXISTS DATETIMEEVENTS_idx01;
CREATE INDEX DATETIMEEVENTS_idx01
  ON DATETIMEEVENTS (SUBJECT_ID);

drop index IF EXISTS DATETIMEEVENTS_idx02;
CREATE INDEX DATETIMEEVENTS_idx02
  ON DATETIMEEVENTS (ITEMID);

drop index IF EXISTS DATETIMEEVENTS_idx03;
CREATE INDEX DATETIMEEVENTS_idx03
  ON DATETIMEEVENTS (ICUSTAY_ID);

drop index IF EXISTS DATETIMEEVENTS_idx04;
CREATE INDEX DATETIMEEVENTS_idx04
  ON DATETIMEEVENTS (HADM_ID);

-- drop index IF EXISTS DATETIMEEVENTS_idx05;
-- CREATE INDEX DATETIMEEVENTS_idx05
--   ON DATETIMEEVENTS (VALUE);

------------------
-- DIAGNOSES_ICD
------------------

drop index IF EXISTS DIAGNOSES_ICD_idx01;
CREATE INDEX DIAGNOSES_ICD_idx01
  ON DIAGNOSES_ICD (SUBJECT_ID);

drop index IF EXISTS DIAGNOSES_ICD_idx02;
CREATE INDEX DIAGNOSES_ICD_idx02
  ON DIAGNOSES_ICD (ICD9_CODE);

drop index IF EXISTS DIAGNOSES_ICD_idx03;
CREATE INDEX DIAGNOSES_ICD_idx03
  ON DIAGNOSES_ICD (HADM_ID);

--------------
-- DRGCODES
--------------

drop index IF EXISTS DRGCODES_idx01;
CREATE INDEX DRGCODES_idx01
  ON DRGCODES (SUBJECT_ID);

drop index IF EXISTS DRGCODES_idx02;
CREATE INDEX DRGCODES_idx02
  ON DRGCODES (DRG_CODE);

drop index IF EXISTS DRGCODES_idx03;
CREATE INDEX DRGCODES_idx03
  ON DRGCODES (DESCRIPTION);

-- HADM_ID

------------------
-- ICUSTAYS
------------------

drop index IF EXISTS ICUSTAYS_idx01;
CREATE INDEX ICUSTAYS_idx01
  ON ICUSTAYS (SUBJECT_ID);

drop index IF EXISTS ICUSTAYS_idx02;
CREATE INDEX ICUSTAYS_idx02
  ON ICUSTAYS (ICUSTAY_ID);

-- drop index IF EXISTS ICUSTAYS_idx03;
-- CREATE INDEX ICUSTAYS_idx03
--   ON ICUSTAYS (LOS);

-- drop index IF EXISTS ICUSTAYS_idx04;
-- CREATE INDEX ICUSTAYS_idx04
--   ON ICUSTAYS (FIRST_CAREUNIT);

-- drop index IF EXISTS ICUSTAYS_idx05;
-- CREATE INDEX ICUSTAYS_idx05
--   ON ICUSTAYS (LAST_CAREUNIT);

drop index IF EXISTS ICUSTAYS_idx06;
CREATE INDEX ICUSTAYS_IDX06
  ON ICUSTAYS (HADM_ID);

-------------
-- INPUTEVENTS_CV
-------------

drop index IF EXISTS INPUTEVENTS_CV_idx01;
CREATE INDEX INPUTEVENTS_CV_idx01
  ON INPUTEVENTS_CV (SUBJECT_ID);

  drop index IF EXISTS INPUTEVENTS_CV_idx02;
  CREATE INDEX INPUTEVENTS_CV_idx02
    ON INPUTEVENTS_CV (HADM_ID);

drop index IF EXISTS INPUTEVENTS_CV_idx03;
CREATE INDEX INPUTEVENTS_CV_idx03
  ON INPUTEVENTS_CV (ICUSTAY_ID);

drop index IF EXISTS INPUTEVENTS_CV_idx04;
CREATE INDEX INPUTEVENTS_CV_idx04
  ON INPUTEVENTS_CV (CHARTTIME);

drop index IF EXISTS INPUTEVENTS_CV_idx05;
CREATE INDEX INPUTEVENTS_CV_idx05
  ON INPUTEVENTS_CV (ITEMID);

-- drop index IF EXISTS INPUTEVENTS_CV_idx06;
-- CREATE INDEX INPUTEVENTS_CV_idx06
--   ON INPUTEVENTS_CV (RATE);

-- drop index IF EXISTS INPUTEVENTS_CV_idx07;
-- CREATE INDEX INPUTEVENTS_CV_idx07
--   ON INPUTEVENTS_CV (AMOUNT);

-- drop index IF EXISTS INPUTEVENTS_CV_idx08;
-- CREATE INDEX INPUTEVENTS_CV_idx08
--   ON INPUTEVENTS_CV (CGID);

-- drop index IF EXISTS INPUTEVENTS_CV_idx09;
-- CREATE INDEX INPUTEVENTS_CV_idx09
--   ON INPUTEVENTS_CV (LINKORDERID, ORDERID);

-------------
-- INPUTEVENTS_MV
-------------

drop index IF EXISTS INPUTEVENTS_MV_idx01;
CREATE INDEX INPUTEVENTS_MV_idx01
  ON INPUTEVENTS_MV (SUBJECT_ID);

drop index IF EXISTS INPUTEVENTS_MV_idx02;
CREATE INDEX INPUTEVENTS_MV_idx02
  ON INPUTEVENTS_MV (HADM_ID);

drop index IF EXISTS INPUTEVENTS_MV_idx03;
CREATE INDEX INPUTEVENTS_MV_idx03
  ON INPUTEVENTS_MV (ICUSTAY_ID);

-- drop index IF EXISTS INPUTEVENTS_MV_idx04;
-- CREATE INDEX INPUTEVENTS_MV_idx04
--   ON INPUTEVENTS_MV (ENDTIME, STARTTIME);

drop index IF EXISTS INPUTEVENTS_MV_idx05;
CREATE INDEX INPUTEVENTS_MV_idx05
  ON INPUTEVENTS_MV (ITEMID);

-- drop index IF EXISTS INPUTEVENTS_MV_idx06;
-- CREATE INDEX INPUTEVENTS_MV_idx06
--   ON INPUTEVENTS_MV (RATE);

-- drop index IF EXISTS INPUTEVENTS_MV_idx07;
-- CREATE INDEX INPUTEVENTS_MV_idx07
--   ON INPUTEVENTS_MV (VOLUME);

-- drop index IF EXISTS INPUTEVENTS_MV_idx08;
-- CREATE INDEX INPUTEVENTS_MV_idx08
--   ON INPUTEVENTS_MV (CGID);

-- drop index IF EXISTS INPUTEVENTS_MV_idx09;
-- CREATE INDEX INPUTEVENTS_MV_idx09
--   ON INPUTEVENTS_MV (LINKORDERID, ORDERID);

-- drop index IF EXISTS INPUTEVENTS_MV_idx10;
-- CREATE INDEX INPUTEVENTS_MV_idx10
--   ON INPUTEVENTS_MV (ORDERCATEGORYDESCRIPTION,
--     ORDERCATEGORYNAME, SECONDARYORDERCATEGORYNAME);

-- drop index IF EXISTS INPUTEVENTS_MV_idx11;
-- CREATE INDEX INPUTEVENTS_MV_idx11
--   ON INPUTEVENTS_MV (ORDERCOMPONENTTYPEDESCRIPTION,
--     ORDERCATEGORYDESCRIPTION);


--------------
-- LABEVENTS
--------------

drop index IF EXISTS LABEVENTS_idx01;
CREATE INDEX LABEVENTS_idx01
  ON LABEVENTS (SUBJECT_ID);

drop index IF EXISTS LABEVENTS_idx02;
CREATE INDEX LABEVENTS_idx02
  ON LABEVENTS (HADM_ID);

drop index IF EXISTS LABEVENTS_idx03;
CREATE INDEX LABEVENTS_idx03
  ON LABEVENTS (ITEMID);

-- drop index IF EXISTS LABEVENTS_idx04;
-- CREATE INDEX LABEVENTS_idx04
--   ON LABEVENTS (VALUE, VALUENUM);

----------------------
-- MICROBIOLOGYEVENTS
----------------------

drop index IF EXISTS MICROBIOLOGYEVENTS_idx01;
CREATE INDEX MICROBIOLOGYEVENTS_idx01
  ON MICROBIOLOGYEVENTS (SUBJECT_ID);

drop index IF EXISTS MICROBIOLOGYEVENTS_idx02;
CREATE INDEX MICROBIOLOGYEVENTS_idx02
  ON MICROBIOLOGYEVENTS (HADM_ID);

-- drop index IF EXISTS MICROBIOLOGYEVENTS_idx03;
-- CREATE INDEX MICROBIOLOGYEVENTS_idx03
--   ON MICROBIOLOGYEVENTS (SPEC_ITEMID,
--     ORG_ITEMID, AB_ITEMID);

---------------
-- NOTEEVENTS
---------------

drop index IF EXISTS NOTEEVENTS_idx01;
CREATE INDEX NOTEEVENTS_idx01
  ON NOTEEVENTS (SUBJECT_ID);

drop index IF EXISTS NOTEEVENTS_idx02;
CREATE INDEX NOTEEVENTS_idx02
  ON NOTEEVENTS (HADM_ID);

-- drop index IF EXISTS NOTEEVENTS_idx03;
-- CREATE INDEX NOTEEVENTS_idx03
--   ON NOTEEVENTS (CGID);

-- drop index IF EXISTS NOTEEVENTS_idx04;
-- CREATE INDEX NOTEEVENTS_idx04
--   ON NOTEEVENTS (RECORD_ID);

drop index IF EXISTS NOTEEVENTS_idx05;
CREATE INDEX NOTEEVENTS_idx05
  ON NOTEEVENTS (CATEGORY);


---------------
-- OUTPUTEVENTS
---------------
drop index IF EXISTS OUTPUTEVENTS_idx01;
CREATE INDEX OUTPUTEVENTS_idx01
  ON OUTPUTEVENTS (SUBJECT_ID);


drop index IF EXISTS OUTPUTEVENTS_idx02;
CREATE INDEX OUTPUTEVENTS_idx02
  ON OUTPUTEVENTS (ITEMID);


drop index IF EXISTS OUTPUTEVENTS_idx03;
CREATE INDEX OUTPUTEVENTS_idx03
  ON OUTPUTEVENTS (ICUSTAY_ID);


drop index IF EXISTS OUTPUTEVENTS_idx04;
CREATE INDEX OUTPUTEVENTS_idx04
  ON OUTPUTEVENTS (HADM_ID);

-- Perhaps not useful to index on just value? Index just for popular subset?
-- drop index IF EXISTS OUTPUTEVENTS_idx05;
-- CREATE INDEX OUTPUTEVENTS_idx05
--   ON OUTPUTEVENTS (VALUE);


-------------
-- PATIENTS
-------------

-- Note that SUBJECT_ID is already indexed as it is unique

-- drop index IF EXISTS PATIENTS_idx01;
-- CREATE INDEX PATIENTS_idx01
--   ON PATIENTS (EXPIRE_FLAG);


------------------
-- PRESCRIPTIONS
------------------

drop index IF EXISTS PRESCRIPTIONS_idx01;
CREATE INDEX PRESCRIPTIONS_idx01
  ON PRESCRIPTIONS (SUBJECT_ID);

drop index IF EXISTS PRESCRIPTIONS_idx02;
CREATE INDEX PRESCRIPTIONS_idx02
  ON PRESCRIPTIONS (ICUSTAY_ID);

drop index IF EXISTS PRESCRIPTIONS_idx03;
CREATE INDEX PRESCRIPTIONS_idx03
  ON PRESCRIPTIONS (DRUG_TYPE);

drop index IF EXISTS PRESCRIPTIONS_idx04;
CREATE INDEX PRESCRIPTIONS_idx04
  ON PRESCRIPTIONS (DRUG);

drop index IF EXISTS PRESCRIPTIONS_idx05;
CREATE INDEX PRESCRIPTIONS_idx05
  ON PRESCRIPTIONS (HADM_ID);


---------------------
-- PROCEDUREEVENTS_MV
---------------------

drop index IF EXISTS PROCEDUREEVENTS_MV_idx01;
CREATE INDEX PROCEDUREEVENTS_MV_idx01
  ON PROCEDUREEVENTS_MV (SUBJECT_ID);

drop index IF EXISTS PROCEDUREEVENTS_MV_idx02;
CREATE INDEX PROCEDUREEVENTS_MV_idx02
  ON PROCEDUREEVENTS_MV (HADM_ID);

drop index IF EXISTS PROCEDUREEVENTS_MV_idx03;
CREATE INDEX PROCEDUREEVENTS_MV_idx03
  ON PROCEDUREEVENTS_MV (ICUSTAY_ID);

-- drop index IF EXISTS PROCEDUREEVENTS_MV_idx04;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx04
--   ON PROCEDUREEVENTS_MV (ENDTIME, STARTTIME);

drop index IF EXISTS PROCEDUREEVENTS_MV_idx05;
CREATE INDEX PROCEDUREEVENTS_MV_idx05
  ON PROCEDUREEVENTS_MV (ITEMID);

-- drop index IF EXISTS PROCEDUREEVENTS_MV_idx06;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx06
--   ON PROCEDUREEVENTS_MV (VALUE);

-- drop index IF EXISTS PROCEDUREEVENTS_MV_idx07;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx07
--   ON PROCEDUREEVENTS_MV (CGID);

-- drop index IF EXISTS PROCEDUREEVENTS_MV_idx08;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx08
--   ON PROCEDUREEVENTS_MV (LINKORDERID, ORDERID);

-- drop index IF EXISTS PROCEDUREEVENTS_MV_idx09;
-- CREATE INDEX PROCEDUREEVENTS_MV_idx09
--   ON PROCEDUREEVENTS_MV (ORDERCATEGORYDESCRIPTION,
--     ORDERCATEGORYNAME, SECONDARYORDERCATEGORYNAME);

-------------------
-- PROCEDURES_ICD
-------------------

drop index IF EXISTS PROCEDURES_ICD_idx01;
CREATE INDEX PROCEDURES_ICD_idx01
  ON PROCEDURES_ICD (SUBJECT_ID);

drop index IF EXISTS PROCEDURES_ICD_idx02;
CREATE INDEX PROCEDURES_ICD_idx02
  ON PROCEDURES_ICD (ICD9_CODE);

drop index IF EXISTS PROCEDURES_ICD_idx03;
CREATE INDEX PROCEDURES_ICD_idx03
  ON PROCEDURES_ICD (HADM_ID);


-------------
-- SERVICES
-------------

drop index IF EXISTS SERVICES_idx01;
CREATE INDEX SERVICES_idx01
  ON SERVICES (SUBJECT_ID);

drop index IF EXISTS SERVICES_idx02;
CREATE INDEX SERVICES_idx02
  ON SERVICES (HADM_ID);

-- drop index IF EXISTS SERVICES_idx03;
-- CREATE INDEX SERVICES_idx03
--   ON SERVICES (CURR_SERVICE, PREV_SERVICE);

-------------
-- TRANSFERS
-------------

drop index IF EXISTS TRANSFERS_idx01;
CREATE INDEX TRANSFERS_idx01
  ON TRANSFERS (SUBJECT_ID);

drop index IF EXISTS TRANSFERS_idx02;
CREATE INDEX TRANSFERS_idx02
  ON TRANSFERS (ICUSTAY_ID);

drop index IF EXISTS TRANSFERS_idx03;
CREATE INDEX TRANSFERS_idx03
  ON TRANSFERS (HADM_ID);

-- drop index IF EXISTS TRANSFERS_idx04;
-- CREATE INDEX TRANSFERS_idx04
--   ON TRANSFERS (INTIME, OUTTIME);

-- drop index IF EXISTS TRANSFERS_idx05;
-- CREATE INDEX TRANSFERS_idx05
--   ON TRANSFERS (LOS);
