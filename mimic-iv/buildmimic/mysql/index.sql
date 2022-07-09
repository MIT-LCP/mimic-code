
-- ----------------------------------------------------------------
--
-- This is a script to add the MIMIC-IV indexes for MySQL.
--
-- These are indexes that were not automagically created as UNIQUE KEY
-- constraints in the define-load step as determined by csv2mysql.
-- They include non-unique keys and multi-column keys that are
-- semantically meaningful.
--
-- These index definitions should be taken as mere suggestions. Which
-- indexes make sense depend on the applications.
--
-- Comments show UNIQUE KEY indexes on the relevant tables.
-- 
-- ----------------------------------------------------------------


-- -----------
-- admissions
-- -----------

alter table admissions
  add index admissions_idx01 (subject_id,hadm_id),
  add index admissions_idx02 (admittime, dischtime, deathtime),
  add index admissions_idx03 (admission_type),
  add unique index admissions_idx04 (hadm_id);

-- -------------
-- chartevents
-- -------------
alter table chartevents 
  add index chartevents_idx01 (subject_id, hadm_id, stay_id),
  add index chartevents_idx02 (itemid),
  add index chartevents_idx03 (charttime, storetime);

-- Perhaps not useful to index on just value? Index just for popular subset?
-- CREATE INDEX CHARTEVENTS_idx05 ON CHARTEVENTS (VALUE);

-- -----------
-- d_hcpcs
-- -----------

alter table d_hcpcs
  add unique index d_hcpcs_idx01 (code);

-- -----------
-- d_icd_diagnoses
-- -----------

alter table d_icd_diagnoses
  add unique index d_icd_diagnoses_icd_code_icd_version (icd_code, icd_version);

-- -----------
-- d_icd_procedures
-- -----------

alter table d_icd_procedures
  add unique index d_icd_procedures_idx01 (icd_code, icd_version);

-- ---------
-- d_items
-- ---------

alter table d_items
  add unique index d_items_idx01 (itemid),
  add index d_items_idx02 (label(200)),
  add index d_items_idx03 (category),
  add index d_items_idx04 (abbreviation),
  add index d_items_idx05 (param_type);

-- -------------
-- d_labitems
-- -------------

alter table d_labitems
  add unique index d_labitems_idx01 (itemid),
  add index d_labitems_idx02 (label, fluid, category);

-- -----------------
-- datetimeevents
-- -----------------

alter table datetimeevents
  add index datetimeevents_idx01 (subject_id, hadm_id, stay_id),
  add index datetimeevents_idx02 (itemid),
  add index datetimeevents_idx03 (charttime),
  add index datetimeevents_idx04 (value);

-- ----------------
-- diagnoses_icd
-- ----------------

alter table diagnoses_icd 
  add index diagnoses_icd_idx01 (subject_id, hadm_id),
  add index diagnoses_icd_idx02 (icd_code, icd_version, seq_num);

-- ------------
-- drgcodes
-- ------------

alter table drgcodes
  add index drgcodes_idx01 (subject_id, hadm_id),
  add index drgcodes_idx02 (drg_code, drg_type),
  add index drgcodes_idx03 (description(255), drg_severity);

-- ----------------
-- emar
-- ----------------

alter table emar
  add primary key(emar_id),
  add index emar_idx01 (subject_id, hadm_id, emar_seq),
  add index emar_idx03 (poe_id),
  add index emar_idx04 (pharmacy_id),
  add index emar_idx05 (charttime, scheduletime, storetime),
  add index emar_idx06 (medication);

-- ----------------
-- emar_detail
-- ----------------

alter table emar_detail
  add index emar_idx01 (subject_id, emar_seq),
  add index emar_idx02 (emar_id),
  add index emar_idx04 (pharmacy_id),
  add index emar_idx05 (product_description(200)),
  add index emar_idx06 (product_code);

-- ----------------
-- hcpsevents
-- ----------------

alter table hcpcsevents
  add index hcpcsevents_idx01 (subject_id, hadm_id, seq_num),
  add index hcpcsevents_idx02 (hcpcs_cd);
  
-- --------------
-- icustays
-- --------------

alter table icustays
  add index icustays_idx01 (subject_id, hadm_id, stay_id),
  add index icustays_idx02 (first_careunit, last_careunit),
  add index icustays_idx03 (intime, outtime);

-- --------------
-- inputevents
-- --------------

alter table inputevents
  add index inputevents_idx01 (subject_id, hadm_id, stay_id),
  add index inputevents_idx02 (stay_id),
  add index inputevents_idx03 (starttime, endtime),
  add index inputevents_idx04 (itemid),
  add index inputevents_idx05 (rate),
  add index inputevents_idx06 (amount);

-- ------------
-- labevents
-- ------------

alter table labevents 
  add index labevents_idx01 (subject_id, hadm_id),
  add index labevents_idx02 (itemid),
  add index labevents_idx03 (charttime),
  add index labevents_idx04 (valuenum),
  add index labevents_idx05 (value(200)),
  add unique index labevents_idx06 (labevent_id, itemid);
-- Note: itemid (by which labevents in partitioned) must be part of the primary key.

-- --------------------
-- microbiologyevents
-- --------------------

alter table microbiologyevents 
  add index microbiologyevents_idx01 (subject_id, hadm_id),
  add index microbiologyevents_idx02 (chartdate, charttime),
  add index microbiologyevents_idx03 (spec_itemid, org_itemid, ab_itemid);

-- --------------
-- outputevents
-- --------------

alter table outputevents
  add index outputevents_idx01 (subject_id, hadm_id),
  add index outputevents_idx02 (stay_id),
  add index outputevents_idx03 (charttime, storetime),
  add index outputevents_idx04 (itemid),
  add index outputevents_idx05 (value);

-- -----------
-- patients
-- -----------

-- note that subject_id is already indexed as it is unique

alter table patients
  add unique index patients_idx01 (subject_id),
  add index patients_idx02 (dod),
  add index patients_idx03 (anchor_age),
  add index patients_idx04 (anchor_year);

-- ----------------
-- pharmacy
-- ----------------

alter table pharmacy
  add index pharmacy_idx01 (subject_id, hadm_id),
  add index pharmacy_idx02 (pharmacy_id),
  add index pharmacy_idx03 (starttime, stoptime),
  add index pharmacy_idx04 (medication);

-- ----------------
-- poe
-- ----------------

alter table poe
  add unique index poe_idx01 (poe_id, poe_seq),
  add index poe_idx02 (subject_id, hadm_id),
  add index poe_idx03 (order_type);

-- ----------------
-- poe-detail
-- ----------------

alter table poe_detail
  add index poe_detail_idx01 (poe_id, poe_seq),
  add index poe_detail_idx02 (subject_id),
  add index poe_detail_idx03 (field_name);

-- ----------------
-- prescriptions
-- ----------------

alter table prescriptions
  add index prescriptions_idx01 (subject_id, hadm_id),
  add index prescriptions_idx02 (pharmacy_id),
  add index prescriptions_idx03 (drug_type),
  add index prescriptions_idx04 (drug),
  add index prescriptions_idx05 (starttime, stoptime);

-- -----------------
-- procedureevents
-- -----------------

alter table procedureevents
  add index procedureevents_mv_idx01 (subject_id, hadm_id),
  add index procedureevents_mv_idx02 (stay_id),
  add index procedureevents_mv_idx03 (itemid),
  add index procedureevents_mv_idx04 (starttime, endtime),
  add index procedureevents_mv_idx05 (ordercategoryname);
      
-- -----------------
-- procedures_icd
-- -----------------

alter table procedures_icd
  add index procedures_icd_idx01 (subject_id, hadm_id, seq_num),
  add index procedures_icd_idx02 (icd_code, icd_version);

-- -----------
-- services
-- -----------

alter table services
  add index services_idx01 (subject_id, hadm_id),
  add index services_idx02 (transfertime),
  add index services_idx03 (curr_service, prev_service);

-- -----------
-- transfers
-- -----------

alter table transfers
  add index transfers_idx01 (subject_id, hadm_id),
  add index transfers_idx02 (eventtype),
  add index transfers_idx03 (careunit),
  add index transfers_idx04 (intime, outtime),
  add index transfers_idx05 (transfer_id);

