-- --------------------------------------------------------
-- Title: Retrieves the urine output of adult patients
--        only for patients recorded on carevue
-- MIMIC version: MIMIC-III v1.3
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------

WITH agetbl AS
(
  SELECT ad.subject_id
  FROM admissions ad
  INNER JOIN patients p
  ON ad.subject_id = p.subject_id
  WHERE
  -- filter to only adults
  EXTRACT(EPOCH FROM (ad.admittime - p.dob))/60.0/60.0/24.0/365.242 > 15
  -- group by subject_id to ensure there is only 1 subject_id per row
  group by ad.subject_id
)

SELECT bucket*5, COUNT(*) FROM (
  SELECT width_bucket(volume, 0, 1000, 200) AS bucket
    FROM ioevents ie
     INNER JOIN agetbl
     ON ie.subject_id = agetbl.subject_id
   WHERE itemid IN (55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428,
   473, 651, 715, 1922, 2042, 2068, 2111, 2119, 2130, 2366, 2463, 2507,
   2510, 2592, 2676, 2810, 2859, 3053, 3175, 3462, 3519, 3966, 3987,
   4132, 4253, 5927)
  ) AS urine_output
  GROUP BY bucket
  ORDER BY bucket;
