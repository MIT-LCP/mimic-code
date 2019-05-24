-- defines suspicion of infection using prescriptions + microbiologyevents
with abx as
(
  select pr.hadm_id
  , pr.drug as antibiotic_name
  , pr.startdate as antibiotic_time
  , pr.enddate as antibiotic_endtime
  from `physionet-data.mimiciii_clinical.prescriptions` pr
  -- inner join to subselect to only antibiotic prescriptions
  inner join `physionet-data.mimiciii_derived.abx_prescriptions_list` ab
      on pr.drug = ab.drug
)
-- get cultures for each icustay
-- note this duplicates prescriptions
-- each ICU stay in the same hospitalization will get a copy of all prescriptions for that hospitalization
, ab_tbl as
(
  select
        ie.subject_id, ie.hadm_id, ie.icustay_id
      , ie.intime, ie.outtime
      , abx.antibiotic_name
      , abx.antibiotic_time
      , abx.antibiotic_endtime
  from `physionet-data.mimiciii_clinical.icustays` ie
  left join abx
      on ie.hadm_id = abx.hadm_id
)
, me as
(
  select hadm_id
    , chartdate, charttime
    , spec_type_desc
    , max(case when org_name is not null and org_name != '' then 1 else 0 end) as PositiveCulture
  from `physionet-data.mimiciii_clinical.microbiologyevents`
  group by hadm_id, chartdate, charttime, spec_type_desc
)
, ab_fnl as
(
  select
      ab_tbl.icustay_id, ab_tbl.intime, ab_tbl.outtime
    , ab_tbl.antibiotic_name
    , ab_tbl.antibiotic_time
    , coalesce(me72.charttime,me72.chartdate) as last72_charttime
    , coalesce(me24.charttime,me24.chartdate) as next24_charttime
    , me72.positiveculture as last72_positiveculture
    , me72.spec_type_desc as last72_specimen
    , me24.positiveculture as next24_positiveculture
    , me24.spec_type_desc as next24_specimen
  from ab_tbl
  -- blood culture in last 72 hours
  left join me me72
    on ab_tbl.hadm_id = me72.hadm_id
    and ab_tbl.antibiotic_time is not null
    and
    (
      -- if charttime is available, use it
      (
          ab_tbl.antibiotic_time >= me72.charttime
      and ab_tbl.antibiotic_time <= datetime_add(me72.charttime, INTERVAL 72 HOUR)
      )
      OR
      (
      -- if charttime is not available, use chartdate
          me72.charttime is null
      and ab_tbl.antibiotic_time >= me72.chartdate
      and ab_tbl.antibiotic_time <= datetime_add(me72.chartdate, INTERVAL 96 HOUR)
      )
    )
  -- blood culture in subsequent 24 hours
  left join me me24
    on ab_tbl.hadm_id = me24.hadm_id
    and ab_tbl.antibiotic_time is not null
    and
    (
      -- if charttime is available, use it
      (
          ab_tbl.antibiotic_time <= me24.charttime
      and ab_tbl.antibiotic_time >= datetime_sub(me24.charttime, INTERVAL 24 HOUR)
      )
      OR
      (
      -- if charttime is not available, use chartdate
          me24.charttime is null
      and ab_tbl.antibiotic_time <= me24.chartdate
      and ab_tbl.antibiotic_time >= datetime_sub(me24.chartdate, INTERVAL 24 HOUR)
      )
    )
)
, ab_laststg as
(
select
  icustay_id
  , antibiotic_name
  , antibiotic_time
  , last72_charttime
  , next24_charttime

  -- time of suspected infection: either the culture time (if before antibiotic), or the antibiotic time
  , case
      when coalesce(last72_charttime,next24_charttime) is null
        then 0
      else 1 end as suspected_infection

  , coalesce(last72_charttime,next24_charttime) as suspected_infection_time

  -- the specimen that was cultured
  , case
      when last72_charttime is not null
        then last72_specimen
      when next24_charttime is not null
        then next24_specimen
    else null
  end as specimen

  -- whether the cultured specimen ended up being positive or not
  , case
      when last72_charttime is not null
        then last72_positiveculture
      when next24_charttime is not null
        then next24_positiveculture
    else null
  end as positiveculture
from ab_fnl
)
select
  icustay_id
  , antibiotic_name
  , antibiotic_time
  , last72_charttime
  , next24_charttime
  , suspected_infection_time
  -- -- the below two fields are used to extract data - modifying them facilitates sensitivity analyses
  -- , suspected_infection_time - interval '48' hour as si_starttime
  -- , suspected_infection_time + interval '24' hour as si_endtime
  , specimen, positiveculture
from ab_laststg
order by icustay_id, antibiotic_time;