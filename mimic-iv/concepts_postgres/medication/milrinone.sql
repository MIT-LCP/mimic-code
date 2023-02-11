-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS milrinone; CREATE TABLE milrinone AS 
-- This query extracts dose+durations of milrinone administration
SELECT
    stay_id, linkorderid
    -- all rows in mcg/kg/min
    , rate AS vaso_rate
    , amount AS vaso_amount
    , starttime
    , endtime
FROM mimiciv_icu.inputevents
WHERE itemid = 221986 -- milrinone
