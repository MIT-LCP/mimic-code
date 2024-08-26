-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_weight; CREATE TABLE mimiciv_derived.first_day_weight AS
SELECT
  ie.subject_id,
  ie.stay_id,
  AVG(CASE WHEN weight_type = 'admit' THEN ce.weight ELSE NULL END) AS weight_admit,
  AVG(ce.weight) AS weight,
  MIN(ce.weight) AS weight_min,
  MAX(ce.weight) AS weight_max
FROM mimiciv_icu.icustays AS ie
LEFT JOIN mimiciv_derived.weight_durations AS ce
  ON ie.stay_id = ce.stay_id AND ce.starttime <= ie.intime + INTERVAL '1' DAY
GROUP BY
  ie.subject_id,
  ie.stay_id