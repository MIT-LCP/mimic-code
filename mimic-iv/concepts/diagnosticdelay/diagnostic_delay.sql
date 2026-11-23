-- ------------------------------------------------------------------
-- Title: Diagnostic-delay measures for the suspected-sepsis cohort.
-- Description: One row per ICU stay in suspected_sepsis_cohort with the
--   delay (in hours) between hospital/ICU admission and the first
--   recognized sign of infection (suspected-infection time, first
--   antibiotic, first culture). An onset window classifies each stay as
--   pre_admission, present_on_admission (within 48 hours of admission),
--   or hospital_onset (after 48 hours). Plausibility flags mark stays
--   whose timestamps are out of order or missing so they can be
--   investigated rather than silently averaged in.
-- Note: ICD codes in MIMIC carry no timestamp, so "diagnosis time" is
--   proxied here by the clinically observable recognition events
--   (antibiotic order, culture draw) used in the Sepsis-3 definition.
-- Reference: https://github.com/MIT-LCP/mimic-code/issues/1843
-- ------------------------------------------------------------------

WITH dd AS (
    SELECT
        c.subject_id
        , c.hadm_id
        , c.stay_id
        , c.admittime
        , c.dischtime
        , c.icu_intime
        , c.icu_outtime
        , c.n_suspicion_episodes
        , c.first_suspicion_time
        , c.first_antibiotic_time
        , c.first_culture_time
        -- delay measures, in hours (1 decimal)
        , ROUND(
            DATETIME_DIFF(c.first_suspicion_time, c.admittime, MINUTE) / 60.0
            , 1
        ) AS admission_to_suspicion_hours
        , ROUND(
            DATETIME_DIFF(c.first_suspicion_time, c.icu_intime, MINUTE) / 60.0
            , 1
        ) AS icu_to_suspicion_hours
        , ROUND(
            DATETIME_DIFF(c.first_antibiotic_time, c.admittime, MINUTE) / 60.0
            , 1
        ) AS admission_to_antibiotic_hours
        , ROUND(
            DATETIME_DIFF(c.first_culture_time, c.admittime, MINUTE) / 60.0
            , 1
        ) AS admission_to_culture_hours
        , ROUND(
            DATETIME_DIFF(
                c.first_antibiotic_time, c.first_culture_time, MINUTE
            ) / 60.0
            , 1
        ) AS culture_to_antibiotic_hours
    FROM `physionet-data.mimiciv_derived.suspected_sepsis_cohort` c
)

SELECT
    dd.subject_id
    , dd.hadm_id
    , dd.stay_id
    , dd.admittime
    , dd.dischtime
    , dd.icu_intime
    , dd.icu_outtime
    , dd.n_suspicion_episodes
    , dd.first_suspicion_time
    , dd.first_antibiotic_time
    , dd.first_culture_time
    , dd.admission_to_suspicion_hours
    , dd.icu_to_suspicion_hours
    , dd.admission_to_antibiotic_hours
    , dd.admission_to_culture_hours
    , dd.culture_to_antibiotic_hours
    -- onset window relative to hospital admission. Classified from the raw
    -- timestamps rather than the rounded delay measures above: e.g. a
    -- suspicion 2 minutes before admission rounds to a delay of -0.0 (not
    -- < 0) and a suspicion 48 hours 2 minutes after admission rounds to
    -- 48.0 (not > 48), both of which the rounded form misclassified.
    , CASE
        WHEN dd.first_suspicion_time < dd.admittime THEN 'pre_admission'
        WHEN dd.first_suspicion_time <= DATETIME_ADD(
            dd.admittime, INTERVAL 48 HOUR
        ) THEN 'present_on_admission'
        ELSE 'hospital_onset'
    END AS onset_window
    -- temporal-plausibility flags (1 = implausible, 0 = plausible,
    -- NULL = cannot be assessed because an anchor is missing)
    , CASE
        WHEN dd.first_suspicion_time < dd.admittime THEN 1
        ELSE 0
    END AS flag_suspicion_before_admission
    , CASE
        WHEN dd.icu_outtime IS NULL THEN NULL
        WHEN dd.first_suspicion_time > dd.icu_outtime THEN 1
        ELSE 0
    END AS flag_suspicion_after_icu_outtime
    , CASE
        WHEN dd.dischtime IS NULL THEN NULL
        WHEN dd.first_suspicion_time > dd.dischtime THEN 1
        ELSE 0
    END AS flag_suspicion_after_discharge
    , CASE
        WHEN dd.first_culture_time IS NULL THEN 1
        ELSE 0
    END AS flag_missing_culture_time
    , CASE
        WHEN dd.first_antibiotic_time IS NULL THEN 1
        ELSE 0
    END AS flag_missing_antibiotic_time
FROM dd
;
