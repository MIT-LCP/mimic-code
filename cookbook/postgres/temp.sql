-- --------------------------------------------------------
-- Title: Retrieves the temperature of adult patients
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
		(extract(DAY FROM ad.admittime - p.dob) 
			+ extract(HOUR FROM ad.admittime - p.dob) /24
			+ extract(MINUTE FROM ad.admittime - p.dob) / 24 / 60
			) / 365.25 
	) > 15
)

SELECT (bucket/10) + 30, count(*) FROM (
  SELECT width_bucket(
      CASE WHEN itemid IN (223762, 676) THEN valuenum -- celsius
           WHEN itemid IN (223761, 678) THEN (valuenum - 32) * 5 / 9 --fahrenheit 
           END, 30, 45, 160) AS bucket
    FROM mimiciii.chartevents ce
    INNER JOIN agetbl 
    ON ce.subject_id = agetbl.subject_id
    WHERE itemid IN (676, 677, 678, 679)
    ) AS temperature 
    GROUP BY bucket 
    ORDER BY bucket;
