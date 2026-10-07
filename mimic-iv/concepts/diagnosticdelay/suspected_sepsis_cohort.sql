-- ------------------------------------------------------------------
-- Title: Suspected-sepsis ICU cohort for diagnostic-delay measurement.
-- Description: One row per ICU stay for adult patients admitted through
--   the emergency department who have at least one suspected-infection
--   episode (an antibiotic paired with a microbiology culture, per the
--   suspicion_of_infection concept). Anchor timestamps and basic
--   demographics are carried along so that downstream queries can
--   measure the delay between hospital/ICU admission and the moment the
--   infection was first recognized (first antibiotic or culture).
-- Reference: community questions on diagnosis timing in MIMIC, e.g.
--   https://github.com/MIT-LCP/mimic-code/issues/1843
-- ------------------------------------------------------------------

WITH soi AS (
    SELECT
        soi.stay_id
        , COUNT(*) AS n_suspicion_episodes
        , MIN(soi.suspected_infection_time) AS first_suspicion_time
        , MIN(soi.antibiotic_time) AS first_antibiotic_time
        , MIN(soi.culture_time) AS first_culture_time
    FROM `physionet-data.mimiciv_derived.suspicion_of_infection` soi
    WHERE soi.suspected_infection = 1
    GROUP BY soi.stay_id
)

SELECT
    ie.subject_id
    , ie.hadm_id
    , ie.stay_id

    -- patient level factors
    , pat.gender
    -- calculate the age as anchor_age plus the difference between
    -- the admit year and the anchor year (same formula as age.sql)
    , pat.anchor_age + DATETIME_DIFF(
        adm.admittime, DATETIME(pat.anchor_year, 1, 1, 0, 0, 0), YEAR
    ) AS admission_age
    , adm.race

    -- hospital level factors
    , adm.admittime
    , adm.dischtime
    , adm.admission_type
    , adm.admission_location
    , adm.hospital_expire_flag
    , DENSE_RANK() OVER (
        PARTITION BY adm.subject_id ORDER BY adm.admittime
    ) AS hospstay_seq

    -- icu level factors
    , ie.intime AS icu_intime
    , ie.outtime AS icu_outtime
    , DENSE_RANK() OVER (
        PARTITION BY ie.hadm_id ORDER BY ie.intime
    ) AS icustay_seq

    -- suspected-infection summary (one row per antibiotic in soi)
    , soi.n_suspicion_episodes
    , soi.first_suspicion_time
    , soi.first_antibiotic_time
    , soi.first_culture_time
FROM `physionet-data.mimiciv_icu.icustays` ie
INNER JOIN `physionet-data.mimiciv_hosp.admissions` adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN `physionet-data.mimiciv_hosp.patients` pat
    ON ie.subject_id = pat.subject_id
-- inner join: only stays with at least one suspected-infection episode
INNER JOIN soi
    ON ie.stay_id = soi.stay_id
-- adults only; ED origin only
WHERE pat.anchor_age + DATETIME_DIFF(
        adm.admittime, DATETIME(pat.anchor_year, 1, 1, 0, 0, 0), YEAR
    ) >= 18
    AND adm.admission_location = 'EMERGENCY ROOM'
;
