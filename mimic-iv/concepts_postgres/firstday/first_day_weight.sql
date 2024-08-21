-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_weight; CREATE TABLE mimiciv_derived.first_day_weight AS
/* This query extracts weights for adult ICU patients on their first ICU day. */ /* It does *not* use any information after the first ICU day, as weight is */ /* sometimes used to monitor fluid balance. */ /* The MIMIC-III version used echodata but this isn't available in MIMIC-IV. */
SELECT
  ie.subject_id,
  ie.stay_id,
  AVG(CASE WHEN weight_type = 'admit' THEN ce.weight ELSE NULL END) AS weight_admit,
  AVG(ce.weight) AS weight,
  MIN(ce.weight) AS weight_min,
  MAX(ce.weight) AS weight_max
FROM mimiciv_icu.icustays AS ie
/* admission weight */
LEFT JOIN mimiciv_derived.weight_durations AS ce
  ON ie.stay_id = ce.stay_id
  AND /* we filter to weights documented during or before the 1st day */ ce.starttime <= ie.intime + INTERVAL '1 DAY'
GROUP BY
  ie.subject_id,
  ie.stay_id