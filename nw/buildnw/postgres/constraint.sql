---------------------------
---------------------------
-- Creating Primary Keys --
---------------------------
---------------------------

----------
-- hosp --
----------

-- admissions

ALTER TABLE nw_hosp.admissions DROP CONSTRAINT IF EXISTS admissions_pk CASCADE;
ALTER TABLE nw_hosp.admissions
ADD CONSTRAINT admissions_pk
  PRIMARY KEY (hadm_id);

ALTER TABLE nw_hosp.patients DROP CONSTRAINT IF EXISTS patients_pk CASCADE;
ALTER TABLE nw_hosp.patients
ADD CONSTRAINT patients_pk
  PRIMARY KEY (subject_id);

-- d_icd_diagnoses

ALTER TABLE nw_hosp.d_icd_diagnoses DROP CONSTRAINT IF EXISTS d_icd_diagnoses_pk CASCADE;
ALTER TABLE nw_hosp.d_icd_diagnoses
ADD CONSTRAINT d_icd_diagnoses_pk
  PRIMARY KEY (icd_code, icd_version);

-- diagnoses_icd

ALTER TABLE nw_hosp.diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_patients_fk CASCADE;
ALTER TABLE nw_hosp.diagnoses_icd
ADD CONSTRAINT diagnoses_icd_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_hosp.diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_admissions_fk;
ALTER TABLE nw_hosp.diagnoses_icd
ADD CONSTRAINT diagnoses_icd_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES nw_hosp.admissions (hadm_id);

-- d_labitems

ALTER TABLE nw_hosp.d_labitems DROP CONSTRAINT IF EXISTS d_labitems_pk CASCADE;
ALTER TABLE nw_hosp.d_labitems
ADD CONSTRAINT d_labitems_pk
  PRIMARY KEY (itemid);

-- labevents

ALTER TABLE nw_hosp.labevents DROP CONSTRAINT IF EXISTS labevents_pk CASCADE;
ALTER TABLE nw_hosp.labevents
ADD CONSTRAINT labevents_pk
  PRIMARY KEY (labevent_id);

-- prescriptions

ALTER TABLE nw_hosp.prescriptions DROP CONSTRAINT IF EXISTS prescriptions_pk CASCADE;
ALTER TABLE nw_hosp.prescriptions
ADD CONSTRAINT prescriptions_pk
  PRIMARY KEY (pharmacy_id, drug); 

-- emar

ALTER TABLE nw_hosp.emar DROP CONSTRAINT IF EXISTS emar_pk CASCADE;
ALTER TABLE nw_hosp.emar
ADD CONSTRAINT emar_pk
  PRIMARY KEY (emar_id);

---------
-- icu --
---------

-- icustays

ALTER TABLE nw_icu.icustays DROP CONSTRAINT IF EXISTS icustays_pk CASCADE;
ALTER TABLE nw_icu.icustays
ADD CONSTRAINT icustays_pk
  PRIMARY KEY (stay_id);

-- d_items

ALTER TABLE nw_icu.d_items DROP CONSTRAINT IF EXISTS d_items_pk CASCADE;
ALTER TABLE nw_icu.d_items
ADD CONSTRAINT d_items_pk
  PRIMARY KEY (itemid, label);

---------------------------
---------------------------
-- Creating Foreign Keys --
---------------------------
---------------------------

----------
-- hosp --
----------

-- admissions

ALTER TABLE nw_hosp.admissions DROP CONSTRAINT IF EXISTS admissions_patients_fk;
ALTER TABLE nw_hosp.admissions
ADD CONSTRAINT admissions_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

-- diagnoses_icd

ALTER TABLE nw_hosp.diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_patients_fk;
ALTER TABLE nw_hosp.diagnoses_icd
ADD CONSTRAINT diagnoses_icd_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_hosp.diagnoses_icd DROP CONSTRAINT IF EXISTS diagnoses_icd_admissions_fk;
ALTER TABLE nw_hosp.diagnoses_icd
ADD CONSTRAINT diagnoses_icd_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES nw_hosp.admissions (hadm_id);

-- labevents

ALTER TABLE nw_hosp.labevents DROP CONSTRAINT IF EXISTS labevents_patients_fk;
ALTER TABLE nw_hosp.labevents
ADD CONSTRAINT labevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_hosp.labevents DROP CONSTRAINT IF EXISTS labevents_d_labitems_fk;
ALTER TABLE nw_hosp.labevents
ADD CONSTRAINT labevents_d_labitems_fk
  FOREIGN KEY (itemid)
  REFERENCES nw_hosp.d_labitems (itemid);

-- prescriptions

ALTER TABLE nw_hosp.prescriptions DROP CONSTRAINT IF EXISTS prescriptions_patients_fk;
ALTER TABLE nw_hosp.prescriptions
ADD CONSTRAINT prescriptions_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_hosp.prescriptions DROP CONSTRAINT IF EXISTS prescriptions_admissions_fk;
ALTER TABLE nw_hosp.prescriptions
ADD CONSTRAINT prescriptions_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES nw_hosp.admissions (hadm_id);

-- emar

ALTER TABLE nw_hosp.emar DROP CONSTRAINT IF EXISTS emar_patients_fk;
ALTER TABLE nw_hosp.emar
ADD CONSTRAINT emar_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_hosp.emar DROP CONSTRAINT IF EXISTS emar_admissions_fk;
ALTER TABLE nw_hosp.emar
ADD CONSTRAINT emar_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES nw_hosp.admissions (hadm_id);

---------
-- icu --
---------

-- icustays

ALTER TABLE nw_icu.icustays DROP CONSTRAINT IF EXISTS icustays_patients_fk;
ALTER TABLE nw_icu.icustays
ADD CONSTRAINT icustays_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_icu.icustays DROP CONSTRAINT IF EXISTS icustays_admissions_fk;
ALTER TABLE nw_icu.icustays
ADD CONSTRAINT icustays_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES nw_hosp.admissions (hadm_id);

-- chartevents

ALTER TABLE nw_icu.chartevents DROP CONSTRAINT IF EXISTS chartevents_patients_fk;
ALTER TABLE nw_icu.chartevents
ADD CONSTRAINT chartevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_icu.chartevents DROP CONSTRAINT IF EXISTS chartevents_admissions_fk;
ALTER TABLE nw_icu.chartevents
ADD CONSTRAINT chartevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES nw_hosp.admissions (hadm_id);

ALTER TABLE nw_icu.chartevents DROP CONSTRAINT IF EXISTS chartevents_icustays_fk;
ALTER TABLE nw_icu.chartevents
ADD CONSTRAINT chartevents_icustays_fk
  FOREIGN KEY (stay_id)
  REFERENCES nw_icu.icustays (stay_id);

  -- procedureevents

ALTER TABLE nw_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_patients_fk;
ALTER TABLE nw_icu.procedureevents
ADD CONSTRAINT procedureevents_patients_fk
  FOREIGN KEY (subject_id)
  REFERENCES nw_hosp.patients (subject_id);

ALTER TABLE nw_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_admissions_fk;
ALTER TABLE nw_icu.procedureevents
ADD CONSTRAINT procedureevents_admissions_fk
  FOREIGN KEY (hadm_id)
  REFERENCES nw_hosp.admissions (hadm_id);

ALTER TABLE nw_icu.procedureevents DROP CONSTRAINT IF EXISTS procedureevents_icustays_fk;
ALTER TABLE nw_icu.procedureevents
ADD CONSTRAINT procedureevents_icustays_fk
  FOREIGN KEY (stay_id)
  REFERENCES nw.icustays (stay_id);
