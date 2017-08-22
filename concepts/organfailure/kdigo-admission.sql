-- This query checks if the patient had AKI according to KDIGO on admission
-- We use data from 0-7 days to define this.
-- For urine output: the highest UO in hours 0-48 is used
-- For creatinine: the creatinine value from days 0-7 is used.
-- Baseline creatinine is defined as first measurement in hours [-6, 24] from ICU admit

DROP MATERIALIZED VIEW IF EXISTS kdigo_admission;
CREATE MATERIALIZED VIEW kdigo_admission AS
with uo_6hr as
(
  select
        ie.icustay_id
      -- , uo.charttime
      -- , uo.urineoutput_6hr
      , min(uo.urineoutput_6hr / uo.weight)::numeric as uo_6hr
  from icustays ie
  inner join kdigo_uo uo
    on ie.icustay_id = uo.icustay_id
    and uo.charttime <= ie.intime + interval '42' hour
  group by ie.icustay_id
)
, uo_12hr as
(
  select
      ie.icustay_id
      -- , uo.charttime
      -- , uo.weight
      -- , uo.urineoutput_12hr
      , min(uo.urineoutput_12hr / uo.weight)::numeric as uo_12hr
  from icustays ie
  inner join kdigo_uo uo
    on ie.icustay_id = uo.icustay_id
    and uo.charttime <= ie.intime + interval '36' hour
  group by ie.icustay_id
)
, uo_24hr as
(
  select
      ie.icustay_id
      -- , uo.charttime
      -- , uo.weight
      -- , uo.urineoutput_24hr
      , min(uo.urineoutput_24hr / uo.weight)::numeric as uo_24hr
  from icustays ie
  inner join kdigo_uo uo
    on ie.icustay_id = uo.icustay_id
    and uo.charttime <= ie.intime + interval '24' hour
  group by ie.icustay_id
)
select ie.icustay_id
-- First, whether the patient has AKI or not
, case
    when HighCreat48hr >= (AdmCreat+0.3) then 1
    when HighCreat48hr >= (AdmCreat*1.5) then 1
    when UO_6hr < (0.5)  then 1 -- and we also check for low UO (== AKI)
    when AdmCreat is null then null
  else 0 end as AKI
-- First, the final AKI stages: either 48 hour or 7 day (according to creat)
, case
  when HighCreat48hr >= (AdmCreat*3.0) then 3
  when HighCreat48hr >= 4 -- note the criteria specify an INCREASE to >=4
    and AdmCreat <= (3.7)  then 3 -- therefore we check that adm <= 3.7
  when UO_24hr < 0.3  then 3
  when UO_12hr = 0  then 3 -- anuria for >= 12 hours
  -- TODO: initiation of RRT
  when HighCreat48hr >= (AdmCreat*2.0) then 2
  when UO_12hr < 0.5 then 2
  when HighCreat48hr >= (AdmCreat+0.3) then 1
  when HighCreat48hr >= (AdmCreat*1.5) then 1
  when UO_6hr  < 0.5 then 1
  when UO_12hr < 0.5 then 1
  when HighCreat48hr is null then null
    when AdmCreat is null then null
  else 0 end as AKI_stage_48hr

-- First, the final AKI stages: either 48 hour or 7 day (according to creat)
, case
  when HighCreat7day >= (AdmCreat*3.0) then 3
  when HighCreat7day >= 4 -- note the criteria specify an INCREASE to >=4
    and AdmCreat <= (3.7)  then 3 -- therefore we check that adm <= 3.7
  when UO_24hr < 0.3  then 3
  when UO_12hr = 0  then 3 -- anuria for >= 12 hours
  -- TODO: initiation of RRT
  when HighCreat7day >= (AdmCreat*2.0) then 2
  when UO_12hr < 0.5 then 2
  when HighCreat7day >= (AdmCreat+0.3) then 1
  when HighCreat7day >= (AdmCreat*1.5) then 1
  when UO_6hr  < 0.5 then 1
  when UO_12hr < 0.5 then 1
  when HighCreat7day is null then null
    when AdmCreat is null then null
  else 0 end as AKI_stage_7day

-- AKI stages according to urine output
, case
    when UO_24hr < 0.3 then 3
    when UO_12hr = 0 then 3
    when UO_12hr < 0.5 then 2
    when UO_6hr < 0.5 then 1
    when UO_6hr is null then null
  else 0 end as AKI_Stage_Urine
, case
    when UO_6hr < 0.5 then 1
    when UO_6hr is null then null
  else 0 end as AKI_Urine
-- Creatinine information
  , AdmCreat
  , HighCreat48hrTime, HighCreat48hr
  , HighCreat7dayTime, HighCreat7day
-- Urine output information: the values and the time of their measurement
, round(UO_6hr,4) as UO_6hr
, round(UO_12hr,4) as UO_12hr
, round(UO_24hr,4) as UO_24hr
from icustays ie
left join uo_6hr  on ie.icustay_id = uo_6hr.icustay_id
left join uo_12hr on ie.icustay_id = uo_12hr.icustay_id
left join uo_24hr on ie.icustay_id = uo_24hr.icustay_id
left join KDIGO_CREAT cr on ie.icustay_id = cr.icustay_id
order by ie.icustay_id;
