-- This query extracts dose+durations of norepinephrine administration
-- Local hospital dosage guidance: 0.03 mcg/kg/min (low), 0.5 mcg/kg/min (high)
SELECT
    stay_id, linkorderid
    -- two rows in mg/kg/min... rest in mcg/kg/min
    -- the rows in mg/kg/min are documented incorrectly
    -- all rows converted into mcg/kg/min (equiv to ug/kg/min)
    , CASE WHEN rateuom = 'mg/kg/min' AND patientweight = 1 THEN rate
        -- below row is written for completion, but doesn't impact rows
        WHEN rateuom = 'mg/kg/min' THEN rate * 1000.0
        ELSE rate END AS vaso_rate
    , amount AS vaso_amount
    , starttime
    , endtime
FROM `physionet-data.mimiciv_icu.inputevents`
WHERE itemid = 221906 -- norepinephrine
