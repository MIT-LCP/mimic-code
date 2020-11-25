---------------------------
---------------------------
-- Creating Primary Keys --
---------------------------
---------------------------

----------
-- core --
----------

-- patients

ALTER TABLE mimic_core.patients DROP CONSTRAINT IF EXISTS patients_pk CASCADE;
ALTER TABLE mimic_core.patients
ADD CONSTRAINT patients_pk
  PRIMARY KEY (subject_id);

-- admissions

ALTER TABLE mimic_core.admissions DROP CONSTRAINT IF EXISTS admissions_pk CASCADE;
ALTER TABLE mimic_core.admissions
ADD CONSTRAINT admissions_pk
  PRIMARY KEY (hadm_id);

-- transfers

ALTER TABLE mimic_core.transfers DROP CONSTRAINT IF EXISTS transfers_pk CASCADE;
ALTER TABLE mimic_core.transfers
ADD CONSTRAINT transfers_pk
  PRIMARY KEY (transfer_id);

----------
-- hosp --
----------

-- d_hcpcs

ALTER TABLE mimic_hosp.d_hcpcs DROP CONSTRAINT IF EXISTS d_hcpcs_pk CASCADE;
ALTER TABLE mimic_hosp.d_hcpcs
ADD CONSTRAINT d_hcpcs_pk
  PRIMARY KEY (code);

-- diagnoses_icd

ALTER TABLE mimic_hosp.diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_pk CASCADE;
ALTER TABLE mimic_hosp.diagnoses_icd
ADD CONSTRAINT diagnoses_icd_pk
  PRIMARY KEY (hadm_id, seq_num, icd_code, icd_version);

-- d_icd_diagnoses

ALTER TABLE mimic_hosp.d_icd_diagnoses DROP CONSTRAINT IF EXISTS d_icd_diagnoses_pk CASCADE;
ALTER TABLE mimic_hosp.d_icd_diagnoses
ADD CONSTRAINT d_icd_diagnoses_pk
  PRIMARY KEY (icd_code, icd_version);

-- d_icd_procedures

ALTER TABLE mimic_hosp.d_icd_procedures DROP CONSTRAINT IF EXISTS d_icd_procedures_pk CASCADE;
ALTER TABLE mimic_hosp.d_icd_procedures
ADD CONSTRAINT d_icd_procedures_pk
  PRIMARY KEY (icd_code, icd_version);

-- d_labitems

ALTER TABLE mimic_hosp.d_labitems DROP CONSTRAINT IF EXISTS d_labitems_pk CASCADE;
ALTER TABLE mimic_hosp.d_labitems
ADD CONSTRAINT d_labitems_pk
  PRIMARY KEY (itemid);

-- emar_detail

-- ALTER TABLE mimic_hosp.emar_detail DROP CONSTRAINT IF EXISTS emar_detail_pk;
-- ALTER TABLE mimic_hosp.emar_detail
-- ADD CONSTRAINT emar_detail_pk
--   PRIMARY KEY (emar_id, parent_field_ordinal);

-- emar

ALTER TABLE mimic_hosp.emar DROP CONSTRAINT IF EXISTS emar_pk CASCADE;
ALTER TABLE mimic_hosp.emar
ADD CONSTRAINT emar_pk
  PRIMARY KEY (emar_id);

-- hcpcsevents

ALTER TABLE mimic_hosp.hcpcsevents DROP CONSTRAINT IF EXISTS hcpcsevents_pk CASCADE;
ALTER TABLE mimic_hosp.hcpcsevents
ADD CONSTRAINT hcpcsevents_pk
  PRIMARY KEY (hadm_id, hcpcs_cd, seq_num);

-- labevents

ALTER TABLE mimic_hosp.labevents DROP CONSTRAINT IF EXISTS labevents_pk CASCADE;
ALTER TABLE mimic_hosp.labevents
ADD CONSTRAINT labevents_pk
  PRIMARY KEY (labevent_id);

-- microbiologyevents

ALTER TABLE mimic_hosp.microbiologyevents DROP CONSTRAINT IF EXISTS microbiologyevents_pk CASCADE;
ALTER TABLE mimic_hosp.microbiologyevents
ADD CONSTRAINT microbiologyevents_pk
  PRIMARY KEY (microevent_id);

-- pharmacy

ALTER TABLE mimic_hosp.pharmacy DROP CONSTRAINT IF EXISTS pharmacy_pk CASCADE;
ALTER TABLE mimic_hosp.pharmacy
ADD CONSTRAINT pharmacy_pk
  PRIMARY KEY (pharmacy_id);

-- poe_detail

ALTER TABLE mimic_hosp.poe_detail DROP CONSTRAINT IF EXISTS poe_detail_pk CASCADE;
ALTER TABLE mimic_hosp.poe_detail
ADD CONSTRAINT poe_detail_pk
  PRIMARY KEY (poe_id, field_name);

-- poe

ALTER TABLE mimic_hosp.poe DROP CONSTRAINT IF EXISTS poe_pk CASCADE;
ALTER TABLE mimic_hosp.poe
ADD CONSTRAINT poe_pk
  PRIMARY KEY (poe_id);

-- prescriptions

ALTER TABLE mimic_hosp.prescriptions DROP CONSTRAINT IF EXISTS prescriptions_pk CASCADE;
ALTER TABLE mimic_hosp.prescriptions
ADD CONSTRAINT prescriptions_pk
  PRIMARY KEY (pharmacy_id, drug_type, drug);

-- procedures_icd

ALTER TABLE mimic_hosp.procedures_icd DROP CONSTRAINT IF EXISTS procedures_icd_pk CASCADE;
ALTER TABLE mimic_hosp.procedures_icd
ADD CONSTRAINT procedures_icd_pk
  PRIMARY KEY (hadm_id, seq_num, icd_code, icd_version);

-- services

ALTER TABLE mimic_hosp.services DROP CONSTRAINT IF EXISTS services_pk CASCADE;
ALTER TABLE mimic_hosp.services
ADD CONSTRAINT services_pk
  PRIMARY KEY (hadm_id, transfertime, curr_service);

---------
-- icu --
---------

-- datetimeevents

ALTER TABLE mimic_icu.datetimeevents DROP CONSTRAINT IF EXISTS datetimeevents_pk CASCADE;
ALTER TABLE mimic_icu.datetimeevents
ADD CONSTRAINT datetimeevents_pk
  PRIMARY KEY (stay_id, itemid, charttime);

-- d_items

ALTER TABLE mimic_icu.d_items DROP CONSTRAINT IF EXISTS d_items_pk CASCADE;
ALTER TABLE mimic_icu.d_items
ADD CONSTRAINT d_items_pk
  PRIMARY KEY (itemid);

-- icustays

ALTER TABLE mimic_icu.icustays DROP CONSTRAINT IF EXISTS icustays_pk CASCADE;
ALTER TABLE mimic_icu.icustays
ADD CONSTRAINT icustays_pk
  PRIMARY KEY (stay_id);

-- inputevents

ALTER TABLE mimic_icu.inputevents DROP CONSTRAINT IF EXISTS inputevents_pk CASCADE;
ALTER TABLE mimic_icu.inputevents
ADD CONSTRAINT inputevents_pk
  PRIMARY KEY (orderid, itemid);

-- outputevents

ALTER TABLE mimic_icu.outputevents DROP CONSTRAINT IF EXISTS outputevents_pk CASCADE;
ALTER TABLE mimic_icu.outputevents
ADD CONSTRAINT outputevents_pk
  PRIMARY KEY (stay_id, charttime, itemid);

-- procedureevents

ALTER TABLE mimic_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_pk CASCADE;
ALTER TABLE mimic_icu.procedureevents
ADD CONSTRAINT procedureevents_pk
  PRIMARY KEY (orderid);

---------------------------
---------------------------
-- Creating Foreign Keys --
---------------------------
---------------------------

----------
-- core --
----------

-- admissions

ALTER TABLE mimic_core.admissions DROP CONSTRAINT IF EXISTS admissions_patients_fk;
ALTER TABLE mimic_core.admissions
ADD CONSTRAINT admissions_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

-- transfers

ALTER TABLE mimic_core.transfers DROP CONSTRAINT IF EXISTS transfers_patients_fk;
ALTER TABLE mimic_core.transfers
ADD CONSTRAINT transfers_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

----------
-- hosp --
----------

-- diagnoses_icd

ALTER TABLE mimic_hosp.diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_patients_fk;
ALTER TABLE mimic_hosp.diagnoses_icd
ADD CONSTRAINT diagnoses_icd_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_admissions_fk;
ALTER TABLE mimic_hosp.diagnoses_icd
ADD CONSTRAINT diagnoses_icd_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- drgcodes

ALTER TABLE mimic_hosp.drgcodes DROP CONSTRAINT IF EXISTS drgcodes_patients_fk;
ALTER TABLE mimic_hosp.drgcodes
ADD CONSTRAINT drgcodes_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.drgcodes DROP CONSTRAINT IF EXISTS drgcodes_admissions_fk;
ALTER TABLE mimic_hosp.drgcodes
ADD CONSTRAINT drgcodes_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- emar_detail

ALTER TABLE mimic_hosp.emar_detail DROP CONSTRAINT IF EXISTS emar_detail_patients_fk;
ALTER TABLE mimic_hosp.emar_detail
ADD CONSTRAINT emar_detail_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.emar_detail DROP CONSTRAINT IF EXISTS emar_detail_emar_fk;
ALTER TABLE mimic_hosp.emar_detail
ADD CONSTRAINT emar_detail_emar_fk
  FOREIGN KEY (emar_id)
  REFERENCES mimic_hosp.emar (emar_id);

-- emar

ALTER TABLE mimic_hosp.emar DROP CONSTRAINT IF EXISTS emar_patients_fk;
ALTER TABLE mimic_hosp.emar
ADD CONSTRAINT emar_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.emar DROP CONSTRAINT IF EXISTS emar_admissions_fk;
ALTER TABLE mimic_hosp.emar
ADD CONSTRAINT emar_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- hcpcsevents

ALTER TABLE mimic_hosp.hcpcsevents DROP CONSTRAINT IF EXISTS hcpcsevents_patients_fk;
ALTER TABLE mimic_hosp.hcpcsevents
ADD CONSTRAINT hcpcsevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.hcpcsevents DROP CONSTRAINT IF EXISTS hcpcsevents_admissions_fk;
ALTER TABLE mimic_hosp.hcpcsevents
ADD CONSTRAINT hcpcsevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

ALTER TABLE mimic_hosp.hcpcsevents DROP CONSTRAINT IF EXISTS hcpcsevents_d_hcpcs_fk;
ALTER TABLE mimic_hosp.hcpcsevents
ADD CONSTRAINT hcpcsevents_d_hcpcs_fk
  FOREIGN KEY (hcpcs_cd)
  REFERENCES mimic_hosp.d_hcpcs (code);

-- labevents

ALTER TABLE mimic_hosp.labevents DROP CONSTRAINT IF EXISTS labevents_patients_fk;
ALTER TABLE mimic_hosp.labevents
ADD CONSTRAINT labevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.labevents DROP CONSTRAINT IF EXISTS labevents_d_labitems_fk;
ALTER TABLE mimic_hosp.labevents
ADD CONSTRAINT labevents_d_labitems_fk
  FOREIGN KEY (itemid)
  REFERENCES mimic_hosp.d_labitems (itemid);

-- microbiologyevents

ALTER TABLE mimic_hosp.microbiologyevents DROP CONSTRAINT IF EXISTS microbiologyevents_patients_fk;
ALTER TABLE mimic_hosp.microbiologyevents
ADD CONSTRAINT microbiologyevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.microbiologyevents DROP CONSTRAINT IF EXISTS microbiologyevents_admissions_fk;
ALTER TABLE mimic_hosp.microbiologyevents
ADD CONSTRAINT microbiologyevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- pharmacy

ALTER TABLE mimic_hosp.pharmacy DROP CONSTRAINT IF EXISTS pharmacy_patients_fk;
ALTER TABLE mimic_hosp.pharmacy
ADD CONSTRAINT pharmacy_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.pharmacy DROP CONSTRAINT IF EXISTS pharmacy_admissions_fk;
ALTER TABLE mimic_hosp.pharmacy
ADD CONSTRAINT pharmacy_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- poe_detail

ALTER TABLE mimic_hosp.poe_detail DROP CONSTRAINT IF EXISTS poe_detail_patients_fk;
ALTER TABLE mimic_hosp.poe_detail
ADD CONSTRAINT poe_detail_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.poe_detail DROP CONSTRAINT IF EXISTS poe_detail_poe_fk;
ALTER TABLE mimic_hosp.poe_detail
ADD CONSTRAINT poe_detail_poe_fk
  FOREIGN KEY (poe_id)
  REFERENCES mimic_hosp.poe (poe_id);

-- poe

ALTER TABLE mimic_hosp.poe DROP CONSTRAINT IF EXISTS poe_patients_fk;
ALTER TABLE mimic_hosp.poe
ADD CONSTRAINT poe_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.poe DROP CONSTRAINT IF EXISTS poe_admissions_fk;
ALTER TABLE mimic_hosp.poe
ADD CONSTRAINT poe_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- prescriptions

ALTER TABLE mimic_hosp.prescriptions DROP CONSTRAINT IF EXISTS prescriptions_patients_fk;
ALTER TABLE mimic_hosp.prescriptions
ADD CONSTRAINT prescriptions_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.prescriptions DROP CONSTRAINT IF EXISTS prescriptions_admissions_fk;
ALTER TABLE mimic_hosp.prescriptions
ADD CONSTRAINT prescriptions_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- procedures_icd

ALTER TABLE mimic_hosp.procedures_icd DROP CONSTRAINT IF EXISTS procedures_icd_patients_fk;
ALTER TABLE mimic_hosp.procedures_icd
ADD CONSTRAINT procedures_icd_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.procedures_icd DROP CONSTRAINT IF EXISTS procedures_icd_admissions_fk;
ALTER TABLE mimic_hosp.procedures_icd
ADD CONSTRAINT procedures_icd_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- services

ALTER TABLE mimic_hosp.services DROP CONSTRAINT IF EXISTS services_patients_fk;
ALTER TABLE mimic_hosp.services
ADD CONSTRAINT services_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_hosp.services DROP CONSTRAINT IF EXISTS services_admissions_fk;
ALTER TABLE mimic_hosp.services
ADD CONSTRAINT services_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

---------
-- icu --
---------

-- chartevents

ALTER TABLE mimic_icu.chartevents DROP CONSTRAINT IF EXISTS chartevents_patients_fk;
ALTER TABLE mimic_icu.chartevents
ADD CONSTRAINT chartevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_icu.chartevents DROP CONSTRAINT IF EXISTS chartevents_admissions_fk;
ALTER TABLE mimic_icu.chartevents
ADD CONSTRAINT chartevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

ALTER TABLE mimic_icu.chartevents DROP CONSTRAINT IF EXISTS chartevents_icustays_fk;
ALTER TABLE mimic_icu.chartevents
ADD CONSTRAINT chartevents_icustays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_icu.icustays (stay_id);

ALTER TABLE mimic_icu.chartevents DROP CONSTRAINT IF EXISTS chartevents_d_items_fk;
ALTER TABLE mimic_icu.chartevents
ADD CONSTRAINT chartevents_d_items_fk
  FOREIGN KEY (itemid)
  REFERENCES mimic_icu.d_items (itemid);

-- datetimeevents

ALTER TABLE mimic_icu.datetimeevents DROP CONSTRAINT IF EXISTS datetimeevents_patients_fk;
ALTER TABLE mimic_icu.datetimeevents
ADD CONSTRAINT datetimeevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_icu.datetimeevents DROP CONSTRAINT IF EXISTS datetimeevents_admissions_fk;
ALTER TABLE mimic_icu.datetimeevents
ADD CONSTRAINT datetimeevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

ALTER TABLE mimic_icu.datetimeevents DROP CONSTRAINT IF EXISTS datetimeevents_icustays_fk;
ALTER TABLE mimic_icu.datetimeevents
ADD CONSTRAINT datetimeevents_icustays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_icu.icustays (stay_id);

ALTER TABLE mimic_icu.datetimeevents DROP CONSTRAINT IF EXISTS datetimeevents_d_items_fk;
ALTER TABLE mimic_icu.datetimeevents
ADD CONSTRAINT datetimeevents_d_items_fk
  FOREIGN KEY (itemid)
  REFERENCES mimic_icu.d_items (itemid);

-- icustays

ALTER TABLE mimic_icu.icustays DROP CONSTRAINT IF EXISTS icustays_patients_fk;
ALTER TABLE mimic_icu.icustays
ADD CONSTRAINT icustays_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_icu.icustays DROP CONSTRAINT IF EXISTS icustays_admissions_fk;
ALTER TABLE mimic_icu.icustays
ADD CONSTRAINT icustays_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

-- inputevents

ALTER TABLE mimic_icu.inputevents DROP CONSTRAINT IF EXISTS inputevents_patients_fk;
ALTER TABLE mimic_icu.inputevents
ADD CONSTRAINT inputevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_icu.inputevents DROP CONSTRAINT IF EXISTS inputevents_admissions_fk;
ALTER TABLE mimic_icu.inputevents
ADD CONSTRAINT inputevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

ALTER TABLE mimic_icu.inputevents DROP CONSTRAINT IF EXISTS inputevents_icustays_fk;
ALTER TABLE mimic_icu.inputevents
ADD CONSTRAINT inputevents_icustays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_icu.icustays (stay_id);

ALTER TABLE mimic_icu.inputevents DROP CONSTRAINT IF EXISTS inputevents_d_items_fk;
ALTER TABLE mimic_icu.inputevents
ADD CONSTRAINT inputevents_d_items_fk
  FOREIGN KEY (itemid)
  REFERENCES mimic_icu.d_items (itemid);

-- outputevents

ALTER TABLE mimic_icu.outputevents DROP CONSTRAINT IF EXISTS outputevents_patients_fk;
ALTER TABLE mimic_icu.outputevents
ADD CONSTRAINT outputevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_icu.outputevents DROP CONSTRAINT IF EXISTS outputevents_admissions_fk;
ALTER TABLE mimic_icu.outputevents
ADD CONSTRAINT outputevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

ALTER TABLE mimic_icu.outputevents DROP CONSTRAINT IF EXISTS outputevents_icustays_fk;
ALTER TABLE mimic_icu.outputevents
ADD CONSTRAINT outputevents_icustays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_icu.icustays (stay_id);

ALTER TABLE mimic_icu.outputevents DROP CONSTRAINT IF EXISTS outputevents_d_items_fk;
ALTER TABLE mimic_icu.outputevents
ADD CONSTRAINT outputevents_d_items_fk
  FOREIGN KEY (itemid)
  REFERENCES mimic_icu.d_items (itemid);

-- procedureevents

ALTER TABLE mimic_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_patients_fk;
ALTER TABLE mimic_icu.procedureevents
ADD CONSTRAINT procedureevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES mimic_core.patients (subject_id);

ALTER TABLE mimic_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_admissions_fk;
ALTER TABLE mimic_icu.procedureevents
ADD CONSTRAINT procedureevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES mimic_core.admissions (hadm_id);

ALTER TABLE mimic_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_icustays_fk;
ALTER TABLE mimic_icu.procedureevents
ADD CONSTRAINT procedureevents_icustays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_icu.icustays (stay_id);

ALTER TABLE mimic_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_d_items_fk;
ALTER TABLE mimic_icu.procedureevents
ADD CONSTRAINT procedureevents_d_items_fk
  FOREIGN KEY (itemid)
  REFERENCES mimic_icu.d_items (itemid);
