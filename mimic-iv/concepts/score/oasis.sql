-- ------------------------------------------------------------------
-- Title: Oxford Acute Severity of Illness Score (oasis)
-- This query extracts the Oxford acute severity of illness score.
-- This score is a measure of severity of illness for patients in the ICU.
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for OASIS:
--    Johnson, Alistair EW, Andrew A. Kramer, and Gari D. Clifford.
--    "A new severity of illness scale using a subset of acute physiology and chronic health evaluation data elements shows comparable predictive accuracy*."
--    Critical care medicine 41, no. 7 (2013): 1711-1718.

-- Variables used in OASIS:
--  Heart rate, GCS, MAP, Temperature, Respiratory rate, Ventilation status (sourced FROM `physionet-data.mimiciv_icu.chartevents`)
--  Urine output (sourced from OUTPUTEVENTS)
--  Elective surgery (sourced FROM `physionet-data.mimiciv_hosp.admissions` and SERVICES)
--  Pre-ICU in-hospital length of stay (sourced FROM `physionet-data.mimiciv_hosp.admissions` and ICUSTAYS)
--  Age (sourced FROM `physionet-data.mimiciv_hosp.patients`)

-- Regarding missing values:
--  The ventilation flag is always 0/1. It cannot be missing, since VENT=0 if no data is found for vent settings.

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption that the user will subselect appropriate stay_ids.
--  For example, the score is calculated for neonates, but it is likely inappropriate to actually use the score values for these patients.


with surgflag as
(
  select ie.stay_id
    , max(case
        when lower(curr_service) like '%surg%' then 1
        when curr_service = 'ORTHO' then 1
    else 0 end) as surgical
  FROM `physionet-data.mimiciv_icu.icustays` ie
  left join `physionet-data.mimiciv_hosp.services` se
    on ie.hadm_id = se.hadm_id
    and se.transfertime < DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  group by ie.stay_id
)
-- first day ventilation
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
      , adm.deathtime
      , DATETIME_DIFF(ie.intime, adm.admittime, MINUTE) as preiculos
      , ag.age
      , gcs.gcs_min
      , vital.heart_rate_max
      , vital.heart_rate_min
      , vital.mbp_max
      , vital.mbp_min
      , vital.resp_rate_max
      , vital.resp_rate_min
      , vital.temperature_max
      , vital.temperature_min
      , vent.vent as mechvent
      , uo.urineoutput

      , case
          when adm.ADMISSION_TYPE = 'ELECTIVE' and sf.surgical = 1
            then 1
          when adm.ADMISSION_TYPE is null or sf.surgical is null
            then null
          else 0
        end as electivesurgery

      -- mortality flags
      , case
          when adm.deathtime between ie.intime and ie.outtime
            then 1
          when adm.deathtime <= ie.intime -- sometimes there are typographical errors in the death date
            then 1
          when adm.dischtime <= ie.outtime and adm.discharge_location = 'DEAD/EXPIRED'
            then 1
          else 0 end
        as icustay_expire_flag
      , adm.hospital_expire_flag
FROM `physionet-data.mimiciv_icu.icustays` ie
inner join `physionet-data.mimiciv_hosp.admissions` adm
  on ie.hadm_id = adm.hadm_id
inner join `physionet-data.mimiciv_hosp.patients` pat
  on ie.subject_id = pat.subject_id
LEFT JOIN `physionet-data.mimiciv_derived.age` ag
  ON ie.hadm_id = ag.hadm_id
left join surgflag sf
  on ie.stay_id = sf.stay_id
-- join to custom tables to get more data....
left join `physionet-data.mimiciv_derived.first_day_gcs` gcs
  on ie.stay_id = gcs.stay_id
left join `physionet-data.mimiciv_derived.first_day_vitalsign` vital
  on ie.stay_id = vital.stay_id
left join `physionet-data.mimiciv_derived.first_day_urine_output` uo
  on ie.stay_id = uo.stay_id
left join vent
  on ie.stay_id = vent.stay_id
)
, scorecomp as
(
select co.subject_id, co.hadm_id, co.stay_id
, co.icustay_expire_flag
, co.hospital_expire_flag

-- Below code calculates the component scores needed for oasis
, case when preiculos is null then null
     when preiculos < 10.2 then 5
     when preiculos < 297 then 3
     when preiculos < 1440 then 0
     when preiculos < 18708 then 1
     else 2 end as preiculos_score
,  case when age is null then null
      when age < 24 then 0
      when age <= 53 then 3
      when age <= 77 then 6
      when age <= 89 then 9
      when age >= 90 then 7
      else 0 end as age_score
,  case when gcs_min is null then null
      when gcs_min <= 7 then 10
      when gcs_min < 14 then 4
      when gcs_min = 14 then 3
      else 0 end as gcs_score
,  case when heart_rate_max is null then null
      when heart_rate_max > 125 then 6
      when heart_rate_min < 33 then 4
      when heart_rate_max >= 107 and heart_rate_max <= 125 then 3
      when heart_rate_max >= 89 and heart_rate_max <= 106 then 1
      else 0 end as heart_rate_score
,  case when mbp_min is null then null
      when mbp_min < 20.65 then 4
      when mbp_min < 51 then 3
      when mbp_max > 143.44 then 3
      when mbp_min >= 51 and mbp_min < 61.33 then 2
      else 0 end as mbp_score
,  case when resp_rate_min is null then null
      when resp_rate_min <   6 then 10
      when resp_rate_max >  44 then  9
      when resp_rate_max >  30 then  6
      when resp_rate_max >  22 then  1
      when resp_rate_min <  13 then 1 else 0
      end as resp_rate_score
,  case when temperature_max is null then null
      when temperature_max > 39.88 then 6
      when temperature_min >= 33.22 and temperature_min <= 35.93 then 4
      when temperature_max >= 33.22 and temperature_max <= 35.93 then 4
      when temperature_min < 33.22 then 3
      when temperature_min > 35.93 and temperature_min <= 36.39 then 2
      when temperature_max >= 36.89 and temperature_max <= 39.88 then 2
      else 0 end as temp_score
,  case when UrineOutput is null then null
      when UrineOutput < 671.09 then 10
      when UrineOutput > 6896.80 then 8
      when UrineOutput >= 671.09
       and UrineOutput <= 1426.99 then 5
      when UrineOutput >= 1427.00
       and UrineOutput <= 2544.14 then 1
      else 0 end as urineoutput_score
,  case when mechvent is null then null
      when mechvent = 1 then 9
      else 0 end as mechvent_score
,  case when electivesurgery is null then null
      when electivesurgery = 1 then 0
      else 6 end as electivesurgery_score


-- The below code gives the component associated with each score
-- This is not needed to calculate oasis, but provided for user convenience.
-- If both the min/max are in the normal range (score of 0), then the average value is stored.
, preiculos
, age
, gcs_min as gcs
,  case when heart_rate_max is null then null
      when heart_rate_max > 125 then heart_rate_max
      when heart_rate_min < 33 then heart_rate_min
      when heart_rate_max >= 107 and heart_rate_max <= 125 then heart_rate_max
      when heart_rate_max >= 89 and heart_rate_max <= 106 then heart_rate_max
      else (heart_rate_min+heart_rate_max)/2 end as heartrate
,  case when mbp_min is null then null
      when mbp_min < 20.65 then mbp_min
      when mbp_min < 51 then mbp_min
      when mbp_max > 143.44 then mbp_max
      when mbp_min >= 51 and mbp_min < 61.33 then mbp_min
      else (mbp_min+mbp_max)/2 end as meanbp
,  case when resp_rate_min is null then null
      when resp_rate_min <   6 then resp_rate_min
      when resp_rate_max >  44 then resp_rate_max
      when resp_rate_max >  30 then resp_rate_max
      when resp_rate_max >  22 then resp_rate_max
      when resp_rate_min <  13 then resp_rate_min
      else (resp_rate_min+resp_rate_max)/2 end as resprate
,  case when temperature_max is null then null
      when temperature_max > 39.88 then temperature_max
      when temperature_min >= 33.22 and temperature_min <= 35.93 then temperature_min
      when temperature_max >= 33.22 and temperature_max <= 35.93 then temperature_max
      when temperature_min < 33.22 then temperature_min
      when temperature_min > 35.93 and temperature_min <= 36.39 then temperature_min
      when temperature_max >= 36.89 and temperature_max <= 39.88 then temperature_max
      else (temperature_min+temperature_max)/2 end as temp
,  UrineOutput
,  mechvent
,  electivesurgery
from cohort co
)
, score as
(
select s.*
    , coalesce(age_score,0)
    + coalesce(preiculos_score,0)
    + coalesce(gcs_score,0)
    + coalesce(heart_rate_score,0)
    + coalesce(mbp_score,0)
    + coalesce(resp_rate_score,0)
    + coalesce(temp_score,0)
    + coalesce(urineoutput_score,0)
    + coalesce(mechvent_score,0)
    + coalesce(electivesurgery_score,0)
    as oasis
from scorecomp s
)
select
  subject_id, hadm_id, stay_id
  , oasis
  -- Calculate the probability of in-hospital mortality
  , 1 / (1 + exp(- (-6.1746 + 0.1275*(oasis) ))) as oasis_prob
  , age, age_score
  , preiculos, preiculos_score
  , gcs, gcs_score
  , heartrate, heart_rate_score
  , meanbp, mbp_score
  , resprate, resp_rate_score
  , temp, temp_score
  , urineoutput, urineoutput_score
  , mechvent, mechvent_score
  , electivesurgery, electivesurgery_score
from score
;