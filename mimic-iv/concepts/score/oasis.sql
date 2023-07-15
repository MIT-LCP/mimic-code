-- ------------------------------------------------------------------
-- Title: Oxford Acute Severity of Illness Score (oasis)
-- This query extracts the Oxford acute severity of illness score.
-- This score is a measure of severity of illness for patients in the ICU.
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for OASIS:
--    Johnson, Alistair EW, Andrew A. Kramer, and Gari D. Clifford.
--    A new severity of illness scale using a subset of acute physiology
--    and chronic health evaluation data elements shows comparable
--    predictive accuracy*.
--    Critical care medicine 41, no. 7 (2013): 1711-1718.

-- Variables used in OASIS:
--  Heart rate, GCS, MAP, Temperature, Respiratory rate, Ventilation status
--      (from chartevents)
--  Urine output (from outputevents)
--  Elective surgery (from admissions and services)
--  Pre-ICU in-hospital length of stay (from admissions and icustays)
--  Age (from patients)

-- Regarding missing values:
--  The ventilation flag is always 0/1. It cannot be missing,
--  since VENT=0 if no data is found for vent settings.

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption
--  that the user will subselect appropriate stay_ids.


WITH surgflag AS (
    SELECT ie.stay_id
        , MAX(CASE
            WHEN LOWER(curr_service) LIKE '%surg%' THEN 1
            WHEN curr_service = 'ORTHO' THEN 1
            ELSE 0 END) AS surgical
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_hosp.services` se
        ON ie.hadm_id = se.hadm_id
            AND se.transfertime < DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    GROUP BY ie.stay_id
)

-- first day ventilation
, vent AS (
    SELECT ie.stay_id
        , MAX(
            CASE WHEN v.stay_id IS NOT NULL THEN 1 ELSE 0 END
        ) AS vent
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.ventilation` v
        ON ie.stay_id = v.stay_id
            AND v.ventilation_status = 'InvasiveVent'
            AND (
                (
                    v.starttime >= ie.intime
                    AND v.starttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
                )
                OR (
                    v.endtime >= ie.intime
                    AND v.endtime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
                )
                OR (
                    v.starttime <= ie.intime
                    AND v.endtime >= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
                )
            )
    GROUP BY ie.stay_id
)

, cohort AS (
    SELECT ie.subject_id, ie.hadm_id, ie.stay_id
        , ie.intime
        , ie.outtime
        , adm.deathtime
        , DATETIME_DIFF(ie.intime, adm.admittime, MINUTE) AS preiculos
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
        , vent.vent AS mechvent
        , uo.urineoutput

        , CASE
            WHEN adm.admission_type = 'ELECTIVE' AND sf.surgical = 1
                THEN 1
            WHEN adm.admission_type IS NULL OR sf.surgical IS NULL
                THEN null
            ELSE 0
        END AS electivesurgery

        -- mortality flags
        , CASE
            WHEN adm.deathtime BETWEEN ie.intime AND ie.outtime
                THEN 1
            -- sometimes there are typographical errors in the death date
            WHEN adm.deathtime <= ie.intime
                THEN 1
            WHEN adm.dischtime <= ie.outtime
                AND adm.discharge_location = 'DEAD/EXPIRED'
                THEN 1
            ELSE 0 END
        AS icustay_expire_flag
        , adm.hospital_expire_flag
    FROM `physionet-data.mimiciv_icu.icustays` ie
    INNER JOIN `physionet-data.mimiciv_hosp.admissions` adm
        ON ie.hadm_id = adm.hadm_id
    INNER JOIN `physionet-data.mimiciv_hosp.patients` pat
        ON ie.subject_id = pat.subject_id
    LEFT JOIN `physionet-data.mimiciv_derived.age` ag
        ON ie.hadm_id = ag.hadm_id
    LEFT JOIN surgflag sf
        ON ie.stay_id = sf.stay_id
    -- join to custom tables to get more data....
    LEFT JOIN `physionet-data.mimiciv_derived.first_day_gcs` gcs
        ON ie.stay_id = gcs.stay_id
    LEFT JOIN `physionet-data.mimiciv_derived.first_day_vitalsign` vital
        ON ie.stay_id = vital.stay_id
    LEFT JOIN `physionet-data.mimiciv_derived.first_day_urine_output` uo
        ON ie.stay_id = uo.stay_id
    LEFT JOIN vent
        ON ie.stay_id = vent.stay_id
)

, scorecomp AS (
    SELECT co.subject_id, co.hadm_id, co.stay_id
        , co.icustay_expire_flag
        , co.hospital_expire_flag

        -- Below code calculates the component scores needed for oasis
        , CASE WHEN preiculos IS NULL THEN null
            WHEN preiculos < 10.2 THEN 5
            WHEN preiculos < 297 THEN 3
            WHEN preiculos < 1440 THEN 0
            WHEN preiculos < 18708 THEN 2
            ELSE 1 END AS preiculos_score
        , CASE WHEN age IS NULL THEN null
            WHEN age < 24 THEN 0
            WHEN age <= 53 THEN 3
            WHEN age <= 77 THEN 6
            WHEN age <= 89 THEN 9
            WHEN age >= 90 THEN 7
            ELSE 0 END AS age_score
        , CASE WHEN gcs_min IS NULL THEN null
            WHEN gcs_min <= 7 THEN 10
            WHEN gcs_min < 14 THEN 4
            WHEN gcs_min = 14 THEN 3
            ELSE 0 END AS gcs_score
        , CASE WHEN heart_rate_max IS NULL THEN null
            WHEN heart_rate_max > 125 THEN 6
            WHEN heart_rate_min < 33 THEN 4
            WHEN heart_rate_max >= 107 AND heart_rate_max <= 125 THEN 3
            WHEN heart_rate_max >= 89 AND heart_rate_max <= 106 THEN 1
            ELSE 0 END AS heart_rate_score
        , CASE WHEN mbp_min IS NULL THEN null
            WHEN mbp_min < 20.65 THEN 4
            WHEN mbp_min < 51 THEN 3
            WHEN mbp_max > 143.44 THEN 3
            WHEN mbp_min >= 51 AND mbp_min < 61.33 THEN 2
            ELSE 0 END AS mbp_score
        , CASE WHEN resp_rate_min IS NULL THEN null
            WHEN resp_rate_min < 6 THEN 10
            WHEN resp_rate_max > 44 THEN 9
            WHEN resp_rate_max > 30 THEN 6
            WHEN resp_rate_max > 22 THEN 1
            WHEN resp_rate_min < 13 THEN 1 ELSE 0
        END AS resp_rate_score
        , CASE WHEN temperature_max IS NULL THEN null
            WHEN temperature_max > 39.88 THEN 6
            WHEN
                temperature_min >= 33.22 AND temperature_min <= 35.93 THEN 4
            WHEN
                temperature_max >= 33.22 AND temperature_max <= 35.93 THEN 4
            WHEN temperature_min < 33.22 THEN 3
            WHEN temperature_min > 35.93 AND temperature_min <= 36.39 THEN 2
            WHEN
                temperature_max >= 36.89 AND temperature_max <= 39.88 THEN 2
            ELSE 0 END AS temp_score
        , CASE WHEN urineoutput IS NULL THEN null
            WHEN urineoutput < 671.09 THEN 10
            WHEN urineoutput > 6896.80 THEN 8
            WHEN urineoutput >= 671.09
                AND urineoutput <= 1426.99 THEN 5
            WHEN urineoutput >= 1427.00
                AND urineoutput <= 2544.14 THEN 1
            ELSE 0 END AS urineoutput_score
        , CASE WHEN mechvent IS NULL THEN null
            WHEN mechvent = 1 THEN 9
            ELSE 0 END AS mechvent_score
        , CASE WHEN electivesurgery IS NULL THEN null
            WHEN electivesurgery = 1 THEN 0
            ELSE 6 END AS electivesurgery_score


        -- The below code gives the component associated with each score
        -- This is not needed to calculate oasis, but provided for
        -- user convenience. If both the min/max are in the normal range
        -- (score of 0), then the average value is stored.
        , preiculos
        , age
        , gcs_min AS gcs
        , CASE WHEN heart_rate_max IS NULL THEN null
            WHEN heart_rate_max > 125 THEN heart_rate_max
            WHEN heart_rate_min < 33 THEN heart_rate_min
            WHEN heart_rate_max >= 107
                AND heart_rate_max <= 125
                THEN heart_rate_max
            WHEN heart_rate_max >= 89
                AND heart_rate_max <= 106
                THEN heart_rate_max
            ELSE (heart_rate_min + heart_rate_max) / 2 END AS heartrate
        , CASE WHEN mbp_min IS NULL THEN null
            WHEN mbp_min < 20.65 THEN mbp_min
            WHEN mbp_min < 51 THEN mbp_min
            WHEN mbp_max > 143.44 THEN mbp_max
            WHEN mbp_min >= 51 AND mbp_min < 61.33 THEN mbp_min
            ELSE (mbp_min + mbp_max) / 2 END AS meanbp
        , CASE WHEN resp_rate_min IS NULL THEN null
            WHEN resp_rate_min < 6 THEN resp_rate_min
            WHEN resp_rate_max > 44 THEN resp_rate_max
            WHEN resp_rate_max > 30 THEN resp_rate_max
            WHEN resp_rate_max > 22 THEN resp_rate_max
            WHEN resp_rate_min < 13 THEN resp_rate_min
            ELSE (resp_rate_min + resp_rate_max) / 2 END AS resprate
        , CASE WHEN temperature_max IS NULL THEN null
            WHEN temperature_max > 39.88 THEN temperature_max
            WHEN temperature_min >= 33.22
                AND temperature_min <= 35.93
                THEN temperature_min
            WHEN temperature_max >= 33.22
                AND temperature_max <= 35.93
                THEN temperature_max
            WHEN temperature_min < 33.22
                THEN temperature_min
            WHEN temperature_min > 35.93
                AND temperature_min <= 36.39
                THEN temperature_min
            WHEN temperature_max >= 36.89
                AND temperature_max <= 39.88
                THEN temperature_max
            ELSE (temperature_min + temperature_max) / 2 END AS temp
        , urineoutput
        , mechvent
        , electivesurgery
    FROM cohort co
)

, score AS (
    SELECT s.*
        , COALESCE(age_score, 0)
        + COALESCE(preiculos_score, 0)
        + COALESCE(gcs_score, 0)
        + COALESCE(heart_rate_score, 0)
        + COALESCE(mbp_score, 0)
        + COALESCE(resp_rate_score, 0)
        + COALESCE(temp_score, 0)
        + COALESCE(urineoutput_score, 0)
        + COALESCE(mechvent_score, 0)
        + COALESCE(electivesurgery_score, 0)
        AS oasis
    FROM scorecomp s
)

SELECT
    subject_id, hadm_id, stay_id
    , oasis
    -- Calculate the probability of in-hospital mortality
    , 1 / (1 + EXP(- (-6.1746 + 0.1275 * (oasis)))) AS oasis_prob
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
FROM score
;
