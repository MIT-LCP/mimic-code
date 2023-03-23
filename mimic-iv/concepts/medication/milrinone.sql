-- This query extracts dose+durations of milrinone administration
-- Local hospital dosage guidance: 0.5 mcg/kg/min (usual)
SELECT
    stay_id, linkorderid
    -- all rows in mcg/kg/min
    , rate AS vaso_rate
    , amount AS vaso_amount
    , starttime
    , endtime
FROM `physionet-data.mimiciv_icu.inputevents`
WHERE itemid = 221986 -- milrinone
