-- This query defines the cohort used for the ALINE study.

-- Inclusion criteria:
--  adult patients
--  In ICU for at least 24 hours
--  First ICU admission
--  mechanical ventilation within the first 12 hours
--  medical or surgical ICU admission

-- Exclusion criteria:
--  **Angus sepsis
--  **On vasopressors (?is this different than on dobutamine)
--  IAC placed before admission
--  CSRU patients

-- **These exclusion criteria are applied in the data.sql file.

-- This query also extracts demographics, and necessary preliminary flags needed
-- for data extraction. For example, since all data is extracted before
-- ventilation, we need to extract start times of ventilation


-- This query requires the following tables:
--  ventdurations - extracted by mimic-code/concepts/durations/ventilation-durations.sql

CREATE TABLE DATABASE.ALINE_COHORT_ALL as

-- get start time of arterial line
-- Definition of arterial line insertion:
--  First measurement of invasive blood pressure
with a as
(
  select icustay_id
  , min(charttime) as starttime_aline
  from DATABASE.chartevents
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
-- get intime/outtime from vitals rather than administrative data
, co_intime as
(
  select ie.icustay_id, min(charttime) as intime, max(charttime) as outtime
  from DATABASE.icustays ie
  left join DATABASE.chartevents ce
    on ie.icustay_id = ce.icustay_id
    and ce.charttime between ie.intime - interval '12' hour and ie.outtime + interval '12' hour
    and ce.itemid in (211, 220045)
  group by ie.icustay_id
)
-- first time ventilation was started
-- last time ventilation was stopped
, ve as
(
  select icustay_id
    , sum(date_diff('second',starttime, endtime))/24.0/60.0/60.0 as vent_day
    , min(starttime) as starttime_first
    , max(endtime) as endtime_last
  from DATABASE.ventdurations vd
  group by icustay_id
)
, serv as
(
    select ie.icustay_id, se.curr_service
    , ROW_NUMBER() over (partition by ie.icustay_id order by se.transfertime DESC) as rn
    from DATABASE.icustays ie
    inner join DATABASE.services se
      on ie.hadm_id = se.hadm_id
      and se.transfertime < ie.intime + interval '2' hour
)
-- cohort view - used to define other concepts
, co as
(
  select
    ie.subject_id, ie.hadm_id, ie.icustay_id
    , co.intime
    , date_format(co.intime, '%W') as day_icu_intime
    , extract(dow from co.intime) as day_icu_intime_num
    , extract(hour from co.intime) as hour_icu_intime
    , co.outtime

    , ROW_NUMBER() over (partition by ie.subject_id order by adm.admittime, co.intime) as stay_num
    , date_diff('second', pat.dob, co.intime)/365.242/24.0/60.0/60.0 as age
    , pat.gender
    , case when pat.gender = 'M' then 1 else 0 end as gender_num
    , vf.vaso_flag
    , sep.angus
    -- service

    -- collapse ethnicity into fixed categories

    -- time of a-line
    , a.starttime_aline
    , case when a.starttime_aline is not null then 1 else 0 end as aline_flag
    , date_diff('second', co.intime, a.starttime_aline)/24.0/60.0/60.0 as aline_time_day
    , case
        when a.starttime_aline is not null
         and a.starttime_aline <= co.intime
          then 1
        else 0
      end as initial_aline_flag

    -- ventilation
    , case when ve.icustay_id is not null then 1 else 0 end as vent_flag
    , case when ve.starttime_first < co.intime + interval '12' hour then 1 else 0 end as vent_1st_12hr
    , case when ve.starttime_first < co.intime + interval '24' hour then 1 else 0 end as vent_1st_24hr

    -- binary flag: were they ventilated before a-line insertion?
    , case
        -- if they were never given an aline, this is a non-sensical question
        when a.starttime_aline is null then null
        -- aline given for sure after ventilation
        when a.starttime_aline > co.intime + interval '1' hour and ve.starttime_first<=a.starttime_aline then 1
        -- aline given for sure after ventilation
        when a.starttime_aline > co.intime + interval '1' hour and ve.starttime_first>a.starttime_aline then 0
        else NULL
      end as vent_b4_aline

    -- number of days on a ventilator
    , ve.vent_day

    -- number of days free of ventilator after *last* extubation
    , date_diff('second', ve.endtime_last, ie.outtime)/24.0/60.0/60.0 as vent_free_day

    -- number of days *not* on a ventilator
    , date_diff('second', co.intime, ie.outtime)/24.0/60.0/60.0 - vent_day as vent_off_day


    , ve.starttime_first as vent_starttime
    , ve.endtime_last as vent_endtime

    -- cohort flags // demographics
    , date_diff('second', co.intime, ie.outtime)/24.0/60.0/60.0 as icu_los_day
    , date_diff('second',adm.admittime, adm.dischtime)/24.0/60.0/60.0 as hospital_los_day

    -- will be used to exclude patients in CSRU
    -- also only include those in CMED or SURG
    , s.curr_service as service_unit
    , case when s.curr_service like '%SURG' or s.curr_service like '%ORTHO%' then 1
          when s.curr_service = 'CMED' then 2
          when s.curr_service in ('CSURG','VSURG','TSURG') then 3
          else 0
        end
      as service_num

    -- outcome
    , case when adm.deathtime is not null then 1 else 0 end as hosp_exp_flag
    , case when adm.deathtime <= ie.outtime then 1 else 0 end as icu_exp_flag
    , case when pat.dod <= (co.intime + interval '28' day) then 1 else 0 end as day_28_flag
    , date_diff('second',adm.admittime, pat.dod)/24.0/60.0/60.0 as mort_day

    , case when pat.dod is null
        then 150 -- patient deaths are censored 150 days after admission
        else date_diff('second', adm.admittime, pat.dod)/24.0/60.0/60.0
      end as mort_day_censored
    , case when pat.dod is null then 1 else 0 end as censor_flag

  from co_intime co
  inner join DATABASE.icustays ie
    on co.icustay_id = ie.icustay_id
  inner join DATABASE.admissions adm
    on ie.hadm_id = adm.hadm_id
  inner join DATABASE.patients pat
    on ie.subject_id = pat.subject_id
  left join a
    on ie.icustay_id = a.icustay_id
  left join ve
    on ie.icustay_id = ve.icustay_id
  left join serv s
    on ie.icustay_id = s.icustay_id
    and s.rn = 1
  left join DATABASE.aline_vaso_flag vf
    on ie.icustay_id = vf.icustay_id
  left join DATABASE.angus_sepsis sep
    on ie.hadm_id = sep.hadm_id
  where co.intime > (pat.dob + interval '16' year) -- only adults
)
select
  co.*
  , case when stay_num > 1 then 1 else 0 end as exclusion_readmission -- first ICU stay
  , case when icu_los_day < 1 then 1 else 0 end exclusion_shortstay -- one day in the ICU
  , case when vaso_flag = 1 then 1 else 0 end as exclusion_vasopressors
  , case when angus = 1 then 1 else 0 end as exclusion_septic
  , case when initial_aline_flag = 1 then 1 else 0 end exclusion_aline_before_admission -- aline must be placed later than admission
  -- exclusion: IAC placement was performed prior to endotracheal intubation and initiation of mechanical ventilation
  -- we do not apply this criteria since it's unclear if this was actually done in the original aline paper
  -- , case when vent_b4_aline = 0 then 1 else 0 end as exclusion_aline_before_vent
  , case when vent_starttime is null or vent_starttime > intime + interval '24' hour then 1 else 0 end exclusion_not_ventilated_first24hr -- were ventilated
  -- above also requires ventilated within first 24 hours
  , case when service_unit in
  (
    -- we need to approximate CCU and CSRU using hospital service
    -- paper only says CSRU but the code did both CCU/CSRU
    -- this is the best guess
    'CMED','CSURG','VSURG','TSURG' -- cardiac/vascular/thoracic surgery
  ) then 1 else 0 end as exclusion_service_surgical
  -- "medical or surgical ICU admission"

from co
order by icustay_id;