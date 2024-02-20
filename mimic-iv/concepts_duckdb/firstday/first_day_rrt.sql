-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_rrt; CREATE TABLE mimiciv_derived.first_day_rrt AS
SELECT
  ie.subject_id,
  ie.stay_id,
  MAX(dialysis_present) AS dialysis_present,
  MAX(dialysis_active) AS dialysis_active,
  GROUP_CONCAT(DISTINCT dialysis_type, ', ') AS dialysis_type
FROM mimiciv_icu.icustays AS ie
LEFT JOIN mimiciv_derived.rrt AS rrt
  ON ie.stay_id = rrt.stay_id
  AND rrt.charttime >= ie.intime - INTERVAL '6' HOUR
  AND rrt.charttime <= ie.intime + INTERVAL '1' DAY
GROUP BY
  ie.subject_id,
  ie.stay_id