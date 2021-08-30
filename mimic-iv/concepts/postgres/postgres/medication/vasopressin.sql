-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS vasopressin; CREATE TABLE vasopressin AS 
-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS vasopressin; CREATE TABLE vasopressin AS 
-- This query extracts dose+durations of vasopressin administration
select
  stay_id, linkorderid
  , rate as vaso_rate
  , amount as vaso_amount
  , starttime
  , endtime
from mimic_icu.inputevents
where itemid = 222315 -- vasopressin