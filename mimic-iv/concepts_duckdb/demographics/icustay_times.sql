-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.icustay_times; CREATE TABLE mimiciv_derived.icustay_times AS
WITH t1 AS (
  SELECT
    ce.stay_id,
    MIN(charttime) AS intime_hr,
    MAX(charttime) AS outtime_hr
  FROM mimiciv_icu.chartevents AS ce
  WHERE
    ce.itemid = 220045
  GROUP BY
    ce.stay_id
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.stay_id,
  t1.intime_hr,
  t1.outtime_hr
FROM mimiciv_icu.icustays AS ie
LEFT JOIN t1
  ON ie.stay_id = t1.stay_id