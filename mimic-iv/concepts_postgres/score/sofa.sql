-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS sofa; CREATE TABLE sofa AS 
-- ------------------------------------------------------------------
-- Title: Sequential Organ Failure Assessment (SOFA)
-- This query extracts the sequential organ failure assessment (formally: sepsis-related organ failure assessment).
-- This score is a measure of organ failure for patients in the ICU.
-- The score is calculated for **every hour** of the patient's ICU stay.
-- However, as the calculation window is 24 hours, care should be taken when
-- using the score before the end of the first day, as the data window is limited.
-- ------------------------------------------------------------------

-- Reference for SOFA:
--    Jean-Louis Vincent, Rui Moreno, Jukka Takala, Sheila Willatts, Arnaldo De Mendonça,
--    Hajo Bruining, C. K. Reinhart, Peter M Suter, and L. G. Thijs.
--    "The SOFA (Sepsis-related Organ Failure Assessment) score to describe organ dysfunction/failure."
--    Intensive care medicine 22, no. 7 (1996): 707-710.

-- Variables used in SOFA:
--  GCS, MAP, FiO2, Ventilation status (sourced FROM mimiciv_icu.chartevents)
--  Creatinine, Bilirubin, FiO2, PaO2, Platelets (sourced FROM mimiciv_icu.labevents)
--  Dopamine, Dobutamine, Epinephrine, Norepinephrine (sourced FROM mimiciv_icu.inputevents_mv and INPUTEVENTS_CV)
--  Urine output (sourced from OUTPUTEVENTS)

-- generate a row for every hour the patient was in the ICU
-- here, we generate a starttime/endtime for every hour of the patient's ICU stay
-- all of our joins to data will use these times to extract data pertinent to only that hour
WITH co AS
(
  select ih.stay_id, ie.hadm_id
  , hr
  -- start/endtime can be used to filter to values within this hour
  , DATETIME_SUB(ih.endtime, INTERVAL '1' HOUR) AS starttime
  , ih.endtime
  from mimiciv_derived.icustay_hourly ih
  INNER JOIN mimiciv_icu.icustays ie
    ON ih.stay_id = ie.stay_id
)
, pafi as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  select ie.stay_id
  , bg.charttime
  -- because pafi has an interaction between vent/PaO2:FiO2, we need two columns for the score
  -- it can happen that the lowest unventilated PaO2/FiO2 is 68, but the lowest ventilated PaO2/FiO2 is 120
  -- in this case, the SOFA score is 3, *not* 4.
  , case when vd.stay_id is null then pao2fio2ratio else null end pao2fio2ratio_novent
  , case when vd.stay_id is not null then pao2fio2ratio else null end pao2fio2ratio_vent
  FROM mimiciv_icu.icustays ie
  inner join mimiciv_derived.bg bg
    on ie.subject_id = bg.subject_id
  left join mimiciv_derived.ventilation vd
    on ie.stay_id = vd.stay_id
    and bg.charttime >= vd.starttime
    and bg.charttime <= vd.endtime
    and vd.ventilation_status = 'InvasiveVent'
  WHERE specimen = 'ART.'
)
, vs AS
(
    
  select co.stay_id, co.hr
  -- vitals
  , min(vs.mbp) as meanbp_min
  from co
  left join mimiciv_derived.vitalsign vs
    on co.stay_id = vs.stay_id
    and co.starttime < vs.charttime
    and co.endtime >= vs.charttime
  group by co.stay_id, co.hr
)
, gcs AS
(
  select co.stay_id, co.hr
  -- gcs
  , min(gcs.gcs) as gcs_min
  from co
  left join mimiciv_derived.gcs gcs
    on co.stay_id = gcs.stay_id
    and co.starttime < gcs.charttime
    and co.endtime >= gcs.charttime
  group by co.stay_id, co.hr
)
, bili AS
(
  select co.stay_id, co.hr
  , max(enz.bilirubin_total) as bilirubin_max
  from co
  left join mimiciv_derived.enzyme enz
    on co.hadm_id = enz.hadm_id
    and co.starttime < enz.charttime
    and co.endtime >= enz.charttime
  group by co.stay_id, co.hr
)
, cr AS
(
  select co.stay_id, co.hr
  , max(chem.creatinine) as creatinine_max
  from co
  left join mimiciv_derived.chemistry chem
    on co.hadm_id = chem.hadm_id
    and co.starttime < chem.charttime
    and co.endtime >= chem.charttime
  group by co.stay_id, co.hr
)
, plt AS
(
  select co.stay_id, co.hr
  , min(cbc.platelet) as platelet_min
  from co
  left join mimiciv_derived.complete_blood_count cbc
    on co.hadm_id = cbc.hadm_id
    and co.starttime < cbc.charttime
    and co.endtime >= cbc.charttime
  group by co.stay_id, co.hr
)
, pf AS
(
  select co.stay_id, co.hr
  , min(pafi.pao2fio2ratio_novent) AS pao2fio2ratio_novent
  , min(pafi.pao2fio2ratio_vent) AS pao2fio2ratio_vent
  from co
  -- bring in blood gases that occurred during this hour
  left join pafi
    on co.stay_id = pafi.stay_id
    and co.starttime < pafi.charttime
    and co.endtime  >= pafi.charttime
  group by co.stay_id, co.hr
)
-- sum uo separately to prevent duplicating values
, uo as
(
  select co.stay_id, co.hr
  -- uo
  , MAX(
      CASE WHEN uo.uo_tm_24hr >= 22 AND uo.uo_tm_24hr <= 30
          THEN uo.urineoutput_24hr / uo.uo_tm_24hr * 24
  END) as uo_24hr
  from co
  left join mimiciv_derived.urine_output_rate uo
    on co.stay_id = uo.stay_id
    and co.starttime < uo.charttime
    and co.endtime >= uo.charttime
  group by co.stay_id, co.hr
)
-- collapse vasopressors into 1 row per hour
-- also ensures only 1 row per chart time
, vaso AS
(
    SELECT 
        co.stay_id
        , co.hr
        , MAX(epi.vaso_rate) as rate_epinephrine
        , MAX(nor.vaso_rate) as rate_norepinephrine
        , MAX(dop.vaso_rate) as rate_dopamine
        , MAX(dob.vaso_rate) as rate_dobutamine
    FROM co
    LEFT JOIN mimiciv_derived.epinephrine epi
        on co.stay_id = epi.stay_id
        and co.endtime > epi.starttime
        and co.endtime <= epi.endtime
    LEFT JOIN mimiciv_derived.norepinephrine nor
        on co.stay_id = nor.stay_id
        and co.endtime > nor.starttime
        and co.endtime <= nor.endtime
    LEFT JOIN mimiciv_derived.dopamine dop
        on co.stay_id = dop.stay_id
        and co.endtime > dop.starttime
        and co.endtime <= dop.endtime
    LEFT JOIN mimiciv_derived.dobutamine dob
        on co.stay_id = dob.stay_id
        and co.endtime > dob.starttime
        and co.endtime <= dob.endtime
    WHERE epi.stay_id IS NOT NULL
    OR nor.stay_id IS NOT NULL
    OR dop.stay_id IS NOT NULL
    OR dob.stay_id IS NOT NULL
    GROUP BY co.stay_id, co.hr
)
, scorecomp as
(
  select
      co.stay_id
    , co.hr
    , co.starttime, co.endtime
    , pf.pao2fio2ratio_novent
    , pf.pao2fio2ratio_vent
    , vaso.rate_epinephrine
    , vaso.rate_norepinephrine
    , vaso.rate_dopamine
    , vaso.rate_dobutamine
    , vs.meanbp_min
    , gcs.gcs_min
    -- uo
    , uo.uo_24hr
    -- labs
    , bili.bilirubin_max
    , cr.creatinine_max
    , plt.platelet_min
  from co
  left join vs
    on co.stay_id = vs.stay_id
    and co.hr = vs.hr
  left join gcs
    on co.stay_id = gcs.stay_id
    and co.hr = gcs.hr
  left join bili
    on co.stay_id = bili.stay_id
    and co.hr = bili.hr
  left join cr
    on co.stay_id = cr.stay_id
    and co.hr = cr.hr
  left join plt
    on co.stay_id = plt.stay_id
    and co.hr = plt.hr
  left join pf
    on co.stay_id = pf.stay_id
    and co.hr = pf.hr
  left join uo
    on co.stay_id = uo.stay_id
    and co.hr = uo.hr
  left join vaso
    on co.stay_id = vaso.stay_id
    and co.hr = vaso.hr
)
, scorecalc as
(
  -- Calculate the final score
  -- note that if the underlying data is missing, the component is null
  -- eventually these are treated as 0 (normal), but knowing when data is missing is useful for debugging
  select scorecomp.*
  -- Respiration
  , case
      when pao2fio2ratio_vent   < 100 then 4
      when pao2fio2ratio_vent   < 200 then 3
      when pao2fio2ratio_novent < 300 then 2
      when pao2fio2ratio_vent   < 300 then 2
      when pao2fio2ratio_novent < 400 then 1
      when pao2fio2ratio_vent   < 400 then 1
      when coalesce(pao2fio2ratio_vent, pao2fio2ratio_novent) is null then null
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
      when meanbp_min < 70 then 1
      when coalesce(meanbp_min, rate_dopamine, rate_dobutamine, rate_epinephrine, rate_norepinephrine) is null then null
      else 0
    end as cardiovascular

  -- Neurological failure (GCS)
  , case
      when (gcs_min >= 13 and gcs_min <= 14) then 1
      when (gcs_min >= 10 and gcs_min <= 12) then 2
      when (gcs_min >=  6 and gcs_min <=  9) then 3
      when  gcs_min <   6 then 4
      when  gcs_min is null then null
      else 0
    end as cns

  -- Renal failure - high creatinine or low urine output
  , case
    when (creatinine_max >= 5.0) then 4
    when uo_24hr < 200 then 4
    when (creatinine_max >= 3.5 and creatinine_max < 5.0) then 3
    when uo_24hr < 500 then 3
    when (creatinine_max >= 2.0 and creatinine_max < 3.5) then 2
    when (creatinine_max >= 1.2 and creatinine_max < 2.0) then 1
    when coalesce (uo_24hr, creatinine_max) is null then null
    else 0 
  end as renal
  from scorecomp
)
, score_final as
(
  select s.*
    -- Combine all the scores to get SOFA
    -- Impute 0 if the score is missing
   -- the window function takes the max over the last 24 hours
    , coalesce(
        MAX(respiration) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0) as respiration_24hours
     , coalesce(
         MAX(coagulation) OVER (PARTITION BY stay_id ORDER BY HR
         ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
        ,0) as coagulation_24hours
    , coalesce(
        MAX(liver) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0) as liver_24hours
    , coalesce(
        MAX(cardiovascular) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0) as cardiovascular_24hours
    , coalesce(
        MAX(cns) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0) as cns_24hours
    , coalesce(
        MAX(renal) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0) as renal_24hours

    -- sum together data for final SOFA
    , coalesce(
        MAX(respiration) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0)
     + coalesce(
         MAX(coagulation) OVER (PARTITION BY stay_id ORDER BY HR
         ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0)
     + coalesce(
        MAX(liver) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0)
     + coalesce(
        MAX(cardiovascular) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0)
     + coalesce(
        MAX(cns) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0)
     + coalesce(
        MAX(renal) OVER (PARTITION BY stay_id ORDER BY HR
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
      ,0)
    as sofa_24hours
  from scorecalc s
  WINDOW W as
  (
    PARTITION BY stay_id
    ORDER BY hr
    ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING
  )
)
select * from score_final
where hr >= 0;