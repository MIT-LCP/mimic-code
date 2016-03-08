-- --------------------------------------------------------
-- Title: Retrieves the blood pressure of hospital survivors 
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

SELECT bucket, count(*) 
FROM (SELECT width_bucket(min_sbp, 0, 300, 300) AS bucket FROM (
      SELECT p.subject_id, ce.icustay_id, min(valuenum) AS min_sbp
      FROM mimiciii.chartevents ce
      INNER JOIN agetbl 
      ON ce.subject_id = agetbl.subject_id
      INNER JOIN mimiciii.patients p 
      ON p.expire_flag = 0
     WHERE itemid IN (6, 51, 455, 6701)
       GROUP BY p.subject_id, ce.icustay_id
    ) AS min_surviving_bp
  ) AS min_surviving_bp_counted
GROUP BY bucket 
ORDER BY bucket;

