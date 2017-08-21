DROP MATERIALIZED VIEW IF EXISTS kdigo_uo;
CREATE MATERIALIZED VIEW kdigo_uo AS
with ur_stg as
(
  select io.icustay_id, io.charttime

  -- three sums:
  -- 1) over a 6 hour period
  -- 2) over a 12 hour period
  -- 3) over a 24 hour period
  , sum(case when iosum.charttime <= io.charttime + interval '5' hour
      then iosum.VALUE
    else null end) as UrineOutput_6hr
  , sum(case when iosum.charttime <= io.charttime + interval '11' hour
      then iosum.VALUE
    else null end) as UrineOutput_12hr
  , sum(iosum.VALUE) as UrineOutput_24hr
  from urineoutput io
  -- this join gives you all UO measurements over a 24 hour period
  left join urineoutput iosum
    on  io.icustay_id = iosum.icustay_id
    and iosum.charttime >=  io.charttime
    and iosum.charttime <= (io.charttime + interval '23' hour)
  group by io.icustay_id, io.charttime
)
select
  ur.icustay_id
, ur.charttime
, wd.weight
, ur.UrineOutput_6hr
, ur.UrineOutput_12hr
, ur.UrineOutput_24hr
from ur_stg ur
left join weightdurations wd
  on  ur.icustay_id = wd.icustay_id
  and ur.charttime >= wd.starttime
  and ur.charttime <  wd.endtime
order by icustay_id, charttime;
