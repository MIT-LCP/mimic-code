-- --------------------------------------------------------
-- Title: Find the glasgow coma score for each adult patient 
--        only works for patients recorded with carevue 
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
		+ extract(HOUR FROM ad.admittime - p.dob) / 24
    + extract(MINUTE FROM ad.admittime - p.dob) / 24 / 60) / 365.25 
    ) > 15
)
SELECT bucket, count(*) FROM (
    SELECT width_bucket(valuenum, 1, 30, 30) AS bucket
    FROM mimiciii.chartevents ce
    INNER JOIN agetbl    
    ON ce.subject_id = agetbl.subject_id
    WHERE itemid IN (198)) AS gcs
GROUP BY bucket 
ORDER BY bucket;
