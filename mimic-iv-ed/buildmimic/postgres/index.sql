----------------------------------------
----------------------------------------
-- Indexes for the MIMIC-IV-ED module --
----------------------------------------
----------------------------------------

-- patients
DROP INDEX IF EXISTS patients_idx01;
CREATE INDEX patients_idx01
  ON patients (anchor_age);

DROP INDEX IF EXISTS patients_idx02;
CREATE INDEX patients_idx02
  ON patients (anchor_year);

-- admissions
 
DROP INDEX IF EXISTS admissions_idx01;
CREATE INDEX admissions_idx01
  ON admissions (admittime, dischtime, deathtime);

-- transfers

DROP INDEX IF EXISTS transfers_idx01;
CREATE INDEX transfers_idx01
  ON transfers (hadm_id);

DROP INDEX IF EXISTS transfers_idx02;
CREATE INDEX transfers_idx02
  ON transfers (intime);

DROP INDEX IF EXISTS transfers_idx03;
CREATE INDEX transfers_idx03
  ON transfers (careunit);
