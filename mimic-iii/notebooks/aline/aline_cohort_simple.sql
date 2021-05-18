-- This query defines the cohort used for the ALINE study.
-- This query is a simpler version of aline_cohort.sql, and does not generate a view.
-- Many of the variables from the aline study are trimmed to simplify the query.
-- See aline_cohort.sql for the actual cohort table generation.

-- Tables required:
--    ventdurations, angus_sepsis, aline_vaso_flag

-- Exclusion criteria:
--  non-adult patients
--  Secondary ICU admission
--  In ICU for less than 24 hours
--  not mechanical ventilation within the first 24 hours
--  non medical or non surgical ICU admission
--  **Angus sepsis
--  IAC placed before admission

-- get start time of arterial line
-- Definition of arterial line insertion:
--  First measurement of invasive blood pressure
with a as
(
  select icustay_id
  , min(charttime) as starttime_aline
  from chartevents
  where icustay_id is not null
  and valuenum is not null
  and itemid in
  (
    51, --	Arterial BP [Systolic]
    6701, --	Arterial BP #2 [Systolic]
    220050, --	Arterial Blood Pressure systolic

    8368, --	Arterial BP [Diastolic]
    8555, --	Arterial BP #2 [Diastolic]
    220051, --	Arterial Blood Pressure diastolic

    52, --"Arterial BP Mean"
    6702, --	Arterial BP Mean #2
    220052, --"Arterial Blood Pressure mean"
    225312 --"ART BP mean"
  )
  group by icustay_id
)
-- first time ventilation was started
-- last time ventilation was stopped
, ve as
(
  select icustay_id
    , min(starttime) as vent_starttime
    , max(endtime) as vent_endtime
  from ventdurations vd
  group by icustay_id
)
-- first service
, serv as
(
    select icu.icustay_id, se.curr_service
    , ROW_NUMBER() over (
        PARTITION BY icu.icustay_id
        ORDER BY se.transfertime DESC
      ) as rn
    from icustays ie
    inner join services se
      on icu.hadm_id = se.hadm_id
      and se.transfertime < icu.intime + interval '2' hour
)
-- cohort view - used to define/aggregate concepts for exclusion
, co as
(
  select
    icu.subject_id, icu.hadm_id, icu.icustay_id
    , icu.intime, icu.outtime
    , ROW_NUMBER() over
      (
        PARTITION BY icu.subject_id
        ORDER BY icu.intime
      ) as stay_num
    , extract(epoch from (icu.intime - pat.dob))/365.242/24.0/60.0/60.0 as age
    , extract(epoch from (icu.outtime - icu.intime))/24.0/60.0/60.0 as icu_length_of_stay
    -- from pre-generated tables
    , vf.vaso_flag
    , sep.angus
    -- service
    -- will be used to exclude patients in CSRU
    -- also only include those in CMED or SURG
    , s.curr_service as service_unit
    -- time of a-line
    , a.starttime_aline
    -- time of ventilation
    , ve.vent_starttime
    , ve.vent_endtime
  from icustays icu
  inner join admissions adm
    on icu.hadm_id = adm.hadm_id
  inner join patients pat
    on icu.subject_id = pat.subject_id
  left join a
    on icu.icustay_id = a.icustay_id
  left join ve
    on icu.icustay_id = ve.icustay_id
  left join serv s
    on icu.icustay_id = s.icustay_id
    and s.rn = 1
  left join angus_sepsis sep
    on icu.hadm_id = sep.hadm_id
)
select
    co.subject_id, co.hadm_id, co.icustay_id
  , case when age < 16 then 1 else 0 end as exclusion_non_adult -- only adults
  , case when stay_num > 1 then 1 else 0 end as exclusion_secondary_stay -- first ICU stay
  , case when icu_length_of_stay < 1 then 1 else 0 end exclusion_short_stay -- one day in the ICU
  , case
          -- not ventilated
          when vent_starttime is null
          -- ventilated more than 24 hours after admission
            or vent_starttime > intime + interval '24' hour
        then 1
    else 0 end exclusion_not_ventilated_first24hr
  , case when angus = 1
          then 1
    else 0 end as exclusion_septic
  , case when vaso_flag = 1
          then 1
    else 0 end as exclusion_vasopressors
  , case when starttime_aline is not null
         and starttime_aline <= intime
        then 1
    else 0 end exclusion_aline_before_admission -- aline must be placed later than admission
  -- we need to approximate CCU and CSRU using hospital service
  -- paper only says CSRU but the code did both CCU/CSRU
  -- this is the best guess
  -- "medical or surgical ICU admission"
  , case when service_unit in
  (
    'CMED','CSURG','VSURG','TSURG' -- cardiac/vascular/thoracic surgery
  ) then 1 else 0 end as exclusion_service_surgical
from co
order by icustay_id;
