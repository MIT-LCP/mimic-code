-- --------------------------------------------------------
-- Title: Retrieves the respiration rate of adult patients
--        only for patients recorded with carevue
-- MIMIC version: MIMIC-III v1.3
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
, rr as
(
  SELECT valuenum, width_bucket(valuenum, 0, 130, 1400) AS bucket
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  INNER JOIN agetbl
  ON ce.subject_id = agetbl.subject_id
  WHERE itemid in (219, 615, 618)
)
SELECT round(cast(bucket as numeric) / 10,2) as respiration_rate, count(*)
FROM rr
GROUP BY bucket
ORDER BY bucket;
