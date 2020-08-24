-- ------------------------------------------------------------------
-- Purpose: Create a view of the urine output for each ICUSTAY_ID over the first 24 hours.
-- ------------------------------------------------------------------

SELECT
  -- patient identifiers
  ie.subject_id
  , ie.hadm_id
  , ie.stay_id
  -- volumes associated with urine output ITEMIDs
  -- we consider input of GU irrigant as a negative volume
  , SUM(CASE WHEN oe.itemid = 227488 AND oe.value > 0 THEN -1*oe.value ELSE oe.value END) AS urineoutput
FROM `physionet-data.mimic_icu.icustays` ie
-- Join to the outputevents table to get urine output
LEFT JOIN `physionet-data.mimic_icu.outputevents` oe ON
-- join on all patient identifiers
    ie.subject_id = oe.subject_id
    AND ie.hadm_id = oe.hadm_id
    AND ie.stay_id = oe.stay_id
    -- and ensure the data occurs during the first day
    AND oe.charttime between ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY) -- first ICU day
WHERE
    itemid IN (
    -- these are the most frequently occurring urine output observations in MetaVision
    226559, -- "Foley"
    226560, -- "Void"
    226561, -- "Condom Cath"
    226584, -- "Ileoconduit"
    226563, -- "Suprapubic"
    226564, -- "R Nephrostomy"
    226565, -- "L Nephrostomy"
    226567, --	Straight Cath
    226557, -- R Ureteral Stent
    226558, -- L Ureteral Stent
    227488, -- GU Irrigant Volume In
    227489  -- GU Irrigant/Urine Volume Out
    )
GROUP BY ie.subject_id, ie.hadm_id, ie.stay_id
ORDER BY ie.subject_id, ie.hadm_id, ie.stay_id;