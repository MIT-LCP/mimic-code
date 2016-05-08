-- ------------------------------------------------------------------
-- Title: Detailed information on ICUSTAY_ID
-- Description: This query provides a useful set of information regarding patient
--			ICU stays. The information is combined from the admissions, patients, and
--			icustays tables. It includes age, length of stay, sequence, and expiry flags.
-- MIMIC version: MIMIC-III v1.4
-- ------------------------------------------------------------------

-- (Optional) Define which schema to work on
-- SET search_path TO mimiciii;

-- This query extracts useful demographic/administrative information for patient ICU stays
DROP MATERIALIZED VIEW IF EXISTS icustay_detail;
CREATE MATERIALIZED VIEW icustay_detail as

select ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient level factors
, pat.gender

-- hospital level factors
, adm.admittime, adm.dischtime
, round( (cast(adm.dischtime as date) - cast(adm.admittime as date)) , 4) as LOS_HOSPITAL
, round( (cast(adm.admittime as date) - cast(pat.dob as date))  / 365.242, 4) as Age
, adm.ethnicity, adm.ADMISSION_TYPE
, adm.hospital_expire_flag

, dense_rank() over (partition by adm.subject_id order by adm.admittime) as hospstay_seq
, case
    when dense_rank() over (partition by adm.subject_id order by adm.admittime) = 1 then 'Y'
    else 'N'
  end as first_hosp_stay

-- icu level factors
, ie.intime, ie.outtime
, round( (cast(ie.outtime as date) - cast(ie.intime as date)) , 4) as LOS_ICU
, dense_rank() over (partition by ie.hadm_id order by ie.intime) as icustay_seq
-- first ICU stay *for the current hospitalization*
, case
    when dense_rank() over (partition by ie.hadm_id order by ie.intime) = 1 then 'Y'
    else 'N'
  end as first_icu_stay

from icustays ie
inner join admissions adm
 on ie.hadm_id = adm.hadm_id
inner join patients pat
 on ie.subject_id = pat.subject_id
where adm.has_chartevents_data = 1
order by ie.subject_id, adm.admittime, ie.intime;
