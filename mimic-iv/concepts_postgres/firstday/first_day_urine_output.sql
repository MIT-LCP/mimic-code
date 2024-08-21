-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_urine_output; CREATE TABLE mimiciv_derived.first_day_urine_output AS
/* Total urine output over the first 24 hours in the ICU */
SELECT
  ie.subject_id,
  ie.stay_id,
  SUM(urineoutput) AS urineoutput
FROM mimiciv_icu.icustays AS ie
/* Join to the outputevents table to get urine output */
LEFT JOIN mimiciv_derived.urine_output AS uo
  ON ie.stay_id = uo.stay_id
  AND /* ensure the data occurs during the first day */ uo.charttime >= ie.intime
  AND uo.charttime <= ie.intime + INTERVAL '1 DAY'
GROUP BY
  ie.subject_id,
  ie.stay_id