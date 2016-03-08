-- --------------------------------------------------------
-- Title: Retrieves the respiration rate of adult patients 
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
			) / 365.25 ) > 15
        )
SELECT bucket/10, count(*) 
  FROM (
  SELECT valuenum, width_bucket(valuenum, 0, 130, 1400) AS bucket
    FROM mimiciii.chartevents ce
    INNER JOIN agetbl
    ON ce.subject_id = agetbl.subject_id
    WHERE itemid in (219, 615, 618)
       ) AS respiration_rate
GROUP BY bucket 
ORDER BY bucket;
