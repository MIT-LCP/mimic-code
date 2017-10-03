DROP MATERIALIZED VIEW IF EXISTS icustay_times CASCADE;
CREATE MATERIALIZED VIEW icustay_times as
-- get first/last heart rate measurement during hospitalization for each ICUSTAY_ID
with t1 as
(
select ce.icustay_id
, min(charttime) as intime_hr
, max(charttime) as outtime_hr
from chartevents ce
-- very loose join to admissions to ensure charttime is near patient admission
inner join admissions adm
  on ce.hadm_id = adm.hadm_id
  and ce.charttime between adm.admittime - interval '1' day and adm.dischtime + interval '1' day
-- only look at heart rate
where ce.itemid in (211,220045)
group by ce.icustay_id
)
-- add in subject_id/hadm_id
select
  ie.subject_id, ie.hadm_id, ie.icustay_id
  , t1.intime_hr
  , t1.outtime_hr
from icustays ie
left join t1
  on ie.icustay_id = t1.icustay_id
order by ie.subject_id, ie.hadm_id, ie.icustay_id;
