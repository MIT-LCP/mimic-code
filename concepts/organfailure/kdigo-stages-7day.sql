-- This query checks if the patient had AKI according to KDIGO on admission
-- AKI can be defined either using data from the first 2 days, or first 7 days

-- For urine output: the highest UO in hours 0-48 is used
-- For creatinine: the creatinine value from days 0-2 or 0-7 is used.
-- Baseline creatinine is defined as first measurement in hours [-6, 24] from ICU admit

CREATE VIEW `physionet-data.mimiciii_clinical.kdigo_stages_7day` AS
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
    and DATETIME_DIFF(uo.charttime, ie.intime, HOUR) <= (7*24-6)
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
    and DATETIME_DIFF(uo.charttime, ie.intime, HOUR) <= (7*24-12)
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
    and DATETIME_DIFF(uo.charttime, ie.intime, HOUR) <= (7*24-24)
  group by ie.icustay_id
)
-- stages for UO / creat
, kdigo_stg as
(

  select ie.icustay_id
  , ie.intime, ie.outtime
  , case
    when HighCreat7day >= (LowCreat7day*3.0) then 3
    when HighCreat7day >= 4 -- note the criteria specify an INCREASE to >=4
      and LowCreat7day <= (3.5)  then 3 -- therefore we check that adm <= 3.5
    -- TODO: initiation of RRT
    when HighCreat7day >= (LowCreat7day*2.0) then 2
    when HighCreat7day >= (LowCreat7day+0.3) then 1
    when HighCreat7day >= (LowCreat7day*1.5) then 1
    when HighCreat7day is null then null
      when LowCreat7day is null then null
    else 0 end as AKI_stage_7day_creat

  -- AKI stages according to urine output
  , case
      when UO24 < 0.3 then 3
      when UO12 = 0 then 3
      when UO12 < 0.5 then 2
      when UO6  < 0.5 then 1
      when UO6  is null then null
    else 0 end as AKI_stage_7day_uo

  -- Creatinine information
  , LowCreat7dayTime, LowCreat7day
  , HighCreat7dayTime, HighCreat7day

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
      when coalesce(AKI_stage_7day_creat,AKI_stage_7day_uo) > 0 then 1
      else coalesce(AKI_stage_7day_creat,AKI_stage_7day_uo)
    end as AKI_7day

  , case
      when AKI_stage_7day_creat >= AKI_stage_7day_uo then AKI_stage_7day_creat
      when AKI_stage_7day_uo > AKI_stage_7day_creat then AKI_stage_7day_uo
      else coalesce(AKI_stage_7day_creat,AKI_stage_7day_uo)
    end as AKI_stage_7day

  , AKI_stage_7day_creat

  -- Creatinine information - convert absolute times to hours since admission
  , LowCreat7day
  , HighCreat7day
  , ROUND(DATETIME_DIFF(LowCreat7dayTime, intime, DAY), 4)  as LowCreat7dayTimeElapsed
  , ROUND(DATETIME_DIFF(HighCreat7dayTime, intime, DAY), 4) as HighCreat7dayTimeElapsed
  , LowCreat7dayTime
  , HighCreat7dayTime

  -- Urine output information: the values and the time of their measurement
  , UO6_48hr
  , UO12_48hr
  , UO24_48hr
from kdigo_stg kd
order by kd.icustay_id;
