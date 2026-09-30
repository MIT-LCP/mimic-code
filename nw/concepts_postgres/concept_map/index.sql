-------------------------------------------------
-- Indexes for NW concept_map tables --
-------------------------------------------------

SET search_path TO nw_concept_map;

-- labevents_to_loinc

DROP INDEX IF EXISTS labevents_to_loinc_idx01;
CREATE INDEX labevents_to_loinc_idx01
  ON labevents_to_loinc (subject_id);

DROP INDEX IF EXISTS labevents_to_loinc_idx02;
CREATE INDEX labevents_to_loinc_idx02
  ON labevents_to_loinc (object_id);

-- labevents_to_omop

DROP INDEX IF EXISTS labevents_to_omop_idx01;
CREATE INDEX labevents_to_omop_idx01
  ON labevents_to_omop (subject_id);

DROP INDEX IF EXISTS labevents_to_omop_idx02;
CREATE INDEX labevents_to_omop_idx02
  ON labevents_to_omop (object_id);

-- prescriptions_to_rxnorm

DROP INDEX IF EXISTS prescriptions_to_rxnorm_idx01;
CREATE INDEX prescriptions_to_rxnorm_idx01
  ON prescriptions_to_rxnorm (subject_id);

DROP INDEX IF EXISTS prescriptions_to_rxnorm_idx02;
CREATE INDEX prescriptions_to_rxnorm_idx02
  ON prescriptions_to_rxnorm (object_id);

-- prescriptions_to_omop

DROP INDEX IF EXISTS prescriptions_to_omop_idx01;
CREATE INDEX prescriptions_to_omop_idx01
  ON prescriptions_to_omop (subject_id);

DROP INDEX IF EXISTS prescriptions_to_omop_idx02;
CREATE INDEX prescriptions_to_omop_idx02
  ON prescriptions_to_omop (object_id);

-- chartevents_to_loinc

DROP INDEX IF EXISTS chartevents_to_loinc_idx01;
CREATE INDEX chartevents_to_loinc_idx01
  ON chartevents_to_loinc (subject_id);

DROP INDEX IF EXISTS chartevents_to_loinc_idx02;
CREATE INDEX chartevents_to_loinc_idx02
  ON chartevents_to_loinc (object_id);

-- chartevents_to_omop

DROP INDEX IF EXISTS chartevents_to_omop_idx01;
CREATE INDEX chartevents_to_omop_idx01
  ON chartevents_to_omop (subject_id);

DROP INDEX IF EXISTS chartevents_to_omop_idx02;
CREATE INDEX chartevents_to_omop_idx02
  ON chartevents_to_omop (object_id);

-- procedureevents_to_snomed

DROP INDEX IF EXISTS procedureevents_to_snomed_idx01;
CREATE INDEX procedureevents_to_snomed_idx01
  ON procedureevents_to_snomed (subject_id);

DROP INDEX IF EXISTS procedureevents_to_snomed_idx02;
CREATE INDEX procedureevents_to_snomed_idx02
  ON procedureevents_to_snomed (object_id);

-- procedureevents_to_omop

DROP INDEX IF EXISTS procedureevents_to_omop_idx01;
CREATE INDEX procedureevents_to_omop_idx01
  ON procedureevents_to_omop (subject_id);

DROP INDEX IF EXISTS procedureevents_to_omop_idx02;
CREATE INDEX procedureevents_to_omop_idx02
  ON procedureevents_to_omop (object_id);
