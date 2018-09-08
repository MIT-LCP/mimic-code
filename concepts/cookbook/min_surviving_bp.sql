-- --------------------------------------------------------
-- Title: Retrieves the systolic blood pressure of hospital survivors
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
, min_surviving_bp as
(
  SELECT p.subject_id, ce.icustay_id, min(valuenum) AS min_sbp
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  INNER JOIN agetbl
  ON ce.subject_id = agetbl.subject_id
  -- here we filter down to only survivors
  INNER JOIN patients p
  ON ce.subject_id = p.subject_id and p.expire_flag = 0
  WHERE itemid IN (6, 51, 455, 6701, 220179, 220050)
  GROUP BY p.subject_id, ce.icustay_id
)
, min_surviving_bp_counted as
(
  SELECT width_bucket(min_sbp, 0, 300, 300) AS bucket
  FROM min_surviving_bp
)
SELECT bucket as systolic_blood_pressure, count(*)
FROM min_surviving_bp_counted
GROUP BY bucket
ORDER BY bucket;
