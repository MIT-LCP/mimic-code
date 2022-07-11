-- ------------------------------------------------------------------
-- Title: Logistic Organ Dysfunction Score (LODS)
-- This query extracts the logistic organ dysfunction system.
-- This score is a measure of organ failure in a patient.
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for LODS:
--  Le Gall, J. R., Klar, J., Lemeshow, S., Saulnier, F., Alberti, C., Artigas, A., & Teres, D.
--  The Logistic Organ Dysfunction system: a new way to assess organ dysfunction in the intensive care unit.
--  JAMA 276.10 (1996): 802-810.

-- Variables used in LODS:
--  GCS
--  VITALS: Heart rate, systolic blood pressure
--  FLAGS: ventilation/cpap
--  IO: urine output
--  LABS: blood urea nitrogen, WBC, bilirubin, creatinine, prothrombin time (PT), platelets
--  ABG: PaO2 with associated FiO2

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption that the user will subselect appropriate stay_ids.
--  For example, the score is calculated for neonates, but it is likely inappropriate to actually use the score values for these patients.

-- extract CPAP from the "Oxygen Delivery Device" fields
with cpap as
(
  select ie.stay_id
    , min(DATETIME_SUB(charttime, INTERVAL '1' HOUR)) as starttime
    , max(DATETIME_ADD(charttime, INTERVAL '4' HOUR)) as endtime
    , max(CASE
          WHEN lower(ce.value) LIKE '%cpap%' THEN 1
          WHEN lower(ce.value) LIKE '%bipap mask%' THEN 1
        else 0 end) as cpap
  FROM `physionet-data.mimiciv_icu.icustays` ie
  inner join `physionet-data.mimiciv_icu.chartevents` ce
    on ie.stay_id = ce.stay_id
    and ce.charttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  where itemid = 226732
  and (lower(ce.value) LIKE '%cpap%' or lower(ce.value) LIKE '%bipap mask%')
  group by ie.stay_id
)
, pafi1 as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  -- also join to cpap table for the same purpose
  select ie.stay_id, bg.charttime
  , pao2fio2ratio
  , case when vd.stay_id is not null then 1 else 0 end as vent
  , case when cp.stay_id is not null then 1 else 0 end as cpap
  from `physionet-data.mimiciv_derived.bg` bg
  INNER JOIN `physionet-data.mimiciv_icu.icustays` ie
    ON bg.hadm_id = ie.hadm_id
    AND bg.charttime >= ie.intime AND bg.charttime < ie.outtime
  left join `physionet-data.mimiciv_derived.ventilation` vd
    on ie.stay_id = vd.stay_id
    and bg.charttime >= vd.starttime
    and bg.charttime <= vd.endtime
    and vd.ventilation_status = 'InvasiveVent'
  left join cpap cp
    on ie.stay_id = cp.stay_id
    and bg.charttime >= cp.starttime
    and bg.charttime <= cp.endtime
)
, pafi2 as
(
  -- get the minimum PaO2/FiO2 ratio *only for ventilated/cpap patients*
  select stay_id
  , min(pao2fio2ratio) as pao2fio2_vent_min
  from pafi1
  where vent = 1 or cpap = 1
  group by stay_id
)
, cohort as
(
select  ie.subject_id
      , ie.hadm_id
      , ie.stay_id
      , ie.intime
      , ie.outtime

      , gcs.gcs_min
      , vital.heart_rate_max
      , vital.heart_rate_min
      , vital.sbp_max
      , vital.sbp_min

      -- this value is non-null iff the patient is on vent/cpap
      , pf.pao2fio2_vent_min

      , labs.bun_max
      , labs.bun_min
      , labs.wbc_max
      , labs.wbc_min
      , labs.bilirubin_total_max AS bilirubin_max
      , labs.creatinine_max
      , labs.pt_min
      , labs.pt_max
      , labs.platelets_min AS platelet_min

      , uo.urineoutput

FROM `physionet-data.mimiciv_icu.icustays` ie
inner join `physionet-data.mimiciv_hosp.admissions` adm
  on ie.hadm_id = adm.hadm_id
inner join `physionet-data.mimiciv_hosp.patients` pat
  on ie.subject_id = pat.subject_id

-- join to above view to get pao2/fio2 ratio
left join pafi2 pf
  on ie.stay_id = pf.stay_id

-- join to custom tables to get more data....
left join `physionet-data.mimiciv_derived.first_day_gcs` gcs
  on ie.stay_id = gcs.stay_id
left join `physionet-data.mimiciv_derived.first_day_vitalsign` vital
  on ie.stay_id = vital.stay_id
left join `physionet-data.mimiciv_derived.first_day_urine_output` uo
  on ie.stay_id = uo.stay_id
left join `physionet-data.mimiciv_derived.first_day_lab` labs
  on ie.stay_id = labs.stay_id
)
, scorecomp as
(
select
  cohort.*
  -- Below code calculates the component scores needed for SAPS

  -- neurologic
  , case
    when gcs_min is null then null
      when gcs_min <  3 then null -- erroneous value/on trach
      when gcs_min <=  5 then 5
      when gcs_min <=  8 then 3
      when gcs_min <= 13 then 1
    else 0
  end as neurologic

  -- cardiovascular
  , case
      when heart_rate_max is null
      and sbp_min is null then null
      when heart_rate_min < 30 then 5
      when sbp_min < 40 then 5
      when sbp_min <  70 then 3
      when sbp_max >= 270 then 3
      when heart_rate_max >= 140 then 1
      when sbp_max >= 240 then 1
      when sbp_min < 90 then 1
    else 0
  end as cardiovascular

  -- renal
  , case
      when bun_max is null
        or urineoutput is null
        or creatinine_max is null
        then null
      when urineoutput <   500.0 then 5
      when bun_max >= 56.0 then 5
      when creatinine_max >= 1.60 then 3
      when urineoutput <   750.0 then 3
      when bun_max >= 28.0 then 3
      when urineoutput >= 10000.0 then 3
      when creatinine_max >= 1.20 then 1
      when bun_max >= 17.0 then 1
      when bun_max >= 7.50 then 1
    else 0
  end as renal

  -- pulmonary
  , case
      when pao2fio2_vent_min is null then 0
      when pao2fio2_vent_min >= 150 then 1
      when pao2fio2_vent_min < 150 then 3
    else null
  end as pulmonary

  -- hematologic
  , case
      when wbc_max is null
        and platelet_min is null
          then null
      when wbc_min <   1.0 then 3
      when wbc_min <   2.5 then 1
      when platelet_min < 50.0 then 1
      when wbc_max >= 50.0 then 1
    else 0
  end as hematologic

  -- hepatic
  -- We have defined the "standard" PT as 12 seconds.
  -- This is an assumption and subsequent analyses may be affected by this assumption.
  , case
      when pt_max is null
        and bilirubin_max is null
          then null
      when bilirubin_max >= 2.0 then 1
      when pt_max > (12+3) then 1
      when pt_min < (12*0.25) then 1
    else 0
  end as hepatic

from cohort
)
select ie.subject_id, ie.hadm_id, ie.stay_id
-- coalesce statements impute normal score of zero if data element is missing
, coalesce(neurologic,0)
+ coalesce(cardiovascular,0)
+ coalesce(renal,0)
+ coalesce(pulmonary,0)
+ coalesce(hematologic,0)
+ coalesce(hepatic,0)
  as LODS
, neurologic
, cardiovascular
, renal
, pulmonary
, hematologic
, hepatic
FROM `physionet-data.mimiciv_icu.icustays` ie
left join scorecomp s
  on ie.stay_id = s.stay_id
;