-- This query extracts weights for adult ICU patients on their first ICU day.
-- It does *not* use any information after the first ICU day, as weight is
-- sometimes used to monitor fluid balance.
-- The MIMIC-III version used echodata but this isn't available in MIMIC-IV.
SELECT
  ie.stay_id
  , AVG(CASE WHEN weight_type = 'admit' THEN weight ELSE NULL END) AS weight_admit
  , AVG(weight) AS weight
  , MIN(weight) AS weight_min
  , MAX(weight) AS weight_max
FROM `physionet-data.mimic_icu.icustays` ie
  -- admission weight
LEFT JOIN `physionet-data.mimic_derived.weight_durations`
    ON ie.stay_id = ce.stay_id
    -- we filter to weights documented during or before the 1st day
    AND ce.starttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
;