-- Create a table which indicates if a patient was ever on a vasopressor during their ICU stay

-- List of vasopressors used:
-- norepinephrine - 30047,30120,221906
-- epinephrine - 30044,30119,30309,221289
-- phenylephrine - 30127,30128,221749
-- vasopressin - 30051,222315
-- dopamine - 30043,30307,221662
-- Isuprel - 30046,227692

CREATE TABLE DATABASE.ALINE_VASO_FLAG as
with io_cv as
(
  select
    icustay_id, charttime, itemid, stopped, rate, amount
  from DATABASE.inputevents_cv
  where itemid in
  (
    30047,30120 -- norepinephrine
    ,30044,30119,30309 -- epinephrine
    ,30127,30128 -- phenylephrine
    ,30051 -- vasopressin
    ,30043,30307,30125 -- dopamine
    ,30046 -- isuprel
  )
  and rate is not null
  and rate > 0
)
-- select only the ITEMIDs from the inputevents_mv table related to vasopressors
, io_mv as
(
  select
    icustay_id, linkorderid, starttime, endtime
  from DATABASE.inputevents_mv io
  -- Subselect the vasopressor ITEMIDs
  where itemid in
  (
  221906 -- norepinephrine
  ,221289 -- epinephrine
  ,221749 -- phenylephrine
  ,222315 -- vasopressin
  ,221662 -- dopamine
  ,227692 -- isuprel
  )
  and rate is not null
  and rate > 0
  and statusdescription != 'Rewritten' -- only valid orders
)
select
  co.subject_id, co.hadm_id, co.icustay_id
  , max(case when coalesce(io_mv.icustay_id, io_cv.icustay_id) is not null then 1 else 0 end) as vaso_flag
from DATABASE.icustays co
left join io_mv
  on co.icustay_id = io_mv.icustay_id
left join io_cv
  on co.icustay_id = io_cv.icustay_id
group by co.subject_id, co.hadm_id, co.icustay_id
order by icustay_id;
