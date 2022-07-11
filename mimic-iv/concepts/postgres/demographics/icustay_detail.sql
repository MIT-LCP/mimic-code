-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS icustay_detail; CREATE TABLE icustay_detail AS 
SELECT ie.subject_id, ie.hadm_id, ie.stay_id

-- patient level factors
, pat.gender, pat.dod

-- hospital level factors
, adm.admittime, adm.dischtime
, DATETIME_DIFF(adm.dischtime, adm.admittime, 'DAY') as los_hospital
, DATETIME_DIFF(adm.admittime, DATETIME(pat.anchor_year, 1, 1, 0, 0, 0), YEAR) + pat.anchor_age as admission_age
, adm.race
, adm.hospital_expire_flag
, DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) AS hospstay_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) = 1 THEN True
    ELSE False END AS first_hosp_stay

-- icu level factors
, ie.intime as icu_intime, ie.outtime as icu_outtime
, ROUND( CAST( DATETIME_DIFF(ie.outtime as numeric),ie.intime, 'HOUR')/24.0, 2) as los_icu
, DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) AS icustay_seq

-- first ICU stay *for the current hospitalization*
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) = 1 THEN True
    ELSE False END AS first_icu_stay

FROM mimiciv_icu.icustays ie
INNER JOIN mimiciv_hosp.admissions adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN mimiciv_hosp.patients pat
    ON ie.subject_id = pat.subject_id
