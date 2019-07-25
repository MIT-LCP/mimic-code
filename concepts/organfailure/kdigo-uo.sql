DROP MATERIALIZED VIEW IF EXISTS kdigo_uo CASCADE;
CREATE MATERIALIZED VIEW kdigo_uo AS
with ur_stg as
(
  select io.icustay_id, io.charttime
  -- three sums:
  -- 1) over a 6 hour period
  -- 2) over a 12 hour period
  -- 3) over a 24 hour period
  , sum(case when io.charttime <= iosum.charttime + interval '5' hour
      then iosum.VALUE
    else null end) as UrineOutput_6hr
  , sum(case when io.charttime <= iosum.charttime + interval '11' hour
      then iosum.VALUE
    else null end) as UrineOutput_12hr
  , sum(iosum.VALUE) as UrineOutput_24hr
  -- count number of measures to protect against missing data
  , MIN(case when io.charttime <= iosum.charttime + interval '5' hour
      then iosum.charttime
    else null end) AS uo_tm_6hr
  , MIN(case when io.charttime <= iosum.charttime + interval '11' hour
      then iosum.charttime
    else null end) AS uo_tm_12hr
  , MIN(iosum.charttime) AS uo_tm_24hr
  from urineoutput io
  -- this join gives you all UO measurements over a 24 hour period
  left join urineoutput iosum
    on  io.icustay_id = iosum.icustay_id
    and io.charttime >= iosum.charttime
    and io.charttime <= (iosum.charttime + interval '23' hour)
  group by io.icustay_id, io.charttime
)
select
  ur.icustay_id
, ur.charttime
, wd.weight
, ur.UrineOutput_6hr
, ur.UrineOutput_12hr
, ur.UrineOutput_24hr
-- calculate rates
, ROUND((ur.UrineOutput_6hr/wd.weight/6.0)::NUMERIC, 4) AS uo_rt_6hr
, ROUND((ur.UrineOutput_12hr/wd.weight/12.0)::NUMERIC, 4) AS uo_rt_12hr
, ROUND((ur.UrineOutput_24hr/wd.weight/24.0)::NUMERIC, 4) AS uo_rt_24hr
-- time of earliest UO measurement that was used to calculate the rate
, uo_tm_6hr
, uo_tm_12hr
, uo_tm_24hr
from ur_stg ur
left join weightdurations wd
  on  ur.icustay_id = wd.icustay_id
  and ur.charttime >= wd.starttime
  and ur.charttime <  wd.endtime
order by icustay_id, charttime;
