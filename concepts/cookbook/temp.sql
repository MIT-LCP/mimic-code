-- --------------------------------------------------------
-- Title: Retrieves the temperature of adult patients
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
, temp as
(
  SELECT width_bucket(
      CASE
        WHEN itemid IN (223762, 676, 677) THEN valuenum -- celsius
        WHEN itemid IN (223761, 678, 679) THEN (valuenum - 32) * 5 / 9 --fahrenheit
      END
    , 30, 45, 160) AS bucket
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  INNER JOIN agetbl
  ON ce.subject_id = agetbl.subject_id
  WHERE itemid IN
  (
      676 -- Temperature C
    , 677 -- Temperature C (calc)
    , 678 -- Temperature F
    , 679 -- Temperature F (calc)
    , 223761 -- Temperature Fahrenheit
    , 223762 -- Temperature Celsius
  )
)
SELECT round((cast(bucket as numeric)/10) + 30,2) as temperature, count(*)
FROM temp
GROUP BY bucket
ORDER BY bucket;
