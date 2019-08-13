-- Create a table which indicates if a patient was ever on a sedative before IAC

-- List of sedatives used (CareVue):
--  midazolam - 30124
--  fentanyl - 30150, 30308, 30118, 30149
--  propofol - 30131

-- List of sedatives used (MetaVision):
--  midazolam - 221668
--  fentanyl - 221744, 225972, 225942
--  propofol - 222168

CREATE TABLE DATABASE.ALINE_SEDATIVES as
with io_cv as
(
  select
    icustay_id, charttime, itemid, stopped, rate, amount
  from DATABASE.inputevents_cv
  where itemid in
  (
      30124 -- midazolam
    , 30150, 30308, 30118, 30149 -- fentanyl
    , 30131 -- propofol
  )
  and coalesce(rate,amount) is not null
  and (rate > 0 OR amount > 0)
)
-- select only the ITEMIDs from the inputevents_mv table related to vasopressors
, io_mv as
(
  select
    icustay_id, linkorderid, itemid, starttime, endtime, rate, amount
  from DATABASE.inputevents_mv io
  -- Subselect the vasopressor ITEMIDs
  where itemid in
  (
    221668 -- midazolam
  , 221744, 225972, 225942 -- fentanyl
  , 222168 -- propofol
  )
  and coalesce(rate,amount) is not null
  and (rate > 0 OR amount > 0)
  and statusdescription != 'Rewritten' -- only valid orders
)
select
    co.subject_id, co.hadm_id, co.icustay_id
  , max(case when coalesce(io_mv.icustay_id, io_cv.icustay_id) is not null then 1 else 0 end) as sedative_flag
  , max(case when coalesce(io_mv.itemid, io_cv.itemid) in (30124, 221668) then 1 else 0 end) as midazolam_flag
  , max(case when coalesce(io_mv.itemid, io_cv.itemid) in (30150, 30308, 30118, 30149, 221744, 225972, 225942) then 1 else 0 end) as fentanyl_flag
  , max(case when coalesce(io_mv.itemid, io_cv.itemid) in (30131, 222168) then 1 else 0 end) as propofol_flag
from DATABASE.aline_cohort co
left join io_mv
  on co.icustay_id = io_mv.icustay_id
  and co.starttime_aline > io_mv.starttime
  and co.starttime_aline <= io_mv.endtime
left join io_cv
  on co.icustay_id = io_cv.icustay_id
  and co.starttime_aline > io_cv.charttime
group by co.subject_id, co.hadm_id, co.icustay_id
order by icustay_id;
