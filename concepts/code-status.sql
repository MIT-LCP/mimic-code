-- This query extracts:
--    i) a patient's first code status
--    ii) a patient's last code status
--    iii) the time of the first entry of DNR or CMO

CREATE TABLE `physionet-data.mimiciii_derived.code_status` AS
with t1 as
(
  select icustay_id, charttime, value
  -- use row number to identify first and last code status
  , ROW_NUMBER() over (PARTITION BY icustay_id order by charttime) as rnFirst
  , ROW_NUMBER() over (PARTITION BY icustay_id order by charttime desc) as rnLast

  -- coalesce the values
  , case
      when value in ('Full Code','Full code') then 1
    else 0 end as FullCode
  , case
      when value in ('Comfort Measures','Comfort measures only') then 1
    else 0 end as CMO
  , case
      when value = 'CPR Not Indicate' then 1
    else 0 end as DNCPR -- only in CareVue, i.e. only possible for ~60-70% of patients
  , case
      when value in ('Do Not Intubate','DNI (do not intubate)','DNR / DNI') then 1
    else 0 end as DNI
  , case
      when value in ('Do Not Resuscita','DNR (do not resuscitate)','DNR / DNI') then 1
    else 0 end as DNR
  FROM `physionet-data.mimiciii_clinical.chartevents`
  where itemid in (128, 223758)
  and value is not null
  and value != 'Other/Remarks'
  -- exclude rows marked as error
  AND (error IS NULL OR error = 0)
)
select ie.subject_id, ie.hadm_id, ie.icustay_id
  -- first recorded code status
  , max(case when rnFirst = 1 then t1.FullCode else null end) as FullCode_first
  , max(case when rnFirst = 1 then t1.CMO else null end) as CMO_first
  , max(case when rnFirst = 1 then t1.DNR else null end) as DNR_first
  , max(case when rnFirst = 1 then t1.DNI else null end) as DNI_first
  , max(case when rnFirst = 1 then t1.DNCPR else null end) as DNCPR_first

  -- last recorded code status
  , max(case when  rnLast = 1 then t1.FullCode else null end) as FullCode_last
  , max(case when  rnLast = 1 then t1.CMO else null end) as CMO_last
  , max(case when  rnLast = 1 then t1.DNR else null end) as DNR_last
  , max(case when  rnLast = 1 then t1.DNI else null end) as DNI_last
  , max(case when  rnLast = 1 then t1.DNCPR else null end) as DNCPR_last

  -- were they *at any time* given a certain code status
  , max(t1.FullCode) as FullCode
  , max(t1.CMO) as CMO
  , max(t1.DNR) as DNR
  , max(t1.DNI) as DNI
  , max(t1.DNCPR) as DNCPR

  -- time until their first DNR
  , min(case when t1.DNR = 1 then t1.charttime else null end)
        as TimeDNR_chart

  -- first code status of CMO
  , min(case when t1.CMO = 1 then t1.charttime else null end)
        as TimeCMO_chart

FROM `physionet-data.mimiciii_clinical.icustays` ie
left join t1
  on ie.icustay_id = t1.icustay_id
group by ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime;
