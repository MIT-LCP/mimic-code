SELECT ie.subject_id, ie.hadm_id, ie.stay_id

    -- patient level factors
    , pat.gender, pat.dod

    -- hospital level factors
    , adm.admittime, adm.dischtime
    , DATETIME_DIFF(adm.dischtime, adm.admittime, DAY) AS los_hospital
    -- calculate the age as anchor_age (60) plus difference between
    -- admit year and the anchor year.
    -- the noqa retains the extra long line so the 
    -- convert to postgres bash script works
    , pat.anchor_age + DATETIME_DIFF(adm.admittime, DATETIME(pat.anchor_year, 1, 1, 0, 0, 0), YEAR) AS admission_age -- noqa: L016
    , adm.race
    , adm.hospital_expire_flag
    , DENSE_RANK() OVER (
        PARTITION BY adm.subject_id ORDER BY adm.admittime
    ) AS hospstay_seq
    , CASE
        WHEN
            DENSE_RANK() OVER (
                PARTITION BY adm.subject_id ORDER BY adm.admittime
            ) = 1 THEN True
        ELSE False END AS first_hosp_stay

    -- icu level factors
    , ie.intime AS icu_intime, ie.outtime AS icu_outtime
    , ROUND(
        CAST(DATETIME_DIFF(ie.outtime, ie.intime, HOUR) / 24.0 AS NUMERIC), 2
    ) AS los_icu
    , DENSE_RANK() OVER (
        PARTITION BY ie.hadm_id ORDER BY ie.intime
    ) AS icustay_seq

    -- first ICU stay *for the current hospitalization*
    , CASE
        WHEN
            DENSE_RANK() OVER (
                PARTITION BY ie.hadm_id ORDER BY ie.intime
            ) = 1 THEN True
        ELSE False END AS first_icu_stay

FROM `physionet-data.mimiciv_icu.icustays` ie
INNER JOIN `physionet-data.mimiciv_hosp.admissions` adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN `physionet-data.mimiciv_hosp.patients` pat
    ON ie.subject_id = pat.subject_id
