-- ------------------------------------------------------------------
-- Title: Retrieves basic patient information from the patients table
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- ------------------------------------------------------------------


SELECT subject_id, gender, dob
FROM `physionet-data.mimiciii_clinical.patients`;
