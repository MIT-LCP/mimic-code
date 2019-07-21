-- This query checks if the patient had AKI according to KDIGO on admission
-- AKI can be defined either using data from the first 2 days, or first 7 days

-- For urine output: the highest UO in hours 0-48 is used
-- For creatinine: the creatinine value from days 0-2 or 0-7 is used.
-- Baseline creatinine is defined as first measurement in hours [-6, 24] from ICU admit

CREATE TABLE `physionet-data.mimiciii_derived.kdigo_stages_48hr` AS
with uo_6hr as
(
  select
        ie.icustay_id
      -- , uo.charttime
      -- , uo.urineoutput_6hr
      , min(uo.urineoutput_6hr / uo.weight / 6.0) as uo6
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.kdigo_uo` uo
    on ie.icustay_id = uo.icustay_id
    and DATETIME_DIFF(uo.charttime, ie.intime, HOUR) <= 42
  group by ie.icustay_id
)
, uo_12hr as
(
  select
      ie.icustay_id
      -- , uo.charttime
      -- , uo.weight
      -- , uo.urineoutput_12hr
      , min(uo.urineoutput_12hr / uo.weight / 12.0) as uo12
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.kdigo_uo` uo
    on ie.icustay_id = uo.icustay_id
    and DATETIME_DIFF(uo.charttime, ie.intime, HOUR) <= 36
  group by ie.icustay_id
)
, uo_24hr as
(
  select
      ie.icustay_id
      -- , uo.charttime
      -- , uo.weight
      -- , uo.urineoutput_24hr
      , min(uo.urineoutput_24hr / uo.weight / 24.0) as uo24
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.kdigo_uo` uo
    on ie.icustay_id = uo.icustay_id
    and DATETIME_DIFF(uo.charttime, ie.intime, HOUR) <= 24
  group by ie.icustay_id
)
-- stages for UO / creat
, kdigo_stg as
(

  select ie.icustay_id
  , ie.intime, ie.outtime
  , case
    when HighCreat48hr >= (LowCreat48hr*3.0) then 3
    when HighCreat48hr >= 4 -- note the criteria specify an INCREASE to >=4
      and LowCreat48hr <= (3.7)  then 3 -- therefore we check that adm <= 3.7
    -- TODO: initiation of RRT
    when HighCreat48hr >= (LowCreat48hr*2.0) then 2
    when HighCreat48hr >= (LowCreat48hr+0.3) then 1
    when HighCreat48hr >= (LowCreat48hr*1.5) then 1
    when HighCreat48hr is null then null
      when LowCreat48hr is null then null
    else 0 end as AKI_stage_48hr_creat

  -- AKI stages according to urine output
  , case
      when UO24 < 0.3 then 3
      when UO12 = 0 then 3
      when UO12 < 0.5 then 2
      when UO6  < 0.5 then 1
      when UO6  is null then null
    else 0 end as AKI_stage_48hr_uo

  -- Creatinine information
  , HighCreat48hr, HighCreat48hrTime
  , LowCreat48hr, LowCreat48hrTime

  -- Urine output information: the values and the time of their measurement
  , round(UO6,4) as UO6_48hr
  , round(UO12,4) as UO12_48hr
  , round(UO24,4) as UO24_48hr
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  left join uo_6hr  on ie.icustay_id = uo_6hr.icustay_id
  left join uo_12hr on ie.icustay_id = uo_12hr.icustay_id
  left join uo_24hr on ie.icustay_id = uo_24hr.icustay_id
  left join `physionet-data.mimiciii_clinical.kdigo_creat` cr on ie.icustay_id = cr.icustay_id
)
select
  kd.icustay_id

  -- Classify AKI using both creatinine/urine output criteria
  , case
      when coalesce(AKI_stage_48hr_creat,AKI_stage_48hr_uo) > 0 then 1
      else coalesce(AKI_stage_48hr_creat,AKI_stage_48hr_uo)
    end as AKI_48hr

  , case
      when AKI_stage_48hr_creat >= AKI_stage_48hr_uo then AKI_stage_48hr_creat
      when AKI_stage_48hr_uo > AKI_stage_48hr_creat then AKI_stage_48hr_uo
      else coalesce(AKI_stage_48hr_creat,AKI_stage_48hr_uo)
    end as AKI_stage_48hr

  -- components
  , AKI_stage_48hr_creat
  , AKI_stage_48hr_uo

  -- Creatinine information - convert absolute times to hours since admission
  , LowCreat48hr
  , HighCreat48hr
  , ROUND(DATETIME_DIFF(LowCreat48hrTime, intime, DAY), 4)  as LowCreat48hrTimeElapsed
  , ROUND(DATETIME_DIFF(HighCreat48hrTime, intime, DAY), 4) as HighCreat48hrTimeElapsed
  , LowCreat48hrTime
  , HighCreat48hrTime

  -- Urine output information: the values and the time of their measurement
  , UO6_48hr
  , UO12_48hr
  , UO24_48hr
from kdigo_stg kd
order by kd.icustay_id;
