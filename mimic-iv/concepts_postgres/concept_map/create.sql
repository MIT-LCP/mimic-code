-----------------------------------------------
-- Create the tables and concept_map schema --
-----------------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -f create.sql

----------------------
-- Creating schema --
----------------------

DROP SCHEMA IF EXISTS mimiciv_concept_map CASCADE;
CREATE SCHEMA mimiciv_concept_map;

---------------------
-- Creating tables --
---------------------

-- hosp concept maps

DROP TABLE IF EXISTS mimiciv_concept_map.labevents_to_loinc;
CREATE TABLE mimiciv_concept_map.labevents_to_loinc
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);

DROP TABLE IF EXISTS mimiciv_concept_map.labevents_to_omop;
CREATE TABLE mimiciv_concept_map.labevents_to_omop
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);

DROP TABLE IF EXISTS mimiciv_concept_map.prescriptions_to_rxnorm;
CREATE TABLE mimiciv_concept_map.prescriptions_to_rxnorm
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);

DROP TABLE IF EXISTS mimiciv_concept_map.prescriptions_to_omop;
CREATE TABLE mimiciv_concept_map.prescriptions_to_omop
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);

-- icu concept maps

DROP TABLE IF EXISTS mimiciv_concept_map.chartevents_to_loinc;
CREATE TABLE mimiciv_concept_map.chartevents_to_loinc
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);

DROP TABLE IF EXISTS mimiciv_concept_map.chartevents_to_omop;
CREATE TABLE mimiciv_concept_map.chartevents_to_omop
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);

DROP TABLE IF EXISTS mimiciv_concept_map.procedureevents_to_snomed;
CREATE TABLE mimiciv_concept_map.procedureevents_to_snomed
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);

DROP TABLE IF EXISTS mimiciv_concept_map.procedureevents_to_omop;
CREATE TABLE mimiciv_concept_map.procedureevents_to_omop
(
    subject_id TEXT,
    subject_label TEXT,
    predicate_id TEXT,
    object_id TEXT,
    object_label TEXT,
    mapping_justification TEXT,
    author_id TEXT,
    confidence NUMERIC,
    comment TEXT,
    reviewer_id TEXT
);
