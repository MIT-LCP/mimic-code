-- This query extracts:
--    i) a patient's first code status
--    ii) a patient's last code status
--    iii) the time of the first entry of DNR or CMO

with t1 as
(
  select icustay_id, charttime, value
  -- use row number to identify first and last code status
  , ROW_NUMBER() over (PARTITION BY icustay_id order by charttime) as rnfirst
  , ROW_NUMBER() over (PARTITION BY icustay_id order by charttime desc) as rnlast

  -- coalesce the values
  , case
      when value in ('Full Code','Full code') then 1
    else 0 end as fullcode
  , case
      when value in ('Comfort Measures','Comfort measures only') then 1
    else 0 end as cmo
  , case
      when value = 'CPR Not Indicate' then 1
    else 0 end as dncpr -- only in CareVue, i.e. only possible for ~60-70% of patients
  , case
      when value in ('Do Not Intubate','DNI (do not intubate)','DNR / DNI') then 1
    else 0 end as dni
  , case
      when value in ('Do Not Resuscita','DNR (do not resuscitate)','DNR / DNI') then 1
    else 0 end as dnr
  FROM `physionet-data.mimiciii_clinical.chartevents`
  where itemid in (128, 223758)
  and value is not null
  and value != 'Other/Remarks'
  -- exclude rows marked as error
  AND (error IS NULL OR error = 0)
)
select ie.subject_id, ie.hadm_id, ie.icustay_id
  -- first recorded code status
  , max(case when rnfirst = 1 then t1.fullcode else null end) as fullcode_first
  , max(case when rnfirst = 1 then t1.cmo else null end) as cmo_first
  , max(case when rnfirst = 1 then t1.dnr else null end) as dnr_first
  , max(case when rnfirst = 1 then t1.dni else null end) as dni_first
  , max(case when rnfirst = 1 then t1.dncpr else null end) as dncpr_first

  -- last recorded code status
  , max(case when  rnlast = 1 then t1.fullcode else null end) as fullcode_last
  , max(case when  rnlast = 1 then t1.cmo else null end) as cmo_last
  , max(case when  rnlast = 1 then t1.dnr else null end) as dnr_last
  , max(case when  rnlast = 1 then t1.dni else null end) as dni_last
  , max(case when  rnlast = 1 then t1.dncpr else null end) as DNCPR_last

  -- were they *at any time* given a certain code status
  , max(t1.fullcode) as fullcode
  , max(t1.cmo) as cmo
  , max(t1.dnr) as dnr
  , max(t1.dni) as dni
  , max(t1.dncpr) as dncpr

  -- time until their first DNR
  , min(case when t1.dnr = 1 then t1.charttime else null end)
        as dnr_first_charttime
  , min(case when t1.dni = 1 then t1.charttime else null end)
        as dni_first_charttime
  , min(case when t1.dncpr = 1 then t1.charttime else null end)
        as dncpr_first_charttime

  -- first code status of CMO
  , min(case when t1.cmo = 1 then t1.charttime else null end)
        as timecmo_chart

FROM `physionet-data.mimiciii_clinical.icustays` ie
left join t1
  on ie.icustay_id = t1.icustay_id
group by ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime;
