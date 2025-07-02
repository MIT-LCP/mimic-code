drop table if exists kdigo_stages_7day; create table kdigo_stages_7day as 
-- This query checks if the patient had AKI during the first 7 days of their ICU
-- stay according to the KDIGO guideline.
-- https://kdigo.org/wp-content/uploads/2016/10/KDIGO-2012-AKI-Guideline-English.pdf

-- get the worst staging of creatinine in the first 48 hours
with cr_aki as
(
  select
    k.icustay_id
    , k.charttime
    , k.creat
    , k.aki_stage_creat
    , row_number() over (partition by k.icustay_id order by k.aki_stage_creat desc, k.creat desc) as rn
  from icustays ie
  inner join kdigo_stages k
    on ie.icustay_id = k.icustay_id
  where (cast(extract(epoch from (k.charttime - ie.intime))/(60*60) as numeric)) > -6
  and (cast(extract(epoch from (k.charttime - ie.intime))/(60*60*24) as numeric)) <= 7
  and k.aki_stage_creat is not null
)
-- get the worst staging of urine output in the first 48 hours
, uo_aki as
(
  select
    k.icustay_id
    , k.charttime
    , k.uo_rt_6hr, k.uo_rt_12hr, k.uo_rt_24hr
    , k.aki_stage_uo
    , row_number() over 
    (
      partition by k.icustay_id
      order by k.aki_stage_uo desc, k.uo_rt_24hr desc, k.uo_rt_12hr desc, k.uo_rt_6hr desc
    ) as rn
  from icustays ie
  inner join kdigo_stages k
    on ie.icustay_id = k.icustay_id
  where (cast(extract(epoch from (k.charttime - ie.intime))/(60*60) as numeric)) > -6
  and (cast(extract(epoch from (k.charttime - ie.intime))/(60*60*24) as numeric)) <= 7
  and k.aki_stage_uo is not null
)
-- final table is aki_stage, include worst cr/uo for convenience
select
    ie.icustay_id
  , cr.charttime as charttime_creat
  , cr.creat
  , cr.aki_stage_creat
  , uo.charttime as charttime_uo
  , uo.uo_rt_6hr
  , uo.uo_rt_12hr
  , uo.uo_rt_24hr
  , uo.aki_stage_uo

  -- classify aki using both creatinine/urine output criteria
  , greatest(
      coalesce(cr.aki_stage_creat, 0),
      coalesce(uo.aki_stage_uo, 0)
    ) as aki_stage_7day
  , case when cr.aki_stage_creat > 0 or uo.aki_stage_uo > 0 then 1 else 0 end as aki_7day

from icustays ie
left join cr_aki cr
  on ie.icustay_id = cr.icustay_id
  and cr.rn = 1
left join uo_aki uo
  on ie.icustay_id = uo.icustay_id
  and uo.rn = 1
order by ie.icustay_id;
