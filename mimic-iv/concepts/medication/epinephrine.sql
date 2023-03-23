-- This query extracts dose+durations of epinephrine administration
-- Local hospital dosage guidance: 0.2 mcg/kg/min (low) - 2 mcg/kg/min (high)
SELECT
    stay_id, linkorderid
    -- all rows in mcg/kg/min
    , rate AS vaso_rate
    , amount AS vaso_amount
    , starttime
    , endtime
FROM `physionet-data.mimiciv_icu.inputevents`
WHERE itemid = 221289 -- epinephrine
