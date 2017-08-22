-- This query extracts:
--    i) a patient's first code status
--    ii) a patient's last code status
--    iii) the time of the first entry of DNR or CMO

DROP MATERIALIZED VIEW IF EXISTS CODE_STATUS;
CREATE MATERIALIZED VIEW CODE_STATUS AS
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
  from chartevents
  where itemid in (128, 223758)
  and value is not null
  and value != 'Other/Remarks'
  -- exclude rows marked as error
  AND error IS DISTINCT FROM 1
)
-- examine the discharge summaries to determine if they were ever made cmo
, disch as
(
  select
    ne.hadm_id
    , max(case
        when substring(substring(text from '[^E]CMO') from 2 for 3) = 'CMO'
          then 1
        else 0
      end) as CMO
    --
    -- , case
    --     when substring(text from '^[E]CMO') as CMO
  from noteevents ne
  where category = 'Discharge summary'
  and text like '%CMO%'
  group by hadm_id
)
-- examine the notes to determine if they were ever made cmo
, nnote as
(
  select
    hadm_id, charttime
    , max(case
        when substring(text from 'made CMO') != '' then 1
        when substring(lower(text) from 'cmo ordered') != '' then 1
        when substring(lower(text) from 'pt. is cmo') != '' then 1
        when substring(text from 'Code status:([ \r\n]+)Comfort measures only') != '' then 1
        --when substring(text from 'made CMO') != '' then 1
        --when substring(substring(text from '[^E]CMO') from 2 for 3) = 'CMO'
        --  then 1
        else 0
      end) as CMO
  from noteevents ne
  where category in ('Nursing/other','Nursing','Physician')
  and lower(text) like '%cmo%'
  group by hadm_id, charttime
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

  -- discharge summary mentions CMO
  -- *** not totally robust, the note could say "NOT CMO", which would be flagged as 1
  , max(case when disch.cmo = 1 then 1 else 0 end) as CMO_ds

  -- time until their first DNR
  , min(case when t1.DNR = 1 then t1.charttime else null end)
        as TimeDNR_chart

  -- first code status of CMO
  , min(case when t1.CMO = 1 then t1.charttime else null end)
        as TimeCMO_chart
  , min(case when t1.CMO = 1 then nn.charttime else null end)
        as TimeCMO_NursingNote

from icustays ie
left join t1
  on ie.icustay_id = t1.icustay_id
left join nnote nn
  on ie.hadm_id = nn.hadm_id and nn.charttime between ie.intime and ie.outtime
left join disch
  on ie.hadm_id = disch.hadm_id
group by ie.subject_id, ie.hadm_id, ie.icustay_id, ie.intime;
