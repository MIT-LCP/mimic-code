-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-III constraints for MySQL.
-- 
-- ----------------------------------------------------------------

-- The below command defines the schema where the data should reside
use mimiciiiv14;

-- Restoring the search path to its default value can be accomplished as follows:
--  SET search_path TO "$user",public;

DROP PROCEDURE IF EXISTS PROC_DROP_FOREIGN_KEY;
DELIMITER $$
CREATE PROCEDURE PROC_DROP_FOREIGN_KEY(IN tableName VARCHAR(64), IN constraintName VARCHAR(64))
BEGIN
  IF EXISTS(
    SELECT * FROM information_schema.table_constraints
    WHERE 
      table_schema    = DATABASE()     AND
      table_name      = tableName      AND
      constraint_name = constraintName AND
      constraint_type = 'FOREIGN KEY')
  THEN
    SET @query = CONCAT('ALTER TABLE ', tableName, ' DROP FOREIGN KEY ', constraintName, ';');
    PREPARE stmt FROM @query; 
    EXECUTE stmt; 
    DEALLOCATE PREPARE stmt; 
  END IF; 
END$$
DELIMITER ;

-- ------------
-- ADMISSIONS--
-- ------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('ADMISSIONS', 'admissions_fk_subject_id');
ALTER TABLE ADMISSIONS
ADD CONSTRAINT admissions_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- ---------
-- CALLOUT--
-- ---------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('CALLOUT', 'callout_fk_subject_id');
ALTER TABLE CALLOUT
ADD CONSTRAINT callout_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('CALLOUT', 'callout_fk_hadm_id');
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
CALL PROC_DROP_FOREIGN_KEY('CHARTEVENTS', 'chartevents_fk_subject_id');
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- cgid
CALL PROC_DROP_FOREIGN_KEY('CHARTEVENTS', 'chartevents_fk_cgid');
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('CHARTEVENTS', 'chartevents_fk_hadm_id');
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- item_id
CALL PROC_DROP_FOREIGN_KEY('CHARTEVENTS', 'chartevents_fk_itemid');
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_itemid
  FOREIGN KEY (ITEMID)
  REFERENCES D_ITEMS(ITEMID);

-- icustay_id
CALL PROC_DROP_FOREIGN_KEY('CHARTEVENTS', 'chartevents_fk_icustay_id');
ALTER TABLE CHARTEVENTS
ADD CONSTRAINT chartevents_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- -----------
-- CPTEVENTS--
-- -----------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('CPTEVENTS', 'cptevents_fk_subject_id');
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('CPTEVENTS', 'cptevents_fk_hadm_id');
ALTER TABLE CPTEVENTS
ADD CONSTRAINT cptevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ----------------
-- DATETIMEEVENTS--
-- ----------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('DATETIMEEVENTS', 'datetimeevents_fk_subject_id');
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- cgid
CALL PROC_DROP_FOREIGN_KEY('DATETIMEEVENTS', 'datetimeevents_fk_cgid');
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('DATETIMEEVENTS', 'datetimeevents_fk_hadm_id');
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- item_id
CALL PROC_DROP_FOREIGN_KEY('DATETIMEEVENTS', 'datetimeevents_fk_itemid');
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_itemid
  FOREIGN KEY (ITEMID)
  REFERENCES D_ITEMS(ITEMID);

-- icustay_id
CALL PROC_DROP_FOREIGN_KEY('DATETIMEEVENTS', 'datetimeevents_fk_icustay_id');
ALTER TABLE DATETIMEEVENTS
ADD CONSTRAINT datetimeevents_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);


-- ---------------
-- DIAGNOSES_ICD--
-- ---------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('DIAGNOSES_ICD', 'diagnoses_icd_fk_subject_id');
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('DIAGNOSES_ICD', 'diagnoses_icd_fk_hadm_id');
ALTER TABLE DIAGNOSES_ICD
ADD CONSTRAINT diagnoses_icd_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);
  
-- ICD9_code
-- Cannot impose this constraint because icd9_code contains 143 codes not in c_icd_diagnoses
-- See https://github.com/MIT-LCP/mimic-code/issues/20
-- CALL PROC_DROP_FOREIGN_KEY('DIAGNOSES_ICD', 'diagnoses_icd_fk_icd9');
-- ALTER TABLE DIAGNOSES_ICD
-- ADD CONSTRAINT diagnoses_icd_fk_icd9
--   FOREIGN KEY (ICD9_CODE)
--   REFERENCES D_ICD_DIAGNOSES(ICD9_CODE);

-- ------------
-- DRGCODES ---
-- ------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('DRGCODES', 'drgcodes_fk_subject_id');
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('DRGCODES', 'drgcodes_fk_hadm_id');
ALTER TABLE DRGCODES
ADD CONSTRAINT drgcodes_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ---------------
-- ICUSTAYS--
-- ---------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('ICUSTAYS', 'icustays_fk_subject_id');
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('ICUSTAYS', 'icustays_fk_hadm_id');
ALTER TABLE ICUSTAYS
ADD CONSTRAINT icustays_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ----------
-- INPUTEVENTS_CV--
-- ----------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_CV', 'inputevents_cv_fk_subject_id');
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_CV', 'inputevents_cv_fk_hadm_id');
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_CV', 'inputevents_cv_fk_icustay_id');
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_CV', 'inputevents_cv_fk_cgid');
ALTER TABLE INPUTEVENTS_CV
ADD CONSTRAINT inputevents_cv_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ----------
-- INPUTEVENTS_MV--
-- ----------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_MV', 'inputevents_mv_fk_subject_id');
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_MV', 'inputevents_mv_fk_hadm_id');
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_MV', 'inputevents_mv_fk_icustay_id');
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
CALL PROC_DROP_FOREIGN_KEY('INPUTEVENTS_MV', 'inputevents_mv_fk_cgid');
ALTER TABLE INPUTEVENTS_MV
ADD CONSTRAINT inputevents_mv_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- -----------
-- LABEVENTS--
-- -----------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('LABEVENTS', 'labevents_fk_subject_id');
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('LABEVENTS', 'labevents_fk_hadm_id');
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- item_id
CALL PROC_DROP_FOREIGN_KEY('LABEVENTS', 'labevents_fk_itemid');
ALTER TABLE LABEVENTS
ADD CONSTRAINT labevents_fk_itemid
  FOREIGN KEY (ITEMID)
  REFERENCES D_LABITEMS(ITEMID);

-- --------------------
-- MICROBIOLOGYEVENTS--
-- --------------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('MICROBIOLOGYEVENTS', 'microbiologyevents_fk_subject_id');
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('MICROBIOLOGYEVENTS', 'microbiologyevents_fk_hadm_id');
ALTER TABLE MICROBIOLOGYEVENTS
ADD CONSTRAINT microbiologyevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ------------
-- NOTEEVENTS--
-- ------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('NOTEEVENTS', 'noteevents_fk_subject_id');
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('NOTEEVENTS', 'noteevents_fk_hadm_id');
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- cgid
CALL PROC_DROP_FOREIGN_KEY('NOTEEVENTS', 'noteevents_fk_cgid');
ALTER TABLE NOTEEVENTS
ADD CONSTRAINT noteevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ----------
-- OUTPUTEVENTS--
-- ----------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('OUTPUTEVENTS', 'outputevents_fk_subject_id');
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('OUTPUTEVENTS', 'outputevents_fk_hadm_id');
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
CALL PROC_DROP_FOREIGN_KEY('OUTPUTEVENTS', 'outputevents_fk_icustay_id');
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
CALL PROC_DROP_FOREIGN_KEY('OUTPUTEVENTS', 'outputevents_fk_cgid');
ALTER TABLE OUTPUTEVENTS
ADD CONSTRAINT outputevents_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ---------------
-- PRESCRIPTIONS--
-- ---------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('PRESCRIPTIONS', 'prescriptions_fk_subject_id');
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('PRESCRIPTIONS', 'prescriptions_fk_hadm_id');
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
CALL PROC_DROP_FOREIGN_KEY('PRESCRIPTIONS', 'prescriptions_fk_icustay_id');
ALTER TABLE PRESCRIPTIONS
ADD CONSTRAINT prescriptions_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- ----------------
-- PROCEDUREEVENTS_MV--
-- ----------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('PROCEDUREEVENTS_MV', 'procedureevents_mv_fk_subject_id');
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('PROCEDUREEVENTS_MV', 'procedureevents_mv_fk_hadm_id');
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- itemid
CALL PROC_DROP_FOREIGN_KEY('PROCEDUREEVENTS_MV', 'procedureevents_mv_fk_icustay_id');
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

-- cgid
CALL PROC_DROP_FOREIGN_KEY('PROCEDUREEVENTS_MV', 'procedureevents_mv_fk_cgid');
ALTER TABLE PROCEDUREEVENTS_MV
ADD CONSTRAINT procedureevents_mv_fk_cgid
  FOREIGN KEY (CGID)
  REFERENCES CAREGIVERS(CGID);

-- ----------------
-- PROCEDURES_ICD--
-- ----------------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('PROCEDURES_ICD', 'procedures_icd_fk_subject_id');
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('PROCEDURES_ICD', 'procedures_icd_fk_hadm_id');
ALTER TABLE PROCEDURES_ICD
ADD CONSTRAINT procedures_icd_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- ICD9_code
-- Cannot impose this constraint because icd9_code contains 1238 codes not in c_icd_diagnoses
-- See https://github.com/MIT-LCP/mimic-code/issues/20, by analogy
-- CALL PROC_DROP_FOREIGN_KEY('PROCEDURES_ICD', 'procedures_icd_fk_icd9');
-- ALTER TABLE PROCEDURES_ICD
-- ADD CONSTRAINT procedures_icd_fk_icd9
--   FOREIGN KEY (icd9_code)
--   REFERENCES d_icd_procedures(icd9_code);

-- ----------
-- SERVICES--
-- ----------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('SERVICES', 'services_fk_subject_id');
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('SERVICES', 'services_fk_hadm_id');
ALTER TABLE SERVICES
ADD CONSTRAINT services_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- -----------
-- TRANSFERS--
-- -----------

-- subject_id
CALL PROC_DROP_FOREIGN_KEY('TRANSFERS', 'transfers_fk_subject_id');
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_subject_id
  FOREIGN KEY (SUBJECT_ID)
  REFERENCES PATIENTS(SUBJECT_ID);

-- hadm_id
CALL PROC_DROP_FOREIGN_KEY('TRANSFERS', 'transfers_fk_hadm_id');
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_hadm_id
  FOREIGN KEY (HADM_ID)
  REFERENCES ADMISSIONS(HADM_ID);

-- icustay_id
CALL PROC_DROP_FOREIGN_KEY('TRANSFERS', 'transfers_fk_icustay_id');
ALTER TABLE TRANSFERS
ADD CONSTRAINT transfers_fk_icustay_id
  FOREIGN KEY (ICUSTAY_ID)
  REFERENCES ICUSTAYS(ICUSTAY_ID);

DROP PROCEDURE PROC_DROP_FOREIGN_KEY;
