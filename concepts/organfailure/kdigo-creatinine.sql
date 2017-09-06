DROP MATERIALIZED VIEW IF EXISTS kdigo_creat CASCADE;
CREATE MATERIALIZED VIEW kdigo_creat as
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
    and le.ITEMID = 50912
    and le.VALUENUM is not null
    and le.CHARTTIME between (ie.intime - interval '6' hour) and (ie.intime + interval '7' day)
)
-- ***** --
-- Get the highest and lowest creatinine for the first 48 hours of ICU admission
-- also get the first creatinine
-- ***** --
, cr_48hr as
(
select
    cr.icustay_id
  , cr.creat
  , cr.charttime
  -- Create an index that goes from 1, 2, ..., N
  -- The index represents how early in the patient's stay a creatinine value was measured
  -- Consequently, when we later select index == 1, we only select the first (admission) creatinine
  -- In addition, we only select the first stay for the given subject_id
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.charttime
              ) as rn_first

  -- Similarly, we can get the highest and the lowest creatinine by ordering by VALUENUM
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat DESC
              ) as rn_highest
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat
              ) as rn_lowest
  from cr
  -- limit to the first 48 hours (source table has data up to 7 days)
  where cr.charttime <= cr.intime + interval '48' hour
)
-- ***** --
-- Get the highest and lowest creatinine for the first 7 days of ICU admission
-- ***** --
, cr_7day as
(
select
    cr.icustay_id
  , cr.creat
  , cr.charttime
  -- We can get the highest and the lowest creatinine by ordering by VALUENUM
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat DESC
              ) as rn_highest
  , ROW_NUMBER ()
          OVER (PARTITION BY cr.icustay_id
                ORDER BY cr.creat
              ) as rn_lowest
  from cr
)
-- ***** --
-- Final query
-- ***** --
select
    ie.subject_id, ie.hadm_id, ie.icustay_id
  , cr_48hr_admit.creat as AdmCreat
  , cr_48hr_admit.charttime as AdmCreatTime
  , cr_48hr_low.creat as LowCreat48hr
  , cr_48hr_low.charttime as LowCreat48hrTime
  , cr_48hr_high.creat as HighCreat48hr
  , cr_48hr_high.charttime as HighCreat48hrTime

  , cr_7day_low.creat as LowCreat7day
  , cr_7day_low.charttime as LowCreat7dayTime
  , cr_7day_high.creat as HighCreat7day
  , cr_7day_high.charttime as HighCreat7dayTime

from icustays ie
left join cr_48hr cr_48hr_admit
  on ie.icustay_id = cr_48hr_admit.icustay_id
  and cr_48hr_admit.rn_first = 1
left join cr_48hr cr_48hr_high
  on ie.icustay_id = cr_48hr_high.icustay_id
  and cr_48hr_high.rn_highest = 1
left join cr_48hr cr_48hr_low
  on ie.icustay_id = cr_48hr_low.icustay_id
  and cr_48hr_low.rn_lowest = 1
left join cr_7day cr_7day_high
  on ie.icustay_id = cr_7day_high.icustay_id
  and cr_7day_high.rn_highest = 1
left join cr_7day cr_7day_low
  on ie.icustay_id = cr_7day_low.icustay_id
  and cr_7day_low.rn_lowest = 1
order by ie.icustay_id;
