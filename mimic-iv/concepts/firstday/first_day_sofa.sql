-- ------------------------------------------------------------------
-- Title: Sequential Organ Failure Assessment (SOFA)
-- This query extracts the sequential organ failure assessment (formally: sepsis-related organ failure assessment).
-- This score is a measure of organ failure for patients in the ICU.
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for SOFA:
--    Jean-Louis Vincent, Rui Moreno, Jukka Takala, Sheila Willatts, Arnaldo De Mendonça,
--    Hajo Bruining, C. K. Reinhart, Peter M Suter, and L. G. Thijs.
--    "The SOFA (Sepsis-related Organ Failure Assessment) score to describe organ dysfunction/failure."
--    Intensive care medicine 22, no. 7 (1996): 707-710.

-- Variables used in SOFA:
--  GCS, MAP, FiO2, Ventilation status (sourced from CHARTEVENTS)
--  Creatinine, Bilirubin, FiO2, PaO2, Platelets (sourced from LABEVENTS)
--  Dopamine, Dobutamine, Epinephrine, Norepinephrine (sourced from INPUTEVENTS)
--  Urine output (sourced from OUTPUTEVENTS)

-- The following views required to run this query:
--  1) first_day_urine_output
--  2) first_day_vitalsign
--  3) first_day_gcs
--  4) first_day_lab
--  5) first_day_bg_art
--  6) ventdurations

-- extract drug rates from derived vasopressor tables
with vaso_stg as
(
  select ie.stay_id, 'norepinephrine' AS treatment, vaso_rate as rate
  FROM `physionet-data.mimiciv_icu.icustays` ie
  INNER JOIN `physionet-data.mimiciv_derived.norepinephrine` mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
    AND mv.starttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  UNION ALL
  select ie.stay_id, 'epinephrine' AS treatment, vaso_rate as rate
  FROM `physionet-data.mimiciv_icu.icustays` ie
  INNER JOIN `physionet-data.mimiciv_derived.epinephrine` mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
    AND mv.starttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  UNION ALL
  select ie.stay_id, 'dobutamine' AS treatment, vaso_rate as rate
  FROM `physionet-data.mimiciv_icu.icustays` ie
  INNER JOIN `physionet-data.mimiciv_derived.dobutamine` mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
    AND mv.starttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  UNION ALL
  select ie.stay_id, 'dopamine' AS treatment, vaso_rate as rate
  FROM `physionet-data.mimiciv_icu.icustays` ie
  INNER JOIN `physionet-data.mimiciv_derived.dopamine` mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
    AND mv.starttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
)
, vaso_mv AS
(
    SELECT
    ie.stay_id
    , max(CASE WHEN treatment = 'norepinephrine' THEN rate ELSE NULL END) as rate_norepinephrine
    , max(CASE WHEN treatment = 'epinephrine' THEN rate ELSE NULL END) as rate_epinephrine
    , max(CASE WHEN treatment = 'dopamine' THEN rate ELSE NULL END) as rate_dopamine
    , max(CASE WHEN treatment = 'dobutamine' THEN rate ELSE NULL END) as rate_dobutamine
  from `physionet-data.mimiciv_icu.icustays` ie
  LEFT JOIN vaso_stg v
      ON ie.stay_id = v.stay_id
  GROUP BY ie.stay_id
)
, pafi1 as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  select ie.stay_id, bg.charttime
  , bg.pao2fio2ratio
  , case when vd.stay_id is not null then 1 else 0 end as IsVent
  from `physionet-data.mimiciv_icu.icustays` ie
  LEFT JOIN `physionet-data.mimiciv_derived.bg` bg
      ON ie.subject_id = bg.subject_id
      AND bg.charttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
      AND bg.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  LEFT JOIN `physionet-data.mimiciv_derived.ventilation` vd
    ON ie.stay_id = vd.stay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
    AND vd.ventilation_status = 'InvasiveVent'
)
, pafi2 as
(
  -- because pafi has an interaction between vent/PaO2:FiO2, we need two columns for the score
  -- it can happen that the lowest unventilated PaO2/FiO2 is 68, but the lowest ventilated PaO2/FiO2 is 120
  -- in this case, the SOFA score is 3, *not* 4.
  select stay_id
  , min(case when IsVent = 0 then pao2fio2ratio else null end) as PaO2FiO2_novent_min
  , min(case when IsVent = 1 then pao2fio2ratio else null end) as PaO2FiO2_vent_min
  from pafi1
  group by stay_id
)
-- Aggregate the components for the score
, scorecomp as
(
select ie.stay_id
  , v.mbp_min
  , mv.rate_norepinephrine
  , mv.rate_epinephrine
  , mv.rate_dopamine
  , mv.rate_dobutamine

  , l.creatinine_max
  , l.bilirubin_total_max as bilirubin_max
  , l.platelets_min as platelet_min

  , pf.PaO2FiO2_novent_min
  , pf.PaO2FiO2_vent_min

  , uo.UrineOutput

  , gcs.gcs_min
from `physionet-data.mimiciv_icu.icustays` ie
left join vaso_mv mv
  on ie.stay_id = mv.stay_id
left join pafi2 pf
 on ie.stay_id = pf.stay_id
left join `physionet-data.mimiciv_derived.first_day_vitalsign` v
  on ie.stay_id = v.stay_id
left join `physionet-data.mimiciv_derived.first_day_lab` l
  on ie.stay_id = l.stay_id
left join `physionet-data.mimiciv_derived.first_day_urine_output` uo
  on ie.stay_id = uo.stay_id
left join `physionet-data.mimiciv_derived.first_day_gcs` gcs
  on ie.stay_id = gcs.stay_id
)
, scorecalc as
(
  -- Calculate the final score
  -- note that if the underlying data is missing, the component is null
  -- eventually these are treated as 0 (normal), but knowing when data is missing is useful for debugging
  select stay_id
  -- Respiration
  , case
      when PaO2FiO2_vent_min   < 100 then 4
      when PaO2FiO2_vent_min   < 200 then 3
      when PaO2FiO2_novent_min < 300 then 2
      when PaO2FiO2_novent_min < 400 then 1
      when coalesce(PaO2FiO2_vent_min, PaO2FiO2_novent_min) is null then null
      else 0
    end as respiration

  -- Coagulation
  , case
      when platelet_min < 20  then 4
      when platelet_min < 50  then 3
      when platelet_min < 100 then 2
      when platelet_min < 150 then 1
      when platelet_min is null then null
      else 0
    end as coagulation

  -- Liver
  , case
      -- Bilirubin checks in mg/dL
        when bilirubin_max >= 12.0 then 4
        when bilirubin_max >= 6.0  then 3
        when bilirubin_max >= 2.0  then 2
        when bilirubin_max >= 1.2  then 1
        when bilirubin_max is null then null
        else 0
      end as liver

  -- Cardiovascular
  , case
      when rate_dopamine > 15 or rate_epinephrine >  0.1 or rate_norepinephrine >  0.1 then 4
      when rate_dopamine >  5 or rate_epinephrine <= 0.1 or rate_norepinephrine <= 0.1 then 3
      when rate_dopamine >  0 or rate_dobutamine > 0 then 2
      when mbp_min < 70 then 1
      when coalesce(mbp_min, rate_dopamine, rate_dobutamine, rate_epinephrine, rate_norepinephrine) is null then null
      else 0
    end as cardiovascular

  -- Neurological failure (GCS)
  , case
      when (gcs_min >= 13 and gcs_min <= 14) then 1
      when (gcs_min >= 10 and gcs_min <= 12) then 2
      when (gcs_min >=  6 and gcs_min <=  9) then 3
      when  gcs_min <   6 then 4
      when  gcs_min is null then null
  else 0 end
    as cns

  -- Renal failure - high creatinine or low urine output
  , case
    when (creatinine_max >= 5.0) then 4
    when  UrineOutput < 200 then 4
    when (creatinine_max >= 3.5 and creatinine_max < 5.0) then 3
    when  UrineOutput < 500 then 3
    when (creatinine_max >= 2.0 and creatinine_max < 3.5) then 2
    when (creatinine_max >= 1.2 and creatinine_max < 2.0) then 1
    when coalesce(UrineOutput, creatinine_max) is null then null
  else 0 end
    as renal
  from scorecomp
)
select ie.subject_id, ie.hadm_id, ie.stay_id
  -- Combine all the scores to get SOFA
  -- Impute 0 if the score is missing
  , coalesce(respiration,0)
  + coalesce(coagulation,0)
  + coalesce(liver,0)
  + coalesce(cardiovascular,0)
  + coalesce(cns,0)
  + coalesce(renal,0)
  as SOFA
, respiration
, coagulation
, liver
, cardiovascular
, cns
, renal
from `physionet-data.mimiciv_icu.icustays` ie
left join scorecalc s
  on ie.stay_id = s.stay_id
;