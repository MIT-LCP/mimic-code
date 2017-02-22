-- ------------------------------------------------------------------
-- Title: Detailed information on ICUSTAY_ID
-- Description: This query provides a useful set of information regarding patient
--			ICU stays. The information is combined from the admissions, patients, and
--			icustays tables. It includes age, length of stay, sequence, and expiry flags.
-- MIMIC version: MIMIC-III v1.3
-- ------------------------------------------------------------------

-- (Optional) Define which schema to work on
-- SET search_path TO mimiciii;

-- This query extracts useful demographic/administrative information for patient ICU stays
DROP MATERIALIZED VIEW IF EXISTS icustay_detail CASCADE;
CREATE MATERIALIZED VIEW icustay_detail as

SELECT ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient level factors
, pat.gender

-- hospital level factors
, adm.admittime, adm.dischtime
, ROUND( (CAST(EXTRACT(epoch FROM adm.dischtime - adm.admittime)/(60*60*24) AS numeric)), 4) AS los_hospital
, ROUND( (CAST(EXTRACT(epoch FROM adm.admittime - pat.dob)/(60*60*24*365.242) AS numeric)), 4) AS age
, adm.ethnicity, adm.ADMISSION_TYPE
, adm.hospital_expire_flag
, DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) AS hospstay_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) = 1 THEN 'Y'
    ELSE 'N' END AS first_hosp_stay

-- icu level factors
, ie.intime, ie.outtime
, ROUND( (CAST(EXTRACT(epoch FROM ie.outtime - ie.intime)/(60*60*24) AS numeric)), 4) AS los_icu
, DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) AS icustay_seq

-- first ICU stay *for the current hospitalization*
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) = 1 THEN 'Y'
    ELSE 'N' END AS first_icu_stay

FROM icustays ie
INNER JOIN admissions adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN patients pat
    ON ie.subject_id = pat.subject_id
WHERE adm.has_chartevents_data = 1
ORDER BY ie.subject_id, adm.admittime, ie.intime;
