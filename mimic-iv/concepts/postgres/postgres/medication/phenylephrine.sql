-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS phenylephrine; CREATE TABLE phenylephrine AS 
-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS phenylephrine; CREATE TABLE phenylephrine AS 
-- This query extracts dose+durations of phenylephrine administration
select
  stay_id, linkorderid
  , rate as vaso_rate
  , amount as vaso_amount
  , starttime
  , endtime
from mimic_icu.inputevents
where itemid = 221749 -- phenylephrine
