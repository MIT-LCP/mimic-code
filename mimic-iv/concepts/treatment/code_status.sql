-- This query extracts:
--    i) a patient's first code status
--    ii) a patient's last code status
--    iii) the time of the first entry of DNR or CMO

with t1 as
(
  /* 
There are five distinct values for the code status order in the dataset:
1 DNR / DNI
2	DNI (do not intubate)
3	Comfort measures only
4	Full code
5	DNR (do not resuscitate)
 */
  
  select stay_id, charttime, value
  -- use row number to identify first and last code status
  , ROW_NUMBER() over (PARTITION BY stay_id order by charttime) as rnfirst
  , ROW_NUMBER() over (PARTITION BY stay_id order by charttime desc) as rnlast
  -- coalesce the values
  , case
      when value in ('Full code') then 1
    else 0 end as fullcode
  , case
      when value in ('Comfort measures only') then 1
    else 0 end as cmo
  , case
      when value in ('DNI (do not intubate)','DNR / DNI') then 1
    else 0 end as dni
  , case
      when value in ('DNR (do not resuscitate)','DNR / DNI') then 1
    else 0 end as dnr
  FROM `physionet-data.mimic_icu.chartevents`
  where itemid in (223758)
)
select ie.subject_id, ie.hadm_id, ie.stay_id
  -- first recorded code status
  , max(case when rnfirst = 1 then t1.fullcode else null end) as fullcode_first
  , max(case when rnfirst = 1 then t1.cmo else null end) as cmo_first
  , max(case when rnfirst = 1 then t1.dnr else null end) as dnr_first
  , max(case when rnfirst = 1 then t1.dni else null end) as dni_first

  -- last recorded code status
  , max(case when  rnlast = 1 then t1.fullcode else null end) as fullcode_last
  , max(case when  rnlast = 1 then t1.cmo else null end) as cmo_last
  , max(case when  rnlast = 1 then t1.dnr else null end) as dnr_last
  , max(case when  rnlast = 1 then t1.dni else null end) as dni_last

  -- were they *at any time* given a certain code status
  , max(t1.fullcode) as fullcode
  , max(t1.cmo) as cmo
  , max(t1.dnr) as dnr
  , max(t1.dni) as dni

  -- time until their first DNR
  , min(case when t1.dnr = 1 then t1.charttime else null end)
        as dnr_first_charttime
  , min(case when t1.dni = 1 then t1.charttime else null end)
        as dni_first_charttime

  -- first code status of CMO
  , min(case when t1.cmo = 1 then t1.charttime else null end)
        as timecmo_chart

FROM `physionet-data.mimic_icu.icustays` ie
left join t1
  on ie.stay_id = t1.stay_id
group by ie.subject_id, ie.hadm_id, ie.stay_id, ie.intime;
