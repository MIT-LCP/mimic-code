-- This query extracts useful demographic/administrative information for patient ICU stays

with co as (
select ie.subject_id, ie.hadm_id, ie.icustay_id
​
-- patient level factors
, pat.gender
	
-- hospital level factors
, adm.ethnicity
, adm.ADMISSION_TYPE
, adm.admittime, adm.dischtime
, case when adm.deathtime is not null then 'Y' else 'N' end
          as hospital_expire_flag
, row_number() over (partition by ie.subject_id, ie.hadm_id order by ie.intime) as hospstay_num
, case when row_number() over (partition by ie.subject_id, ie.hadm_id order by ie.intime) = 1 then 'Y' else 'N' end
	as first_hosp_stay
	
-- icu level factors
, ie.intime, ie.outtime
, EXTRACT(DAY FROM ie.intime-pat.dob) / 365.25 as Age
, round(ie.outtime - ie.intime,4) as LOS_ICU
, row_number() over (partition by ie.subject_id, ie.hadm_id order by ie.intime) as icustay_num
​
​
from mimiciii.icustayevents ie
inner join mimiciii.admissions adm
 on ie.hadm_id = adm.hadm_id
inner join mimiciii.patients pat
 on ie.subject_id = pat.subject_id
where adm.has_chartevents_data = 1
)
select co.*
from co
order by co.subject_id, co.admittime, co.intime;
