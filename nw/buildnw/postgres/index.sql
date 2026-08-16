--------------------------------------
--------------------------------------
-- Indexes for all NW modules    --
--------------------------------------
--------------------------------------

----------
-- hosp --
----------

SET search_path TO nw_hosp;

-- admissions

DROP INDEX IF EXISTS admissions_idx01;
CREATE INDEX admissions_idx01
	ON admissions (admittime, dischtime, deathtime); 

-- patients

DROP INDEX IF EXISTS patients_idx01;
CREATE INDEX patients_idx01
	ON patients (anchor_age);

DROP INDEX IF EXISTS patients_idx02;
CREATE INDEX patients_idx02
  ON patients (anchor_year);

-- d_icd_diagnoses

DROP INDEX IF EXISTS d_icd_diagnoses_idx01;
CREATE INDEX d_icd_diagnoses_idx01
    ON d_icd_diagnoses (long_title);

DROP INDEX IF EXISTS d_icd_diagnoses_idx02;
CREATE INDEX d_icd_diagnoses_idx02
    ON d_icd_diagnoses (icd_code);

-- diagnoses_icd

DROP INDEX IF EXISTS diagnoses_icd_idx01;
CREATE INDEX diagnoses_icd_idx01
  ON diagnoses_icd (icd_code);

DROP INDEX IF EXISTS diagnoses_icd_idx02;
CREATE INDEX diagnoses_icd_idx02
  ON diagnoses_icd (icd_code, icd_version);

-- d_labitems

DROP INDEX IF EXISTS d_labitems_idx01;
CREATE INDEX d_labitems_idx01
	ON d_labitems (label, fluid, category);

DROP INDEX IF EXISTS d_labitems_idx02;
CREATE INDEX d_labitems_idx02
    ON d_labitems (itemid);

-- labevents

DROP INDEX IF EXISTS labevents_idx01;
CREATE INDEX labevents_idx01
	ON labevents (charttime, storetime);

DROP INDEX IF EXISTS labevents_idx02;
CREATE INDEX labevents_idx02
    ON labevents (specimen_id);

DROP INDEX IF EXISTS labevents_idx03;
CREATE INDEX labevents_idx03
    ON labevents (itemid);

-- prescriptions

DROP INDEX IF EXISTS prescriptions_idx01;
CREATE INDEX prescriptions_idx01
	ON prescriptions (starttime, stoptime);

DROP INDEX IF EXISTS prescriptions_idx02;
CREATE INDEX prescriptions_idx02
    ON prescriptions (ndc);

-- emar

DROP INDEX IF EXISTS emar_idx01;
CREATE INDEX emar_idx01
  ON emar (poe_id);

DROP INDEX IF EXISTS emar_idx02;
CREATE INDEX emar_idx02
  ON emar (pharmacy_id);

DROP INDEX IF EXISTS emar_idx03;
CREATE INDEX emar_idx03
  ON emar (charttime, scheduletime, storetime);

DROP INDEX IF EXISTS emar_idx04;
CREATE INDEX emar_idx04
  ON emar (medication);

---------
-- icu --
---------

SET search_path TO nw_icu;

-- chartevents

DROP INDEX IF EXISTS chartevents_idx01;
CREATE INDEX chartevents_idx01
	ON chartevents (charttime, itemid);

DROP INDEX IF EXISTS chartevents_idx02;
CREATE INDEX chartevents_idx02
    ON chartevents (itemid);

-- d_items

DROP INDEX IF EXISTS d_items_idx01;
CREATE INDEX d_items_idx01
	ON d_items (label, abbreviation);

DROP INDEX IF EXISTS d_items_idx02;
CREATE INDEX d_items_idx02
  ON d_items (category);

DROP INDEX IF EXISTS d_items_idx03;
CREATE INDEX d_items_idx03
  ON d_items (itemid);

-- icustays

DROP INDEX IF EXISTS icustays_idx01;
CREATE INDEX icustays_idx01
  ON icustays (first_careunit, last_careunit);

DROP INDEX IF EXISTS icustays_idx02;
CREATE INDEX icustays_idx02
  ON icustays (intime, outtime);

-- procedureevents

DROP INDEX IF EXISTS procedureevents_idx01;
CREATE INDEX procedureevents_idx01
	ON procedureevents (starttime, itemid);

DROP INDEX IF EXISTS procedureevents_idx02;
CREATE INDEX procedureevents_idx02
	ON procedureevents (ordercategoryname);

DROP INDEX IF EXISTS procedureevents_idx03;
CREATE INDEX procedureevents_idx03
    ON procedureevents (itemid);
