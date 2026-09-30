---------------------------
---------------------------
-- Creating Primary Keys --
---------------------------
---------------------------

-- hosp concept maps

-- labevents_to_loinc

ALTER TABLE mimiciv_concept_map.labevents_to_loinc DROP CONSTRAINT IF EXISTS labevents_to_loinc_pk CASCADE;
ALTER TABLE mimiciv_concept_map.labevents_to_loinc
ADD CONSTRAINT labevents_to_loinc_pk
  PRIMARY KEY (subject_id);

-- labevents_to_omop

ALTER TABLE mimiciv_concept_map.labevents_to_omop DROP CONSTRAINT IF EXISTS labevents_to_omop_pk CASCADE;
ALTER TABLE mimiciv_concept_map.labevents_to_omop
ADD CONSTRAINT labevents_to_omop_pk
  PRIMARY KEY (subject_id);

-- prescriptions_to_rxnorm
-- NOTE: PK on subject_id is not possible. The same NDC code (subject_id)
-- can appear with multiple subject_labels because different drug names
-- in the prescriptions table share the same NDC. For example,
-- mimic-ndc:002641101 maps to rxnorm:309778 (glucose 50 MG/ML) but
-- appears 5 times with labels: D5W, 5% Dextrose, Dextrose 5%, etc.
-- Per SSSOM, subject_label is metadata — the mapping is subject_id -> object_id.
-- This means joins on subject_id will produce duplicate rows (one per label).

-- prescriptions_to_omop
-- same note as prescriptions_to_rxnorm

-- icu concept maps

-- chartevents_to_loinc

ALTER TABLE mimiciv_concept_map.chartevents_to_loinc DROP CONSTRAINT IF EXISTS chartevents_to_loinc_pk CASCADE;
ALTER TABLE mimiciv_concept_map.chartevents_to_loinc
ADD CONSTRAINT chartevents_to_loinc_pk
  PRIMARY KEY (subject_id);

-- chartevents_to_omop

ALTER TABLE mimiciv_concept_map.chartevents_to_omop DROP CONSTRAINT IF EXISTS chartevents_to_omop_pk CASCADE;
ALTER TABLE mimiciv_concept_map.chartevents_to_omop
ADD CONSTRAINT chartevents_to_omop_pk
  PRIMARY KEY (subject_id);

-- procedureevents_to_snomed

ALTER TABLE mimiciv_concept_map.procedureevents_to_snomed DROP CONSTRAINT IF EXISTS procedureevents_to_snomed_pk CASCADE;
ALTER TABLE mimiciv_concept_map.procedureevents_to_snomed
ADD CONSTRAINT procedureevents_to_snomed_pk
  PRIMARY KEY (subject_id);

-- procedureevents_to_omop

ALTER TABLE mimiciv_concept_map.procedureevents_to_omop DROP CONSTRAINT IF EXISTS procedureevents_to_omop_pk CASCADE;
ALTER TABLE mimiciv_concept_map.procedureevents_to_omop
ADD CONSTRAINT procedureevents_to_omop_pk
  PRIMARY KEY (subject_id);
