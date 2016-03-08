-- ------------------------------------------------------------------
-- Title: Simplified Acute Physiology Score II (SAPS II)
-- MIMIC version: ?
-- Calculate hospital mortality, 30 day mortality (from hospital admission), 
-- and 1 year mortality (from hospital admission)
-- Inclusion criteria: Adult (>15 year old) patients, *MOST RECENT* hospital admission
-- ------------------------------------------------------------------

with tmp as (
select adm.hadm_id, admittime, dischtime, adm.deathtime, pat.dod
-- integer which is 1 for the most recent hospital admission
, ROW_NUMBER() over (partition by hadm_id order by admittime DESC) as mostrecent
from admissions adm
inner join patients pat
  on adm.subject_id = pat.subject_id
-- filter out organ donor accounts
where lower(diagnosis) not like '%organ donor%'
-- at least 15 years old
and extract(YEAR from admittime) - extract(YEAR from dob) > 15
-- filter that removes hospital admissions with no corresponding ICU data
and HAS_CHARTEVENTS_DATA = 1
)
select
  count(hadm_id) as NumPat -- total number of patients
, round( count(deathtime)/count(hadm_id)*100 , 4) as HospMort -- % hospital mortality
, round( sum(case when dod < admittime+30 then 1 else 0 end)/count(hadm_id)*100 , 4) as HospMort30day -- % 30 day mortality
, round( sum(case when dod < admittime+365.25 then 1 else 0 end)/count(hadm_id)*100 , 4) as HospMort1yr -- % 1 year mortality
from tmp;
