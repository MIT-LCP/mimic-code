DROP MATERIALIZED VIEW IF EXISTS kdigo_uo CASCADE;
CREATE MATERIALIZED VIEW kdigo_uo AS
with ur_stg as
(
  select io.icustay_id, io.charttime
  -- we have joined each row to all rows preceding within 24 hours
  -- we can now sum these rows to get total UO over the last 24 hours
  -- we can use case statements to restrict it to only the last 6/12 hours
  -- therefore we have three sums:
  -- 1) over a 6 hour period
  -- 2) over a 12 hour period
  -- 3) over a 24 hour period
  -- note that we assume data charted at charttime corresponds to 1 hour of UO
  -- therefore we use '5' and '11' to restrict the period, rather than 6/12
  -- this assumption may overestimate UO rate when documentation is done less than hourly

  -- 6 hours
  , sum(case when io.charttime <= iosum.charttime + interval '5' hour
      then iosum.VALUE
    else null end) as UrineOutput_6hr
  -- 12 hours
  , sum(case when io.charttime <= iosum.charttime + interval '11' hour
      then iosum.VALUE
    else null end) as UrineOutput_12hr
  -- 24 hours
  , sum(iosum.VALUE) as UrineOutput_24hr
  -- calculate the number of hours over which we've tabulated UO
  , ROUND(CAST(EXTRACT(EPOCH FROM
      io.charttime - 
        -- below MIN() gets the earliest time that was used in the summation 
        MIN(case when io.charttime <= iosum.charttime + interval '5' hour
          then iosum.charttime
        else null end)
    -- convert from EPOCH (seconds) to hours by dividing by 360.0
    )/3600.0 AS NUMERIC), 4) AS uo_tm_6hr
  -- repeat extraction for 12 hours and 24 hours
  , ROUND(CAST(EXTRACT(EPOCH FROM
      io.charttime - 
        MIN(case when io.charttime <= iosum.charttime + interval '11' hour
          then iosum.charttime
        else null end)
   )/3600.0 AS NUMERIC), 4) AS uo_tm_12hr
  , ROUND(CAST(EXTRACT(EPOCH FROM
      io.charttime - MIN(iosum.charttime)
   )/3600.0 AS NUMERIC), 4) AS uo_tm_24hr
  from urineoutput io
  -- this join gives all UO measurements over the 24 hours preceding this row
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
-- calculate rates - adding 1 hour as we assume data charted at 10:00 corresponds to previous hour
, ROUND((ur.UrineOutput_6hr/wd.weight/(uo_tm_6hr+1))::NUMERIC, 4) AS uo_rt_6hr
, ROUND((ur.UrineOutput_12hr/wd.weight/(uo_tm_12hr+1))::NUMERIC, 4) AS uo_rt_12hr
, ROUND((ur.UrineOutput_24hr/wd.weight/(uo_tm_24hr+1))::NUMERIC, 4) AS uo_rt_24hr
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
