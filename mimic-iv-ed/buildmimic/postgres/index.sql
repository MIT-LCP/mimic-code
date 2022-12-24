----------------------------------------
----------------------------------------
-- Indexes for the MIMIC-IV-ED module --
----------------------------------------
----------------------------------------

SET search_path TO mimiciv_ed;

-- diagnosis

DROP INDEX IF EXISTS diagnosis_idx01;
CREATE INDEX diagnosis_idx01
  ON diagnosis (subject_id, stay_id);

DROP INDEX IF EXISTS diagnosis_idx02;
CREATE INDEX diagnosis_idx02
  ON diagnosis (icd_code, icd_version);

-- edstays

DROP INDEX IF EXISTS edstays_idx01;
CREATE INDEX edstays_idx01
  ON edstays (subject_id, hadm_id, stay_id);

DROP INDEX IF EXISTS edstays_idx02;
CREATE INDEX edstays_idx02
  ON edstays (intime, outtime);

-- medrecon

DROP INDEX IF EXISTS medrecon_idx01;
CREATE INDEX medrecon_idx01
  ON medrecon (subject_id, stay_id, charttime);

-- pyxis

DROP INDEX IF EXISTS pyxis_idx01;
CREATE INDEX pyxis_idx01
  ON pyxis (subject_id, stay_id, charttime);

DROP INDEX IF EXISTS pyxis_idx02;
CREATE INDEX pyxis_idx02
  ON pyxis (gsn);

-- triage

DROP INDEX IF EXISTS triage_idx01;
CREATE INDEX triage_idx01
  ON triage (subject_id, stay_id);

-- vitalsign

DROP INDEX IF EXISTS vitalsign_idx01;
CREATE INDEX vitalsign_idx01
  ON vitalsign (subject_id, stay_id, charttime);
