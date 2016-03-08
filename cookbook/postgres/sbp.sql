-- --------------------------------------------------------
-- Title: Retrieves the systolic blood pressure for adult patients 
--        only for patients recorded with carevue 
-- MIMIC version: ?
-- --------------------------------------------------------

WITH agetbl AS
(
    SELECT ad.subject_id, ad.hadm_id
    FROM mimiciii.admissions ad
    INNER JOIN mimiciii.patients p
    ON ad.subject_id = p.subject_id 
    WHERE
       -- filter to only adults
        ( 
		(EXTRACT(DAY FROM ad.admittime - p.dob) 
			+ EXTRACT(HOUR FROM ad.admittime - p.dob) /24
			+ EXTRACT(MINUTE FROM ad.admittime - p.dob) / 24 / 60
			) / 365.25 
	) > 15
)

SELECT bucket, count(*) 
FROM (
    SELECT width_bucket(valuenum, 0, 300, 300) AS bucket
    FROM mimiciii.chartevents ce
    INNER JOIN agetbl
    ON ce.subject_id = agetbl.subject_id
   WHERE itemid IN (6, 51, 455, 6701)
   ) AS systolic_blood_pressure 
GROUP BY bucket 
ORDER BY bucket;
