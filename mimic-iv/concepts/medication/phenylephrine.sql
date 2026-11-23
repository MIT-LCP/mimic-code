-- This query extracts dose+durations of phenylephrine administration
-- Local hospital dosage guidance: 0.5 mcg/kg/min (low) - 5 mcg/kg/min (high)
SELECT
    stay_id, linkorderid
    -- one row in mcg/min, the rest in mcg/kg/min
    , CASE WHEN rateuom = 'mcg/min' THEN rate / patientweight
        ELSE rate END AS vaso_rate
    , amount AS vaso_amount
    , starttime
    , endtime
FROM `physionet-data.mimiciv_icu.inputevents`
WHERE itemid IN (
    221749 -- Phenylephrine
    , 229630 -- Phenylephrine (50/250)
    , 229631 -- Phenylephrine (200/250)_OLD_1
    , 229632 -- Phenylephrine (200/250)
)
-- Exclude 229789 (Phenylephrine (Intubation)), which is bolus dosing.
