-- ------------------------------------------------------------------
-- Title: Acute Physiology Score III (APS III)
-- This query extracts the acute physiology score III.
-- This score is a measure of patient severity of illness.
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for APS III:
--    Knaus WA, Wagner DP, Draper EA, Zimmerman JE, Bergner M, Bastos PG, Sirio CA, Murphy DJ, Lotring T, Damiano A.
--    The APACHE III prognostic system. Risk prediction of hospital mortality for critically ill hospitalized adults.
--    Chest Journal. 1991 Dec 1;100(6):1619-36.

-- Reference for the equation for calibrating APS III to hospital mortality:
--    Johnson, A. E. W. (2015). Mortality prediction and acuity assessment in critical care.
--    University of Oxford, Oxford, UK.

-- Variables used in APS III:
--  GCS
--  VITALS: Heart rate, mean blood pressure, temperature, respiration rate
--  FLAGS: ventilation/cpap, chronic dialysis
--  IO: urine output
--  LABS: pao2, A-aDO2, hematocrit, WBC, creatinine
--        , blood urea nitrogen, sodium, albumin, bilirubin, glucose, pH, pCO2

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption that the user will subselect appropriate stay_ids.
--  For example, the score is calculated for neonates, but it is likely inappropriate to actually use the score values for these patients.

-- List of TODO:
-- The site of temperature is not incorporated. Axillary measurements should be increased by 1 degree.
-- Unfortunately the data for metavision is not available at the moment.
--  674 | Temp. Site
--  224642 | Temperature Site

with pa as
(
  select ie.stay_id, bg.charttime
  , po2 as PaO2
  , ROW_NUMBER() over (partition by ie.stay_id ORDER BY bg.po2 DESC) as rn
  from `physionet-data.mimiciv_derived.bg` bg
  INNER JOIN `physionet-data.mimiciv_icu.icustays` ie
    ON bg.hadm_id = ie.hadm_id
    AND bg.charttime >= ie.intime AND bg.charttime < ie.outtime
  left join `physionet-data.mimiciv_derived.ventilation` vd
    on ie.stay_id = vd.stay_id
    and bg.charttime >= vd.starttime
    and bg.charttime <= vd.endtime
    and vd.ventilation_status = 'InvasiveVent'
  WHERE vd.stay_id is null -- patient is *not* ventilated
  -- and fio2 < 50, or if no fio2, assume room air
  AND coalesce(fio2, fio2_chartevents, 21) < 50
  AND bg.po2 IS NOT NULL
  AND bg.specimen = 'ART.'
)
, aa as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  -- also join to cpap table for the same purpose
  select ie.stay_id, bg.charttime
  , bg.aado2
  , ROW_NUMBER() over (partition by ie.stay_id ORDER BY bg.aado2 DESC) as rn
  -- row number indicating the highest AaDO2
  from `physionet-data.mimiciv_derived.bg` bg
  INNER JOIN `physionet-data.mimiciv_icu.icustays` ie
    ON bg.hadm_id = ie.hadm_id
    AND bg.charttime >= ie.intime AND bg.charttime < ie.outtime
  INNER JOIN `physionet-data.mimiciv_derived.ventilation` vd
    on ie.stay_id = vd.stay_id
    and bg.charttime >= vd.starttime
    and bg.charttime <= vd.endtime
    and vd.ventilation_status = 'InvasiveVent'
  WHERE vd.stay_id is not null -- patient is ventilated
  AND coalesce(fio2, fio2_chartevents) >= 50
  AND bg.aado2 IS NOT NULL
  AND bg.specimen = 'ART.'
)
-- because ph/pco2 rules are an interaction *within* a blood gas, we calculate them here
-- the worse score is then taken for the final calculation
, acidbase as
(
  select ie.stay_id
  , ph, pco2 as paco2
  , case
      when ph is null or pco2 is null then null
      when ph < 7.20 then
        case
          when pco2 < 50 then 12
          else 4
        end
      when ph < 7.30 then
        case
          when pco2 < 30 then 9
          when pco2 < 40 then 6
          when pco2 < 50 then 3
          else 2
        end
      when ph < 7.35 then
        case
          when pco2 < 30 then 9
          when pco2 < 45 then 0
          else 1
        end
      when ph < 7.45 then
        case
          when pco2 < 30 then 5
          when pco2 < 45 then 0
          else 1
        end
      when ph < 7.50 then
        case
          when pco2 < 30 then 5
          when pco2 < 35 then 0
          when pco2 < 45 then 2
          else 12
        end
      when ph < 7.60 then
        case
          when pco2 < 40 then 3
          else 12
        end
      else -- ph >= 7.60
        case
          when pco2 < 25 then 0
          when pco2 < 40 then 3
          else 12
        end
    end as acidbase_score
  from `physionet-data.mimiciv_derived.bg` bg
  INNER JOIN `physionet-data.mimiciv_icu.icustays` ie
    ON bg.hadm_id = ie.hadm_id
    AND bg.charttime >= ie.intime AND bg.charttime < ie.outtime
  where ph is not null and pco2 is not null
  AND bg.specimen = 'ART.'
)
, acidbase_max as
(
  select stay_id, acidbase_score, ph, paco2
    -- create integer which indexes maximum value of score with 1
  , ROW_NUMBER() over (partition by stay_id ORDER BY acidbase_score DESC) as acidbase_rn
  from acidbase
)
-- define acute renal failure (ARF) as:
--  creatinine >=1.5 mg/dl
--  and urine output <410 cc/day
--  and no chronic dialysis
, arf as
(
  select ie.stay_id
    , case
        when labs.creatinine_max >= 1.5
        and  uo.urineoutput < 410
        -- acute renal failure is only coded if the patient is not on chronic dialysis
        -- we use ICD-9 coding of ESRD as a proxy for chronic dialysis
        and  icd.ckd = 0
          then 1
      else 0 end as arf
  FROM `physionet-data.mimiciv_icu.icustays` ie
  left join `physionet-data.mimiciv_derived.first_day_urine_output` uo
    on ie.stay_id = uo.stay_id
  left join `physionet-data.mimiciv_derived.first_day_lab` labs
    on ie.stay_id = labs.stay_id
  left join
  (
    select hadm_id
      , max(case
          -- severe kidney failure requiring use of dialysis
          when icd_version = 9 AND SUBSTR(icd_code, 1, 4) in ('5854','5855','5856') then 1
          when icd_version = 10 AND SUBSTR(icd_code, 1, 4) in ('N184','N185','N186') then 1
          -- we do not include 5859 as that is sometimes coded for acute-on-chronic ARF
        else 0 end)
      as ckd
    from `physionet-data.mimiciv_hosp.diagnoses_icd`
    group by hadm_id
  ) icd
    on ie.hadm_id = icd.hadm_id
)
-- first day mechanical ventilation
, vent AS
(
    SELECT ie.stay_id
    , MAX(
        CASE WHEN v.stay_id IS NOT NULL THEN 1 ELSE 0 END
    ) AS vent
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.ventilation` v
        ON ie.stay_id = v.stay_id
        AND (
            v.starttime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
        OR v.endtime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
        OR v.starttime <= ie.intime AND v.endtime >= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
        )
        AND v.ventilation_status = 'InvasiveVent'
    GROUP BY ie.stay_id
)
, cohort as
(
select ie.subject_id, ie.hadm_id, ie.stay_id
      , ie.intime
      , ie.outtime

      , vital.heart_rate_min
      , vital.heart_rate_max
      , vital.mbp_min
      , vital.mbp_max
      , vital.temperature_min
      , vital.temperature_max
      , vital.resp_rate_min
      , vital.resp_rate_max

      , pa.pao2
      , aa.aado2

      , ab.ph
      , ab.paco2
      , ab.acidbase_score

      , labs.hematocrit_min
      , labs.hematocrit_max
      , labs.wbc_min
      , labs.wbc_max
      , labs.creatinine_min
      , labs.creatinine_max
      , labs.bun_min
      , labs.bun_max
      , labs.sodium_min
      , labs.sodium_max
      , labs.albumin_min
      , labs.albumin_max
      , labs.bilirubin_total_min AS bilirubin_min
      , labs.bilirubin_total_max AS bilirubin_max

      , case
          when labs.glucose_max is null and vital.glucose_max is null
            then null
          when labs.glucose_max is null or vital.glucose_max > labs.glucose_max
            then vital.glucose_max
          when vital.glucose_max is null or labs.glucose_max > vital.glucose_max
            then labs.glucose_max
          else labs.glucose_max -- if equal, just pick labs
        end as glucose_max

      , case
          when labs.glucose_min is null and vital.glucose_min is null
            then null
          when labs.glucose_min is null or vital.glucose_min < labs.glucose_min
            then vital.glucose_min
          when vital.glucose_min is null or labs.glucose_min < vital.glucose_min
            then labs.glucose_min
          else labs.glucose_min -- if equal, just pick labs
        end as glucose_min

      -- , labs.bicarbonate_min
      -- , labs.bicarbonate_max
      , vent.vent
      , uo.urineoutput
      -- gcs and its components
      , gcs.gcs_min AS mingcs
      , gcs.gcs_motor, gcs.gcs_verbal,  gcs.gcs_eyes, gcs.gcs_unable
      -- acute renal failure
      , arf.arf as arf

FROM `physionet-data.mimiciv_icu.icustays` ie
inner join `physionet-data.mimiciv_hosp.admissions` adm
  on ie.hadm_id = adm.hadm_id
inner join `physionet-data.mimiciv_hosp.patients` pat
  on ie.subject_id = pat.subject_id

-- join to above views - the row number filters to 1 row per stay_id
left join pa
  on  ie.stay_id = pa.stay_id
  and pa.rn = 1
left join aa
  on  ie.stay_id = aa.stay_id
  and aa.rn = 1
left join acidbase_max ab
  on  ie.stay_id = ab.stay_id
  and ab.acidbase_rn = 1
left join arf
  on ie.stay_id = arf.stay_id

-- join to custom tables to get more data....
left join vent
  on ie.stay_id = vent.stay_id
left join `physionet-data.mimiciv_derived.first_day_gcs` gcs
  on ie.stay_id = gcs.stay_id
left join `physionet-data.mimiciv_derived.first_day_vitalsign` vital
  on ie.stay_id = vital.stay_id
left join `physionet-data.mimiciv_derived.first_day_urine_output` uo
  on ie.stay_id = uo.stay_id
left join `physionet-data.mimiciv_derived.first_day_lab` labs
  on ie.stay_id = labs.stay_id
)
-- First, we calculate the score for the minimum values
, score_min as
(
  select cohort.subject_id, cohort.hadm_id, cohort.stay_id
  , case
      when heart_rate_min is null then null
      when heart_rate_min <   40 then 8
      when heart_rate_min <   50 then 5
      when heart_rate_min <  100 then 0
      when heart_rate_min <  110 then 1
      when heart_rate_min <  120 then 5
      when heart_rate_min <  140 then 7
      when heart_rate_min <  155 then 13
      when heart_rate_min >= 155 then 17
    end as hr_score

  , case
      when mbp_min is null then null
      when mbp_min <   40 then 23
      when mbp_min <   60 then 15
      when mbp_min <   70 then 7
      when mbp_min <   80 then 6
      when mbp_min <  100 then 0
      when mbp_min <  120 then 4
      when mbp_min <  130 then 7
      when mbp_min <  140 then 9
      when mbp_min >= 140 then 10
    end as mbp_score

  -- TODO: add 1 degree to axillary measurements
  , case
      when temperature_min is null then null
      when temperature_min <  33.0 then 20
      when temperature_min <  33.5 then 16
      when temperature_min <  34.0 then 13
      when temperature_min <  35.0 then 8
      when temperature_min <  36.0 then 2
      when temperature_min <  40.0 then 0
      when temperature_min >= 40.0 then 4
    end as temp_score

  , case
      when resp_rate_min is null then null
      -- special case for ventilated patients
      when vent = 1 and resp_rate_min < 14 then 0
      when resp_rate_min <   6 then 17
      when resp_rate_min <  12 then 8
      when resp_rate_min <  14 then 7
      when resp_rate_min <  25 then 0
      when resp_rate_min <  35 then 6
      when resp_rate_min <  40 then 9
      when resp_rate_min <  50 then 11
      when resp_rate_min >= 50 then 18
    end as resp_rate_score

  , case
      when hematocrit_min is null then null
      when hematocrit_min <   41.0 then 3
      when hematocrit_min <   50.0 then 0
      when hematocrit_min >=  50.0 then 3
    end as hematocrit_score

  , case
      when wbc_min is null then null
      when wbc_min <   1.0 then 19
      when wbc_min <   3.0 then 5
      when wbc_min <  20.0 then 0
      when wbc_min <  25.0 then 1
      when wbc_min >= 25.0 then 5
    end as wbc_score

  , case
      when creatinine_min is null then null
      when arf = 1 and creatinine_min <  1.5 then 0
      when arf = 1 and creatinine_min >= 1.5 then 10
      when creatinine_min <   0.5 then 3
      when creatinine_min <   1.5 then 0
      when creatinine_min <  1.95 then 4
      when creatinine_min >= 1.95 then 7
    end as creatinine_score

  , case
      when bun_min is null then null
      when bun_min <  17.0 then 0
      when bun_min <  20.0 then 2
      when bun_min <  40.0 then 7
      when bun_min <  80.0 then 11
      when bun_min >= 80.0 then 12
    end as bun_score

  , case
      when sodium_min is null then null
      when sodium_min <  120 then 3
      when sodium_min <  135 then 2
      when sodium_min <  155 then 0
      when sodium_min >= 155 then 4
    end as sodium_score

  , case
      when albumin_min is null then null
      when albumin_min <  2.0 then 11
      when albumin_min <  2.5 then 6
      when albumin_min <  4.5 then 0
      when albumin_min >= 4.5 then 4
    end as albumin_score

  , case
      when bilirubin_min is null then null
      when bilirubin_min <  2.0 then 0
      when bilirubin_min <  3.0 then 5
      when bilirubin_min <  5.0 then 6
      when bilirubin_min <  8.0 then 8
      when bilirubin_min >= 8.0 then 16
    end as bilirubin_score

  , case
      when glucose_min is null then null
      when glucose_min <   40 then 8
      when glucose_min <   60 then 9
      when glucose_min <  200 then 0
      when glucose_min <  350 then 3
      when glucose_min >= 350 then 5
    end as glucose_score

from cohort
)
, score_max as
(
  select cohort.subject_id, cohort.hadm_id, cohort.stay_id
    , case
        when heart_rate_max is null then null
        when heart_rate_max <   40 then 8
        when heart_rate_max <   50 then 5
        when heart_rate_max <  100 then 0
        when heart_rate_max <  110 then 1
        when heart_rate_max <  120 then 5
        when heart_rate_max <  140 then 7
        when heart_rate_max <  155 then 13
        when heart_rate_max >= 155 then 17
      end as hr_score

    , case
        when mbp_max is null then null
        when mbp_max <   40 then 23
        when mbp_max <   60 then 15
        when mbp_max <   70 then 7
        when mbp_max <   80 then 6
        when mbp_max <  100 then 0
        when mbp_max <  120 then 4
        when mbp_max <  130 then 7
        when mbp_max <  140 then 9
        when mbp_max >= 140 then 10
      end as mbp_score

    -- TODO: add 1 degree to axillary measurements
    , case
        when temperature_max is null then null
        when temperature_max <  33.0 then 20
        when temperature_max <  33.5 then 16
        when temperature_max <  34.0 then 13
        when temperature_max <  35.0 then 8
        when temperature_max <  36.0 then 2
        when temperature_max <  40.0 then 0
        when temperature_max >= 40.0 then 4
      end as temp_score

    , case
        when resp_rate_max is null then null
        -- special case for ventilated patients
        when vent = 1 and resp_rate_max < 14 then 0
        when resp_rate_max <   6 then 17
        when resp_rate_max <  12 then 8
        when resp_rate_max <  14 then 7
        when resp_rate_max <  25 then 0
        when resp_rate_max <  35 then 6
        when resp_rate_max <  40 then 9
        when resp_rate_max <  50 then 11
        when resp_rate_max >= 50 then 18
      end as resp_rate_score

    , case
        when hematocrit_max is null then null
        when hematocrit_max <   41.0 then 3
        when hematocrit_max <   50.0 then 0
        when hematocrit_max >=  50.0 then 3
      end as hematocrit_score

    , case
        when wbc_max is null then null
        when wbc_max <   1.0 then 19
        when wbc_max <   3.0 then 5
        when wbc_max <  20.0 then 0
        when wbc_max <  25.0 then 1
        when wbc_max >= 25.0 then 5
      end as wbc_score

    , case
        when creatinine_max is null then null
        when arf = 1 and creatinine_max <  1.5 then 0
        when arf = 1 and creatinine_max >= 1.5 then 10
        when creatinine_max <   0.5 then 3
        when creatinine_max <   1.5 then 0
        when creatinine_max <  1.95 then 4
        when creatinine_max >= 1.95 then 7
      end as creatinine_score

    , case
        when bun_max is null then null
        when bun_max <  17.0 then 0
        when bun_max <  20.0 then 2
        when bun_max <  40.0 then 7
        when bun_max <  80.0 then 11
        when bun_max >= 80.0 then 12
      end as bun_score

    , case
        when sodium_max is null then null
        when sodium_max <  120 then 3
        when sodium_max <  135 then 2
        when sodium_max <  155 then 0
        when sodium_max >= 155 then 4
      end as sodium_score

    , case
        when albumin_max is null then null
        when albumin_max <  2.0 then 11
        when albumin_max <  2.5 then 6
        when albumin_max <  4.5 then 0
        when albumin_max >= 4.5 then 4
      end as albumin_score

    , case
        when bilirubin_max is null then null
        when bilirubin_max <  2.0 then 0
        when bilirubin_max <  3.0 then 5
        when bilirubin_max <  5.0 then 6
        when bilirubin_max <  8.0 then 8
        when bilirubin_max >= 8.0 then 16
      end as bilirubin_score

    , case
        when glucose_max is null then null
        when glucose_max <   40 then 8
        when glucose_max <   60 then 9
        when glucose_max <  200 then 0
        when glucose_max <  350 then 3
        when glucose_max >= 350 then 5
      end as glucose_score

from cohort
)
-- Combine together the scores for min/max, using the following rules:
--  1) select the value furthest from a predefined normal value
--  2) if both equidistant, choose the one which gives a worse score
--  3) calculate score for acid-base abnormalities as it requires interactions
-- sometimes the code is a bit redundant, i.e. we know the max would always be furthest from 0
, scorecomp as
(
  select co.*
  -- The rules for APS III require the definition of a "worst" value
  -- This value is defined as whatever value is furthest from a predefined normal
  -- e.g., for heart rate, worst is defined as furthest from 75
  , case
      when heart_rate_max is null then null
      when abs(heart_rate_max-75) > abs(heart_rate_min-75)
        then smax.hr_score
      when abs(heart_rate_max-75) < abs(heart_rate_min-75)
        then smin.hr_score
      when abs(heart_rate_max-75) = abs(heart_rate_min-75)
      and  smax.hr_score >= smin.hr_score
        then smax.hr_score
      when abs(heart_rate_max-75) = abs(heart_rate_min-75)
      and  smax.hr_score < smin.hr_score
        then smin.hr_score
    end as hr_score

  , case
      when mbp_max is null then null
      when abs(mbp_max-90) > abs(mbp_min-90)
        then smax.mbp_score
      when abs(mbp_max-90) < abs(mbp_min-90)
        then smin.mbp_score
      -- values are equidistant - pick the larger score
      when abs(mbp_max-90) = abs(mbp_min-90)
      and  smax.mbp_score >= smin.mbp_score
        then smax.mbp_score
      when abs(mbp_max-90) = abs(mbp_min-90)
      and  smax.mbp_score < smin.mbp_score
        then smin.mbp_score
    end as mbp_score

  , case
      when temperature_max is null then null
      when abs(temperature_max-38) > abs(temperature_min-38)
        then smax.temp_score
      when abs(temperature_max-38) < abs(temperature_min-38)
        then smin.temp_score
      -- values are equidistant - pick the larger score
      when abs(temperature_max-38) = abs(temperature_min-38)
      and  smax.temp_score >= smin.temp_score
        then smax.temp_score
      when abs(temperature_max-38) = abs(temperature_min-38)
      and  smax.temp_score < smin.temp_score
        then smin.temp_score
    end as temp_score

  , case
      when resp_rate_max is null then null
      when abs(resp_rate_max-19) > abs(resp_rate_min-19)
        then smax.resp_rate_score
      when abs(resp_rate_max-19) < abs(resp_rate_min-19)
        then smin.resp_rate_score
      -- values are equidistant - pick the larger score
      when abs(resp_rate_max-19) = abs(resp_rate_max-19)
      and  smax.resp_rate_score >= smin.resp_rate_score
        then smax.resp_rate_score
      when abs(resp_rate_max-19) = abs(resp_rate_max-19)
      and  smax.resp_rate_score < smin.resp_rate_score
        then smin.resp_rate_score
    end as resp_rate_score

  , case
      when hematocrit_max is null then null
      when abs(hematocrit_max-45.5) > abs(hematocrit_min-45.5)
        then smax.hematocrit_score
      when abs(hematocrit_max-45.5) < abs(hematocrit_min-45.5)
        then smin.hematocrit_score
      -- values are equidistant - pick the larger score
      when abs(hematocrit_max-45.5) = abs(hematocrit_max-45.5)
      and  smax.hematocrit_score >= smin.hematocrit_score
        then smax.hematocrit_score
      when abs(hematocrit_max-45.5) = abs(hematocrit_max-45.5)
      and  smax.hematocrit_score < smin.hematocrit_score
        then smin.hematocrit_score
    end as hematocrit_score

  , case
      when wbc_max is null then null
      when abs(wbc_max-11.5) > abs(wbc_min-11.5)
        then smax.wbc_score
      when abs(wbc_max-11.5) < abs(wbc_min-11.5)
        then smin.wbc_score
      -- values are equidistant - pick the larger score
      when abs(wbc_max-11.5) = abs(wbc_max-11.5)
      and  smax.wbc_score >= smin.wbc_score
        then smax.wbc_score
      when abs(wbc_max-11.5) = abs(wbc_max-11.5)
      and  smax.wbc_score < smin.wbc_score
        then smin.wbc_score
    end as wbc_score


  -- For some labs, "furthest from normal" doesn't make sense
  -- e.g. creatinine w/ ARF, the minimum could be 0.3, and the max 1.6
  -- while the minimum of 0.3 is "further from 1", seems like the max should be scored

  , case
      when creatinine_max is null then null
      -- if they have arf then use the max to score
      when arf = 1 then smax.creatinine_score
      -- otherwise furthest from 1
      when abs(creatinine_max-1) > abs(creatinine_min-1)
        then smax.creatinine_score
      when abs(creatinine_max-1) < abs(creatinine_min-1)
        then smin.creatinine_score
      -- values are equidistant
      when smax.creatinine_score >= smin.creatinine_score
        then smax.creatinine_score
      when smax.creatinine_score < smin.creatinine_score
        then smin.creatinine_score
    end as creatinine_score

  -- the rule for BUN is the furthest from 0.. equivalent to the max value
  , case
      when bun_max is null then null
      else smax.bun_score
    end as bun_score

  , case
      when sodium_max is null then null
      when abs(sodium_max-145.5) > abs(sodium_min-145.5)
        then smax.sodium_score
      when abs(sodium_max-145.5) < abs(sodium_min-145.5)
        then smin.sodium_score
      -- values are equidistant - pick the larger score
      when abs(sodium_max-145.5) = abs(sodium_max-145.5)
      and  smax.sodium_score >= smin.sodium_score
        then smax.sodium_score
      when abs(sodium_max-145.5) = abs(sodium_max-145.5)
      and  smax.sodium_score < smin.sodium_score
        then smin.sodium_score
    end as sodium_score

  , case
      when albumin_max is null then null
      when abs(albumin_max-3.5) > abs(albumin_min-3.5)
        then smax.albumin_score
      when abs(albumin_max-3.5) < abs(albumin_min-3.5)
        then smin.albumin_score
      -- values are equidistant - pick the larger score
      when abs(albumin_max-3.5) = abs(albumin_max-3.5)
      and  smax.albumin_score >= smin.albumin_score
        then smax.albumin_score
      when abs(albumin_max-3.5) = abs(albumin_max-3.5)
      and  smax.albumin_score < smin.albumin_score
        then smin.albumin_score
    end as albumin_score

  , case
      when bilirubin_max is null then null
      else smax.bilirubin_score
    end as bilirubin_score

  , case
      when glucose_max is null then null
      when abs(glucose_max-130) > abs(glucose_min-130)
        then smax.glucose_score
      when abs(glucose_max-130) < abs(glucose_min-130)
        then smin.glucose_score
      -- values are equidistant - pick the larger score
      when abs(glucose_max-130) = abs(glucose_max-130)
      and  smax.glucose_score >= smin.glucose_score
        then smax.glucose_score
      when abs(glucose_max-130) = abs(glucose_max-130)
      and  smax.glucose_score < smin.glucose_score
        then smin.glucose_score
    end as glucose_score


  -- Below are interactions/special cases where only 1 value is important
  , case
      when urineoutput is null then null
      when urineoutput <   400 then 15
      when urineoutput <   600 then 8
      when urineoutput <   900 then 7
      when urineoutput <  1500 then 5
      when urineoutput <  2000 then 4
      when urineoutput <  4000 then 0
      when urineoutput >= 4000 then 1
  end as uo_score

  , case
      when gcs_unable = 1
        -- here they are intubated, so their verbal score is inappropriate
        -- normally you are supposed to use "clinical judgement"
        -- we don't have that, so we just assume normal (as was done in the original study)
        then 0
      when gcs_eyes = 1
        then case
          when gcs_verbal = 1 and gcs_motor in (1,2)
            then 48
          when gcs_verbal = 1 and gcs_motor in (3,4)
            then 33
          when gcs_verbal = 1 and gcs_motor in (5,6)
            then 16
          when gcs_verbal in (2,3) and gcs_motor in (1,2)
            then 29
          when gcs_verbal in (2,3) and gcs_motor in (3,4)
            then 24
          when gcs_verbal in (2,3) and gcs_motor >= 5
            -- highly unlikely clinical combination
            then null
          when gcs_verbal >= 4
            then null
          end
      when gcs_eyes > 1
        then case
          when gcs_verbal = 1 and gcs_motor in (1,2)
            then 29
          when gcs_verbal = 1 and gcs_motor in (3,4)
            then 24
          when gcs_verbal = 1 and gcs_motor in (5,6)
            then 15
          when gcs_verbal in (2,3) and gcs_motor in (1,2)
            then 29
          when gcs_verbal in (2,3) and gcs_motor in (3,4)
            then 24
          when gcs_verbal in (2,3) and gcs_motor = 5
            then 13
          when gcs_verbal in (2,3) and gcs_motor = 6
            then 10
          when gcs_verbal = 4 and gcs_motor in (1,2,3,4)
            then 13
          when gcs_verbal = 4 and gcs_motor = 5
            then 8
          when gcs_verbal = 4 and gcs_motor = 6
            then 3
          when gcs_verbal = 5 and gcs_motor in (1,2,3,4,5)
            then 3
          when gcs_verbal = 5 and gcs_motor = 6
            then 0
          end
      else null
    end as gcs_score

  , case
      when pao2 is null and aado2 is null
        then null
      when pao2 is not null then
        case
          when pao2 < 50 then 15
          when pao2 < 70 then 5
          when pao2 < 80 then 2
        else 0 end
      when aado2 is not null then
        case
          when aado2 <  100 then 0
          when aado2 <  250 then 7
          when aado2 <  350 then 9
          when aado2 <  500 then 11
          when aado2 >= 500 then 14
        else 0 end
      end as pao2_aado2_score

from cohort co
left join score_min smin
  on co.stay_id = smin.stay_id
left join score_max smax
  on co.stay_id = smax.stay_id
)
-- tabulate the APS III using the scores from the worst values
, score as
(
  select s.*
  -- coalesce statements impute normal score of zero if data element is missing
  , coalesce(hr_score,0)
  + coalesce(mbp_score,0)
  + coalesce(temp_score,0)
  + coalesce(resp_rate_score,0)
  + coalesce(pao2_aado2_score,0)
  + coalesce(hematocrit_score,0)
  + coalesce(wbc_score,0)
  + coalesce(creatinine_score,0)
  + coalesce(uo_score,0)
  + coalesce(bun_score,0)
  + coalesce(sodium_score,0)
  + coalesce(albumin_score,0)
  + coalesce(bilirubin_score,0)
  + coalesce(glucose_score,0)
  + coalesce(acidbase_score,0)
  + coalesce(gcs_score,0)
    as apsiii
  from scorecomp s
)
select ie.subject_id, ie.hadm_id, ie.stay_id
, apsiii
-- Calculate probability of hospital mortality using equation from Johnson 2014.
, 1 / (1 + exp(- (-4.4360 + 0.04726*(apsiii) ))) as apsiii_prob
, hr_score
, mbp_score
, temp_score
, resp_rate_score
, pao2_aado2_score
, hematocrit_score
, wbc_score
, creatinine_score
, uo_score
, bun_score
, sodium_score
, albumin_score
, bilirubin_score
, glucose_score
, acidbase_score
, gcs_score
FROM `physionet-data.mimiciv_icu.icustays` ie
left join score s
  on ie.stay_id = s.stay_id
;