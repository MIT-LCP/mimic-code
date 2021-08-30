SET search_path TO mimic_ed;
---------------------------
---------------------------
-- Creating Primary Keys --
---------------------------
---------------------------

ALTER TABLE mimic_ed.edstays DROP CONSTRAINT IF EXISTS edstays_pk CASCADE;
ALTER TABLE mimic_ed.edstays
ADD CONSTRAINT edstays_pk
  PRIMARY KEY (stay_id);

ALTER TABLE mimic_ed.diagnosis DROP CONSTRAINT IF EXISTS diagnosis_pk CASCADE;
ALTER TABLE mimic_ed.diagnosis
ADD CONSTRAINT diagnosis_pk
  PRIMARY KEY (stay_id, seq_num);

--ALTER TABLE mimic_ed.medrecon DROP CONSTRAINT IF EXISTS medrecon_pk CASCADE;
--ALTER TABLE mimic_ed.medrecon
--ADD CONSTRAINT medrecon_pk
--  PRIMARY KEY (stay_id, charttime, name);

--ALTER TABLE mimic_ed.pyxis DROP CONSTRAINT IF EXISTS pyxis_pk CASCADE;
--ALTER TABLE mimic_ed.pyxis
--ADD CONSTRAINT pyxis_pk
--  PRIMARY KEY (stay_id, charttime, name);

ALTER TABLE mimic_ed.triage DROP CONSTRAINT IF EXISTS triage_pk CASCADE;
ALTER TABLE mimic_ed.triage
ADD CONSTRAINT triage_pk
  PRIMARY KEY (stay_id);

ALTER TABLE mimic_ed.vitalsign DROP CONSTRAINT IF EXISTS vitalsign_pk CASCADE;
ALTER TABLE mimic_ed.vitalsign
ADD CONSTRAINT vitalsign_pk
  PRIMARY KEY (stay_id, charttime);

---------------------------
---------------------------
-- Creating Foreign Keys --
---------------------------
---------------------------

ALTER TABLE mimic_ed.diagnosis DROP CONSTRAINT IF EXISTS diagnosis_edstays_fk CASCADE;
ALTER TABLE mimic_ed.diagnosis
ADD CONSTRAINT diagnosis_edstays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_ed.edstays (stay_id);

ALTER TABLE mimic_ed.medrecon DROP CONSTRAINT IF EXISTS medrecon_edstays_fk CASCADE;
ALTER TABLE mimic_ed.medrecon
ADD CONSTRAINT medrecon_edstays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_ed.edstays (stay_id);

ALTER TABLE mimic_ed.pyxis DROP CONSTRAINT IF EXISTS pyxis_edstays_fk CASCADE;
ALTER TABLE mimic_ed.pyxis
ADD CONSTRAINT pyxis_edstays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_ed.edstays (stay_id);

ALTER TABLE mimic_ed.triage DROP CONSTRAINT IF EXISTS triage_edstays_fk CASCADE;
ALTER TABLE mimic_ed.triage
ADD CONSTRAINT triage_edstays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_ed.edstays (stay_id);

ALTER TABLE mimic_ed.vitalsign DROP CONSTRAINT IF EXISTS vitalsign_edstays_fk CASCADE;
ALTER TABLE mimic_ed.vitalsign
ADD CONSTRAINT vitalsign_edstays_fk
  FOREIGN KEY (stay_id)
  REFERENCES mimic_ed.edstays (stay_id);
