drop table if exists urine_output; create table urine_output as 
-- First we drop the table if it exists
select 
  oe.icustay_id
  , oe.charttime
  , sum(oe.value) as value
from outputevents oe
where oe.itemid in
(
  -- these are the most frequently occurring urine output observations in CareVue
  40055, -- "Urine Out Foley"
  43175, -- "Urine"
  40069, -- "Urine Out Void"
  40094, -- "Urine Out Condom Cath"
  40715, -- "Urine Out Suprapubic"
  40473, -- "Urine Out IleoConduit"
  40085, -- "Urine Out Incontinent"
  40057, -- "Urine Out Rt Nephrostomy"
  40056, -- "Urine Out Lt Nephrostomy"
  40405, -- "Urine Out Other"
  40428, -- "Urine Out Straight Cath"
  40086, -- Urine Out Incontinent
  40096, -- "Urine Out Ureteral Stent #1"
  40651  -- "Urine Out Ureteral Stent #2"
)
and oe.value < 5000 -- sanity check on urine value
and oe.icustay_id is not null
group by icustay_id, charttime;