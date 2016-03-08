-- ------------------------------------------------------------------
-- Title: Count the number of ages in equally sized bins of 1 year
-- MIMIC version: ?
-- ------------------------------------------------------------------

WITH agetbl AS
(
    SELECT (extract(DAY FROM ad.admittime - p.dob) 
            + extract(HOUR FROM ad.admittime - p.dob) / 24
            + extract(MINUTE FROM ad.admittime - p.dob) / 24 / 60
            ) / 365.25
            AS age
      FROM MIMICIII.admissions ad
      INNER JOIN MIMICIII.patients p
      ON ad.subject_id = p.subject_id 
)
, agebin AS
(
      SELECT age, width_bucket(age, 15, 100, 85) AS bucket 
      FROM agetbl
)
SELECT bucket+15, count(*) 
FROM agebin
GROUP BY bucket 
ORDER BY bucket;