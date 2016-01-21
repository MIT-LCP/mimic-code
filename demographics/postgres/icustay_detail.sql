-- ------------------------------------------------------------------
-- Title: Detailed information on ICUSTAY_ID
-- Description: This query provides a useful set of information regarding patient
--			ICU stays. The information is combined from the admissions, patients, and
--			icustays tables. It includes age, length of stay, sequence, and expiry flags.
-- MIMIC version: MIMIC-III v1.2
-- Created by: Erin Hong, Alistair Johnson
-- Editted by: Marzyeh Ghassemi
-- ------------------------------------------------------------------

-- Define which schema to work on
SET search_path TO mimiciii;

-- This query extracts useful demographic/administrative information for patient ICU stays
with adm as (
select ad.subject_id, ad.hadm_id, 
ad.ethnicity, ad.ADMISSION_TYPE, ad.admittime, ad.dischtime,
case 
  when ad.deathtime is not null then 'Y' 
  else 'N' 
end
as hospital_expire_flag,
row_number() over (partition by ad.subject_id order by ad.admittime) as hospstay_seq,
case 
  when row_number() over (partition by ad.subject_id order by ad.admittime) = 1 then 'Y' 
  else 'N' 
end
as first_hosp_stay

from admissions ad
where ad.has_chartevents_data = 1
)
,
co as (
select ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient level factors
, pat.gender
, adm.ethnicity, adm.ADMISSION_TYPE, adm.admittime, adm.dischtime, adm.hospital_expire_flag, adm.first_hosp_stay, adm.hospstay_seq
  
-- icu level factors
, ie.intime, ie.outtime
, round((EXTRACT(EPOCH FROM (ie.intime-pat.dob)) / 60 / 60 / 24 / 365.242) :: NUMERIC, 4) as Age
, round((EXTRACT(EPOCH FROM (ie.outtime - ie.intime)) / 60 / 60 / 24) :: NUMERIC, 4) as LOS_ICU
, row_number() over (partition by ie.subject_id, ie.hadm_id order by ie.intime) as icustay_seq

from icustays ie
inner join adm
 on ie.hadm_id = adm.hadm_id
inner join patients pat
 on ie.subject_id = pat.subject_id
)
select co.*
from co
order by co.subject_id, co.admittime, co.intime;
