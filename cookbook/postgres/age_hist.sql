-- ------------------------------------------------------------------
-- Title: Count the number of hospital admissions in equally sized bins of age
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- ------------------------------------------------------------------

WITH agetbl AS
(
    SELECT (extract(DAY FROM ad.admittime - p.dob)
            + extract(HOUR FROM ad.admittime - p.dob) / 24
            + extract(MINUTE FROM ad.admittime - p.dob) / 24 / 60
            ) / 365.25
            AS age
      FROM admissions ad
      INNER JOIN patients p
      ON ad.subject_id = p.subject_id
)
, agebin AS
(
      SELECT age, width_bucket(age, 15, 100, 85) AS bucket
      FROM agetbl
)
SELECT bucket+15 as age, count(*)
FROM agebin
GROUP BY bucket
ORDER BY bucket;
