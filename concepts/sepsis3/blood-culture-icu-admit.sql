with me as
(
  select hadm_id
    , chartdate, charttime
    , spec_type_desc
    , max(case when org_name is not null and org_name != '' then 1 else 0 end) as PositiveCulture
  from `physionet-data.mimic_hosp.microbiologyevents`
  group by hadm_id, chartdate, charttime, spec_type_desc
)
select
    ie.stay_id
  , min(coalesce(charttime, chartdate)) as charttime
  , max(case when me.hadm_id is not null then 1 else 0 end) as blood_culture
  , max(case when org_name is not null and org_name != '' then 1 else 0 end) as PositiveCulture
from `physionet-data.mimic_icu.icustays` ie
left join `physionet-data.mimic_hosp.microbiologyevents` me
  on ie.hadm_id = me.hadm_id
  and (
      me.charttime between DATETIME_ADD(ie.intime, INTERVAL -1 DAY) AND DATETIME_ADD(ie.intime, INTERVAL 1 DAY) 
  OR  me.chartdate between DATETIME_ADD(ie.intime, INTERVAL -1 DAY) AND DATETIME_ADD(ie.intime, INTERVAL 1 DAY) 
  )
group by ie.stay_id;