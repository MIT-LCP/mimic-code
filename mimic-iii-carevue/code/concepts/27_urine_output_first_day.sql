drop table if exists urine_output_first_day; create table urine_output_first_day as 
-- ------------------------------------------------------------------
-- Purpose: Create a view of the urine output for each icustay_id over the first 24 hours.
-- ------------------------------------------------------------------

select
  -- patient identifiers
  ie.subject_id, ie.hadm_id, ie.icustay_id

  -- volumes associated with urine output ITEMIDs
  , sum(oe.value) as urineoutput
from icustays ie
-- join to the outputevents table to get urine output
left join outputevents oe
-- join on all patient identifiers
on ie.subject_id = oe.subject_id and ie.hadm_id = oe.hadm_id and ie.icustay_id = oe.icustay_id
-- and ensure the data occurs during the first day
and oe.charttime between ie.intime and (ie.intime + interval '1 day') -- first icu day
where itemid in
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
40086, -- "Urine Out Incontinent"
40096, -- "Urine Out Ureteral Stent #1"
40651  -- "Urine Out Ureteral Stent #2"
)
group by ie.subject_id, ie.hadm_id, ie.icustay_id
order by ie.subject_id, ie.hadm_id, ie.icustay_id;