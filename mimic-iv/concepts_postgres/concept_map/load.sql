-----------------------------------------------
-- Load data into the concept_map schema --
-----------------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -f load.sql
-- The script assumes the CSV files are in the hosp and icu subfolders
-- of ../../concepts/concept_map/ relative to this script's location

SET CLIENT_ENCODING TO 'utf8';

-- hosp concept maps
\COPY mimiciv_concept_map.labevents_to_loinc FROM '../../concepts/concept_map/hosp/labevents_to_loinc.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_concept_map.labevents_to_omop FROM '../../concepts/concept_map/hosp/labevents_to_omop.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_concept_map.prescriptions_to_rxnorm FROM '../../concepts/concept_map/hosp/prescriptions_to_rxnorm.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_concept_map.prescriptions_to_omop FROM '../../concepts/concept_map/hosp/prescriptions_to_omop.csv' DELIMITER ',' CSV HEADER NULL '';

-- icu concept maps
\COPY mimiciv_concept_map.chartevents_to_loinc FROM '../../concepts/concept_map/icu/chartevents_to_loinc.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_concept_map.chartevents_to_omop FROM '../../concepts/concept_map/icu/chartevents_to_omop.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_concept_map.procedureevents_to_snomed FROM '../../concepts/concept_map/icu/procedureevents_to_snomed.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_concept_map.procedureevents_to_omop FROM '../../concepts/concept_map/icu/procedureevents_to_omop.csv' DELIMITER ',' CSV HEADER NULL '';
