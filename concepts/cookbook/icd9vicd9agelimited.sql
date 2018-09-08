-- ------------------------------------------------------------------
-- Title: Count the number of patients with two specific icd9 codes above a certain age
-- MIMIC version: MIMIC-III v1.3
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
-- SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- Reference: tompollard, alistairewj, erinhong for code taken
-- from sodium.sql on the MIMIC III github repository
-- ------------------------------------------------------------------

WITH agetbl AS 
	(
	SELECT ad.subject_id 
	FROM `physionet-data.mimiciii_clinical.admissions` ad 
	INNER JOIN patients p 
	ON ad.subject_id = p.subject_id 
	WHERE 
	DATETIME_DIFF(ad.admittime, p.dob, YEAR) > 40 
	GROUP BY ad.subject_id
	) 
SELECT COUNT(DISTINCT dia.subject_id) 
AS "Obesity vs Hypertension Age 40+" 
from `physionet-data.mimiciii_clinical.diagnoses_icd` dia 
INNER JOIN agetbl 
ON dia.subject_id = agetbl.subject_id 
INNER JOIN diagnoses_icd dib 
ON dia.subject_id = dib.subject_id 
WHERE dia.icd9_code 
-- 278% relates to obesity
LIKE '278%' 
AND dib.icd9_code 
-- 401% relates to hypertension
LIKE '401%';