-- This table requires:
--  abx_poe_list
--  abx_micro_poe
--  suspinfect_poe

with serv as
(
    select hadm_id, curr_service
    , ROW_NUMBER() over (partition by hadm_id order by transfertime) as rn
    from `physionet-data.mimic_hosp.services`
)
, t1 as
(
select ie.stay_id, ie.hadm_id
    , ie.intime, ie.outtime
    , pat.anchor_age + (EXTRACT(YEAR FROM adm.admittime) - pat.anchor_year) as age
    , pat.gender
    , adm.ethnicity
    -- used to get first ICUSTAY_ID
    , ROW_NUMBER() over (partition by ie.subject_id order by intime) as rn

    -- exclusions
    , s.curr_service as first_service

    -- suspicion of infection using POE
    , case when spoe.suspected_infection_time is not null then 1 else 0 end
        as suspected_of_infection_poe
    , spoe.suspected_infection_time as suspected_infection_time_poe
    , DATETIME_DIFF(ie.intime, spoe.suspected_infection_time, DAY) 
        as suspected_infection_time_poe_days
    --, DATETIME_DIFF(ie.intime, spoe.suspected_infection_time, SECOND)
    --      / 60.0 / 60.0 / 24.0 as suspected_infection_time_poe_days
    , spoe.specimen as specimen_poe
    , spoe.positiveculture as positiveculture_poe
    , spoe.antibiotic_time as antibiotic_time_poe

from `physionet-data.mimic_icu.icustays` ie
inner join `physionet-data.mimic_core.admissions` adm
    on ie.hadm_id = adm.hadm_id
inner join `physionet-data.mimic_core.patients` pat
    on ie.subject_id = pat.subject_id
left join serv s
    on ie.hadm_id = s.hadm_id
    and s.rn = 1
left join `physionet-data.mimic_derived.suspinfect_poe` spoe
  on ie.stay_id = spoe.stay_id
)
select
    t1.hadm_id, t1.stay_id
  , t1.intime, t1.outtime

  -- set de-identified ages to median of 91.4
  , case when age > 89 then 91.4 else age end as age
  , gender
  , ethnicity
  , first_service

  -- suspicion using POE
  , suspected_of_infection_poe
  , suspected_infection_time_poe
  , suspected_infection_time_poe_days
  , specimen_poe
  , positiveculture_poe
  , antibiotic_time_poe

  -- exclusions
  , case when t1.rn = 1 then 0 else 1 end as exclusion_secondarystay
  , case when t1.age <= 16 then 1 else 0 end as exclusion_nonadult
  , case when t1.first_service in ('CSURG','VSURG','TSURG') then 1 else 0 end as exclusion_csurg
  , case when t1.suspected_infection_time_poe is not null
          and t1.suspected_infection_time_poe < DATETIME_SUB(t1.intime, INTERVAL 1 DAY) then 1
      else 0 end as exclusion_early_suspicion
  , case when t1.suspected_infection_time_poe is not null
          and t1.suspected_infection_time_poe > DATETIME_ADD(t1.intime, INTERVAL 1 DAY) then 1
      else 0 end as exclusion_late_suspicion
  , case when t1.intime is null then 1
         when t1.outtime is null then 1
      else 0 end as exclusion_bad_data
  -- , case when t1.suspected_of_infection = 0 then 1 else 0 end as exclusion_suspicion

  -- the above flags are used to summarize patients excluded
  -- below flag is used to actually exclude patients in future queries
  , case when
             t1.rn != 1
          or t1.age <= 16
          or t1.first_service in ('CSURG','VSURG','TSURG')
          or t1.intime is null
          or t1.outtime is null
          or (
                  t1.suspected_infection_time_poe is not null
              and t1.suspected_infection_time_poe < DATETIME_SUB(t1.intime, INTERVAL 1 DAY) 
            )
          or (
                  t1.suspected_infection_time_poe is not null
              and t1.suspected_infection_time_poe > DATETIME_ADD(t1.intime, INTERVAL 1 DAY) 
            )
          -- or t1.suspected_of_infection = 0
            then 1
        else 0 end as excluded
from t1;