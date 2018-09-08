-- ------------------------------------------------------------------
-- Title: Count the number of patients with a specific icd9 code
-- MIMIC version: MIMIC-III v1.3
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
-- SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- Acknowledgement: Credit goes to Kris Kindle
-- ------------------------------------------------------------------

SELECT COUNT(DISTINCT subject_id) 
AS "Hypertension" 
from `physionet-data.mimiciii_clinical.diagnoses_icd` 
WHERE icd9_code 
-- 401% will search for all icd9 codes relating to hypertension
LIKE '401%';