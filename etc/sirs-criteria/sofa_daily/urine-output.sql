-- ------------------------------------------------------------------
-- Source: mentioned at the end
-- modified to calculate some data without the limitation of the first day 
-- and to get the data of each calendar day
-- ------------------------------------------------------------------

create table a_uo as
select subject_id, hadm_id, icustay_id
,sum(VALUE) as UrineOutput
,dailyInterval
from 
(
select
  -- patient identifiers
  ie.subject_id, ie.hadm_id, ie.icustay_id

  -- volumes associated with urine output ITEMIDs
  , VALUE 
  , datediff('day', ie.intime::date, charttime::date) AS dailyInterval

from icustays ie
-- Join to the outputevents table to get urine output
left join outputevents oe
-- join on all patient identifiers
on ie.subject_id = oe.subject_id and ie.hadm_id = oe.hadm_id and ie.icustay_id = oe.icustay_id
where itemid in
(
-- these are the most frequently occurring urine output observations in CareVue
40055, -- "Urine Out Foley"
43175, -- "Urine ."
40069, -- "Urine Out Void"
40094, -- "Urine Out Condom Cath"
40715, -- "Urine Out Suprapubic"
40473, -- "Urine Out IleoConduit"
40085, -- "Urine Out Incontinent"
40057, -- "Urine Out Rt Nephrostomy"
40056, -- "Urine Out Lt Nephrostomy"
40405, -- "Urine Out Other"
40428, -- "Urine Out Straight Cath"
40086,--	Urine Out Incontinent
40096, -- "Urine Out Ureteral Stent #1"
40651, -- "Urine Out Ureteral Stent #2"

-- these are the most frequently occurring urine output observations in CareVue
226559, -- "Foley"
226560, -- "Void"
227510, -- "TF Residual"
226561, -- "Condom Cath"
226584, -- "Ileoconduit"
226563, -- "Suprapubic"
226564, -- "R Nephrostomy"
226565, -- "L Nephrostomy"
226567, --	Straight Cath
226557, -- "R Ureteral Stent"
226558  -- "L Ureteral Stent"
) 
) AS foo
where dailyInterval < 10
group by subject_id, hadm_id, icustay_id, dailyInterval
order by subject_id, hadm_id, icustay_id, dailyInterval
;


--source: https://github.com/MIT-LCP/mimic-code/blob/e48a5b61136c8a92a4e28b2fde0de0e5a86d71df/etc/firstday/urine-output-first-day.sql
