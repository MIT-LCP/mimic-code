
-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
drop table if exists age; create table age as 

-- https://mimic.mit.edu/docs/iii/about/time/#dates-of-birth

-- Dates of birth which occur in the present time are not true dates of birth. 
-- Furthermore, dates of birth which occur before the year 1900 occur if the patient is older than 89. 
-- In these cases, the patient’s age at their first admission has been fixed to 300.

with age_raw as (
    select 
        icustay_id,
        hadm_id,
        round(cast(extract(epoch from (admittime - dob))/(60*60*24*365) as numeric), 2) as age
    from 
        mimiciii_cv.icustays
    left join mimiciii_cv.patients 
        using (subject_id)
    left join mimiciii_cv.admissions
        using (hadm_id)
)

select 
    distinct
    hadm_id,
    case when age >= 90 then 90 else age end as age
from
    age_raw;