-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS dopamine; CREATE TABLE dopamine AS 
-- This query extracts dose+durations of dopamine administration
select
stay_id, linkorderid
-- all rows in mcg/kg/min
, rate as vaso_rate
, amount as vaso_amount
, starttime
, endtime
from mimiciv_icu.inputevents
where itemid = 221662 -- dopamine