-- --------------------------------------------------------
-- Title: Retrieves the blood serum sodium levels for adult patients
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
, sodium as
(
  SELECT width_bucket(valuenum, 0, 180, 180) AS bucket
  FROM `physionet-data.mimiciii_clinical.labevents` le
  INNER JOIN agetbl
  ON le.subject_id = agetbl.subject_id
  WHERE itemid IN (50824, 50983)
)
SELECT bucket as sodium, count(*)
FROM sodium
GROUP BY bucket
ORDER BY bucket;
