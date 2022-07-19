-- Total urine output over the first 24 hours in the ICU
SELECT
  -- patient identifiers
  ie.subject_id
  , ie.stay_id
  , SUM(urineoutput) AS urineoutput
FROM `physionet-data.mimiciv_icu.icustays` ie
-- Join to the outputevents table to get urine output
LEFT JOIN `physionet-data.mimiciv_derived.urine_output` uo
    ON ie.stay_id = uo.stay_id
    -- ensure the data occurs during the first day
    AND uo.charttime >= ie.intime
    AND uo.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
GROUP BY ie.subject_id, ie.stay_id