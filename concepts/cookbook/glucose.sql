-- --------------------------------------------------------
-- Title: Retrieves a glucose histogram of adult patients
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------

WITH agetbl AS
(
  SELECT ad.subject_id
  FROM `physionet-data.mimiciii_clinical.admissions` ad
  INNER JOIN patients p
  ON ad.subject_id = p.subject_id
  WHERE
  -- filter to only adults
  DATETIME_DIFF(ad.admittime, p.dob, YEAR) > 15
  -- group by subject_id to ensure there is only 1 subject_id per row
  group by ad.subject_id
)
, glc as
(
  SELECT width_bucket(valuenum, 0.5, 1000, 1000) AS bucket
  FROM `physionet-data.mimiciii_clinical.labevents` le
  INNER JOIN agetbl
  ON le.subject_id = agetbl.subject_id
  WHERE itemid IN (50809,50931)
  AND valuenum IS NOT NULL
)
SELECT bucket as glucose, count(*)
FROM glc
GROUP BY bucket
ORDER BY bucket;
