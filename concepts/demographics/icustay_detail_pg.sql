-- This code is wriiten in Postgres SQL syntax

SELECT ie.subject_id, ie.hadm_id, ie.stay_id

-- patient level factors
, pat.gender, pat.dod

-- hospital level factors
, adm.admittime, adm.dischtime
, EXTRACT(epoch FROM adm.dischtime - adm.admittime)/3600/24 as los_hospital
, EXTRACT(year FROM adm.admittime) - pat.anchor_year + pat.anchor_age as admission_age
, adm.ethnicity
, adm.hospital_expire_flag
, DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) AS hospstay_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) = 1 THEN True
    ELSE False END AS first_hosp_stay

-- icu level factors
, ie.intime as icu_intime, ie.outtime as icu_outtime
, extract (epoch from ie.outtime - ie.intime)/3600/24 as los_icu
, DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) AS icustay_seq

-- first ICU stay *for the current hospitalization*
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) = 1 THEN True
    ELSE False END AS first_icu_stay

FROM mimic_icu.icustays ie
INNER JOIN mimic_core.admissions adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN mimic_core.patients pat
    ON ie.subject_id = pat.subject_id
ORDER BY ie.subject_id, adm.admittime, ie.intime
