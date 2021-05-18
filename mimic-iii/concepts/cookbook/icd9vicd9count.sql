-- ------------------------------------------------------------------
-- Title: Count the number of patients with two specific icd9 codes
-- MIMIC version: MIMIC-III v1.3
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
-- SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- Acknowledgement: Credit goes to Kris Kindle
-- ------------------------------------------------------------------

SELECT COUNT(DISTINCT a.subject_id) 
AS "Obesity and Dyslipidemia" 
from `physionet-data.mimiciii_clinical.diagnoses_icd` a 
INNER JOIN diagnoses_icd b 
ON a.subject_id = b.subject_id 
WHERE a.icd9_code
-- 278% relates to obesity 
LIKE '278%' 
AND b.icd9_code 
-- 272 relates to Dyslipidemia
LIKE '272%';