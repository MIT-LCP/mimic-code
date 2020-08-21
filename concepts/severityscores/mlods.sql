-- ------------------------------------------------------------------
-- Title: Modified Logistic organ dysfunction system (mLODS)
-- This query extracts a modified version of the logistic organ dysfunction system.
-- This score was used in the third international definition of sepsis: Sepsis-3.
-- This score is a measure of organ failure in a patient.
-- ------------------------------------------------------------------

-- Reference for LODS:
--  Le Gall, J. R., Klar, J., Lemeshow, S., Saulnier, F., Alberti, C., Artigas, A., & Teres, D.
--  The Logistic Organ Dysfunction system: a new way to assess organ dysfunction in the intensive care unit.
--  JAMA 276.10 (1996): 802-810.

-- Reference for modified LODS:
--  Le Gall, J. R., Klar, J., Lemeshow, S., Saulnier, F., Alberti, C., Artigas, A., & Teres, D.
--  The Logistic Organ Dysfunction system: a new way to assess organ dysfunction in the intensive care unit.
--  JAMA 276.10 (1996): 802-810.

-- Variables used in mLODS:
--  GCS
--  VITALS: Heart rate, systolic blood pressure
--  FLAGS: ventilation/cpap
--  LABS: WBC, bilirubin, creatinine, platelets
--  ABG: PaO2 with associated FiO2

-- Variables *excluded*, that are used in the original LODS:
--  prothrombin time (PT), blood urea nitrogen, urine output

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption that the user will subselect appropriate ICUSTAY_IDs.
--  For example, the score is calculated for neonates, but it is likely inappropriate to actually use the score values for these patients.

-- extract CPAP from the "Oxygen Delivery Device" fields
with cpap as
(
  select ie.icustay_id
    , min(DATETIME_SUB(charttime, INTERVAL '1' HOUR)) as starttime
    , max(DATETIME_ADD(charttime, INTERVAL '4' HOUR)) as endtime
    , max(CASE
          WHEN lower(ce.value) LIKE '%cpap%' THEN 1
          WHEN lower(ce.value) LIKE '%bipap mask%' THEN 1
        else 0 end) as cpap
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.chartevents` ce
    on ie.icustay_id = ce.icustay_id
    and ce.charttime between ie.intime and ie.outtime
  where itemid in
  (
    -- TODO: when metavision data import fixed, check the values in 226732 match the value clause below
    467, 469, 226732
  )
  and (lower(ce.value) LIKE '%cpap%' or lower(ce.value) LIKE '%bipap mask%')
  -- exclude rows marked as error
  AND (ce.error IS NULL OR ce.error = 0)
  group by ie.icustay_id
)
, pafi1 as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  -- also join to cpap table for the same purpose
  select bg.icustay_id, bg.charttime
  , PaO2FiO2
  , case when vd.icustay_id is not null then 1 else 0 end as vent
  , case when cp.icustay_id is not null then 1 else 0 end as cpap
  from `physionet-data.mimiciii_derived.blood_gas_first_day_arterial` bg
  left join `physionet-data.mimiciii_derived.ventilation_durations` vd
    on bg.icustay_id = vd.icustay_id
    and bg.charttime >= vd.starttime
    and bg.charttime <= vd.endtime
  left join cpap cp
    on bg.icustay_id = cp.icustay_id
    and bg.charttime >= cp.starttime
    and bg.charttime <= cp.endtime
)
, pafi2 as
(
  -- get the minimum PaO2/FiO2 ratio *only for ventilated/cpap patients*
  select icustay_id
  , min(PaO2FiO2) as PaO2FiO2_vent_min
  from pafi1
  where vent = 1 or cpap = 1
  group by icustay_id
)
, cohort as
(
select  ie.subject_id
      , ie.hadm_id
      , ie.icustay_id
      , ie.intime
      , ie.outtime

      , gcs.mingcs
      , vital.heartrate_max
      , vital.heartrate_min
      , vital.sysbp_max
      , vital.sysbp_min

      -- this value is non-null iff the patient is on vent/cpap
      , pf.PaO2FiO2_vent_min

      , labs.wbc_max
      , labs.wbc_min
      , labs.bilirubin_max
      , labs.creatinine_max
      , labs.platelet_min

FROM `physionet-data.mimiciii_clinical.icustays` ie
inner join `physionet-data.mimiciii_clinical.admissions` adm
  on ie.hadm_id = adm.hadm_id
inner join `physionet-data.mimiciii_clinical.patients` pat
  on ie.subject_id = pat.subject_id

-- join to above view to get pao2/fio2 ratio
left join pafi2 pf
  on ie.icustay_id = pf.icustay_id

-- join to custom tables to get more data....
left join `physionet-data.mimiciii_derived.gcs_first_day` gcs
  on ie.icustay_id = gcs.icustay_id
left join `physionet-data.mimiciii_derived.vitals_first_day` vital
  on ie.icustay_id = vital.icustay_id
left join `physionet-data.mimiciii_derived.labs_first_day` labs
  on ie.icustay_id = labs.icustay_id
)
, scorecomp as
(
select
  cohort.*

  -- neurologic
  , case
    when mingcs is null then null
      when mingcs <  3 then null -- erroneous value/on trach
      when mingcs <=  5 then 5
      when mingcs <=  8 then 3
      when mingcs <= 13 then 1
    else 0
  end as neurologic

  -- cardiovascular
  , case
      when heartrate_max is null
      and sysbp_min is null then null
      when heartrate_min < 30 then 5
      when sysbp_min < 40 then 5
      when sysbp_min <  70 then 3
      when sysbp_max >= 270 then 3
      when heartrate_max >= 140 then 1
      when sysbp_max >= 240 then 1
      when sysbp_min < 90 then 1
    else 0
  end as cardiovascular

  -- renal
  , case
      when creatinine_max is null
        -- or UrineOutput is null
        -- or bun_max is null
        then null
      -- when UrineOutput <   500.0 then 5
      -- when bun_max >= 56.0 then 5
      when creatinine_max >= 1.60 then 3
      -- when UrineOutput <   750.0 then 3
      -- when bun_max >= 28.0 then 3
      -- when UrineOutput >= 10000.0 then 3
      when creatinine_max >= 1.20 then 1
      -- when bun_max >= 17.0 then 1
      -- when bun_max >= 7.50 then 1
    else 0
  end as renal

  -- pulmonary
  , case
      when PaO2FiO2_vent_min is null then 0
      when PaO2FiO2_vent_min >= 150 then 1
      when PaO2FiO2_vent_min < 150 then 3
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
  , case
      when bilirubin_max is null
        -- and pt_max is null
          then null
      when bilirubin_max >= 2.0 then 1
      -- when pt_max > (12+3) then 1
      -- when pt_min < (12*0.25) then 1
    else 0
  end as hepatic

from cohort
)
select ie.icustay_id
-- coalesce statements impute normal score of zero if data element is missing
, coalesce(neurologic,0)
+ coalesce(cardiovascular,0)
+ coalesce(renal,0)
+ coalesce(pulmonary,0)
+ coalesce(hematologic,0)
+ coalesce(hepatic,0)
  as mLODS
, neurologic
, cardiovascular
, renal
, pulmonary
, hematologic
, hepatic
FROM `physionet-data.mimiciii_clinical.icustays` ie
left join scorecomp s
  on ie.icustay_id = s.icustay_id
order by ie.icustay_id;
