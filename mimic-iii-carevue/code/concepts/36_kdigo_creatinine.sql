drop table if exists kdigo_creatinine; create table kdigo_creatinine as 
-- Extract all creatinine values from labevents around patient's ICU stay
with cr as
(
select
    ie.icustay_id
  , ie.intime, ie.outtime
  , le.valuenum as creat
  , le.charttime
  from icustays ie
  left join labevents le
    on ie.subject_id = le.subject_id
    and le.itemid = 50912
    and le.valuenum is not null
    and (cast(extract(epoch from (le.charttime - ie.intime))/(60*60) as numeric)) <= (7*24-6)  
    and le.charttime >= (ie.intime - interval '6 hour')
    and le.charttime <= (ie.intime + interval '7 day')
)
-- add in the lowest value in the previous 48 hours/7 days
select
  cr.icustay_id
  , cr.charttime
  , cr.creat
  , min(cr48.creat) as creat_low_past_48hr
  , min(cr7.creat) as creat_low_past_7day
from cr
-- add in all creatinine values in the last 48 hours
left join cr cr48
  on cr.icustay_id = cr48.icustay_id
  and cr48.charttime <  cr.charttime
  and (cast(extract(epoch from (cr.charttime - cr48.charttime))/(60*60) as numeric)) <= 48
-- add in all creatinine values in the last 7 days
left join cr cr7
  on cr.icustay_id = cr7.icustay_id
  and cr7.charttime <  cr.charttime
  and (cast(extract(epoch from (cr.charttime - cr7.charttime))/(60*60*24) as numeric)) <= 7
group by cr.icustay_id, cr.charttime, cr.creat
order by cr.icustay_id, cr.charttime, cr.creat;