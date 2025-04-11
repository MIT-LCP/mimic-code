drop table if exists kdigo_stages; create table kdigo_stages as 
-- This query checks if the patient had AKI according to KDIGO.
-- AKI is calculated every time a creatinine or urine output measurement occurs.
-- Baseline creatinine is defined as the lowest creatinine in the past 7 days.

-- get creatinine stages
with cr_stg as
(
  select
    cr.icustay_id
    , cr.charttime
    , cr.creat
    , case
        -- 3x baseline
        when cr.creat >= (cr.creat_low_past_7day*3.0) then 3
        -- *OR* cr >= 4.0 with associated increase
        when cr.creat >= 4
        -- For patients reaching Stage 3 by SCr >4.0 mg/dl
        -- require that the patient first achieve ... acute increase >= 0.3 within 48 hr
        -- *or* an increase of >= 1.5 times baseline
        and (cr.creat_low_past_48hr <= 3.7 or cr.creat >= (1.5*cr.creat_low_past_7day))
            then 3 
        -- TODO: initiation of RRT
        when cr.creat >= (cr.creat_low_past_7day*2.0) then 2
        when cr.creat >= (cr.creat_low_past_48hr+0.3) then 1
        when cr.creat >= (cr.creat_low_past_7day*1.5) then 1
    else 0 end as aki_stage_creat
  from kdigo_creatinine cr
)
-- stages for UO / creat
, uo_stg as
(
  select
      uo.icustay_id
    , uo.charttime
    , uo.weight
    , uo.uo_rt_6hr
    , uo.uo_rt_12hr
    , uo.uo_rt_24hr
    -- AKI stages according to urine output
    , case
        when uo.uo_rt_6hr is null then null
        -- require patient to be in icu for at least 6 hours to stage uo
        when uo.charttime <= (ie.intime + interval '6 hour') then 0
        -- require the uo rate to be calculated over half the period
        -- i.e. for uo rate over 24 hours, require documentation at least 12 hr apart
        when uo.uo_tm_24hr >= 11 and uo.uo_rt_24hr < 0.3 then 3
        when uo.uo_tm_12hr >= 5 and uo.uo_rt_12hr = 0 then 3
        when uo.uo_tm_12hr >= 5 and uo.uo_rt_12hr < 0.5 then 2
        when uo.uo_tm_6hr >= 2 and uo.uo_rt_6hr  < 0.5 then 1
    else 0 end as aki_stage_uo
  from kdigo_uo uo
  inner join icustays ie
    on uo.icustay_id = ie.icustay_id
)
-- get all charttimes documented
, tm_stg as
(
    select
      icustay_id, charttime
    from cr_stg
    union distinct
    select
      icustay_id, charttime
    from uo_stg
)
select
    ie.icustay_id
  , tm.charttime
  , cr.creat
  , cr.aki_stage_creat
  , uo.uo_rt_6hr
  , uo.uo_rt_12hr
  , uo.uo_rt_24hr
  , uo.aki_stage_uo
  -- Classify AKI using both creatinine/urine output criteria
  , greatest(
      coalesce(cr.aki_stage_creat, 0),
      coalesce(uo.aki_stage_uo, 0)
    ) as aki_stage
from icustays ie
-- get all possible charttimes as listed in tm_stg
left join tm_stg tm
  on ie.icustay_id = tm.icustay_id
left join cr_stg cr
  on ie.icustay_id = cr.icustay_id
  and tm.charttime = cr.charttime
left join uo_stg uo
  on ie.icustay_id = uo.icustay_id
  and tm.charttime = uo.charttime
order by ie.icustay_id, tm.charttime;