DROP TABLE IF EXISTS dopamine; CREATE TABLE dopamine AS 
-- This query extracts dose+durations of dopamine administration
select
stay_id, linkorderid
, rate as vaso_rate
, amount as vaso_amount
, starttime
, endtime
from mimic_icu.inputevents
where itemid = 221662 -- dopamine