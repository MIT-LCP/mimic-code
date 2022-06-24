-- This query extracts dose+durations of phenylephrine administration
select
  stay_id, linkorderid
  -- one row in mcg/min, the rest in mcg/kg/min
  , CASE WHEN rateuom = 'mcg/min' THEN rate / patientweight
  ELSE rate END as vaso_rate
  , amount as vaso_amount
  , starttime
  , endtime
from `physionet-data.mimiciv_icu.inputevents`
where itemid = 221749 -- phenylephrine
