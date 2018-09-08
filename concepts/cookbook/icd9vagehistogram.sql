-- ------------------------------------------------------------------
-- Title: Count the number of patients with a specific icd9 code and shows the output as a histogram with groups of age
-- MIMIC version: MIMIC-III v1.3
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
-- SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- Acknowledgements: Made with help from Kris Kindle
-- Reference: tompollard, alistairewj for code taken
-- from age_hist.sql on the MIMIC III github repository
-- ------------------------------------------------------------------

WITH diatbl AS
	(
	SELECT DISTINCT ON (dia.subject_id) dia.subject_id, ad.admittime
	from `physionet-data.mimiciii_clinical.diagnoses_icd` dia
	INNER JOIN admissions ad
	ON dia.subject_id = ad.subject_id
	WHERE dia.icd9_code
	-- 401% relates to hypertension
	LIKE '401%'
	),
agetbl AS
	(
	SELECT dt.subject_id, DATETIME_DIFF(dt.admittime, p.dob, YEAR) AS age
	FROM diatbl dt
	INNER JOIN patients p
	ON dt.subject_id = p.subject_id
	)
SELECT
        COUNT(*) AS TOTAL,
        COUNT(CASE WHEN age >= 0 AND age < 16 THEN  '0 - 15' END) AS "0-15",
        COUNT(CASE WHEN age >= 16 AND age < 21 THEN '16 - 20' END) AS "16-20",
        COUNT(CASE WHEN age >= 21 AND age < 26 THEN '21 - 25' END) AS "21-25",
        COUNT(CASE WHEN age >= 26 AND age < 31 THEN '26 - 30' END) AS "26-30",
        COUNT(CASE WHEN age >= 31 AND age < 36 THEN '31 - 35' END) AS "31-35",
        COUNT(CASE WHEN age >= 36 AND age < 41 THEN '36 - 40' END) AS "36-40",
        COUNT(CASE WHEN age >= 41 AND age < 46 THEN '41 - 45' END) AS "41-45",
        COUNT(CASE WHEN age >= 46 AND age < 51 THEN '46 - 50' END) AS "46-50",
        COUNT(CASE WHEN age >= 51 AND age < 56 THEN '51 - 55' END) AS "51-55",
        COUNT(CASE WHEN age >= 56 AND age < 61 THEN '56 - 60' END) AS "56-60",
        COUNT(CASE WHEN age >= 61 AND age < 66 THEN '61 - 65' END) AS "61-65",
        COUNT(CASE WHEN age >= 66 AND age < 71 THEN '66 - 70' END) AS "66-70",
        COUNT(CASE WHEN age >= 71 AND age < 76 THEN '71 - 75' END) AS "71-75",
        COUNT(CASE WHEN age >= 76 AND age < 81 THEN '76 - 80' END) AS "76-80",
        COUNT(CASE WHEN age >= 81 AND age < 86 THEN '81 - 85' END) AS "81-85",
        COUNT(CASE WHEN age >= 86 AND age < 91 THEN '86 - 90' END) AS "86-91",
        COUNT(CASE WHEN age >= 91 THEN 'Over 91' END) AS ">91"
FROM agetbl;
