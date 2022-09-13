-- --------------------------------------
-- --------------------------------------
-- Indexes for the MIMIC-IV-ED module --
-- --------------------------------------
-- --------------------------------------

-- Note: MySql has no "DROP INDEX IF EXISTS ..." statement,
-- hence running this a second time may error.

-- The load.sql script already creates primary keys for stay_id
-- on stayids and triage, so we don't need to include those.

-- diagnosis

-- DROP INDEX diagnosis_idx01 ON diagnosis;
CREATE INDEX diagnosis_idx01
  ON diagnosis (subject_id, stay_id);
-- DROP INDEX diagnosis_idx02;
CREATE INDEX diagnosis_idx02
  ON diagnosis (icd_code, icd_version);


-- edstays
 
-- DROP INDEX edstays_idx01;
CREATE INDEX edstays_idx01
  ON edstays (subject_id, hadm_id, stay_id);
-- DROP INDEX edstays_idx02;
-- CREATE UNIQUE INDEX edstays_idx02
--   ON edstays (stay_id);
-- DROP INDEX edstays_idx03;
CREATE INDEX edstays_idx03
  ON edstays (intime, outtime);

-- medrecon

-- DROP INDEX medrecon_idx01;
CREATE INDEX medrecon_idx01
  ON medrecon (subject_id, stay_id, charttime);

-- pyxis

-- DROP INDEX pyxis_idx01;
CREATE INDEX pyxis_idx01
  ON pyxis (subject_id, stay_id, charttime);
-- DROP INDEX pyxis_idx02;
CREATE INDEX pyxis_idx02
  ON pyxis (gsn);

-- triage

-- DROP INDEX triage_idx01;
CREATE INDEX triage_idx01
  ON triage (subject_id, stay_id);
-- DROP INDEX triage_idx02;
-- CREATE INDEX triage_idx02
--   ON triage (stay_id);
  
-- vitalsign

-- DROP INDEX vitalsign_idx01;
CREATE INDEX vitalsign_idx01
  ON vitalsign (subject_id, stay_id, charttime);
  
