-- This query extracts dose+durations of phenylephrine administration
SELECT
    stay_id, linkorderid
    -- one row in mcg/min, the rest in mcg/kg/min
    , CASE WHEN rateuom = 'mcg/min' THEN rate / patientweight
        ELSE rate END AS vaso_rate
    , amount AS vaso_amount
    , starttime
    , endtime
FROM `physionet-data.mimiciv_icu.inputevents`
WHERE itemid = 221749 -- phenylephrine
