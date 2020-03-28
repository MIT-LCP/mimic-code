CREATE TABLE `physionet-data.mimiciii_derived.kdigo_uo` AS
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
  , sum(case when DATETIME_DIFF(io.charttime, iosum.charttime, HOUR) <= 5
      then iosum.VALUE
    else null end) as UrineOutput_6hr
  , sum(case when DATETIME_DIFF(io.charttime, iosum.charttime, HOUR) <= 11
      then iosum.VALUE
    else null end) as UrineOutput_12hr
  -- 24 hours
  , sum(iosum.VALUE) as UrineOutput_24hr
  from `physionet-data.mimiciii_derived.urineoutput` io
  -- this join gives you all UO measurements over a 24 hour period
  left join `physionet-data.mimiciii_derived.urineoutput` iosum
    on  io.icustay_id = iosum.icustay_id
    and io.charttime >= iosum.charttime
    and io.charttime <= (DATETIME_ADD(iosum.charttime, INTERVAL 23 HOUR))
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
left join `physionet-data.mimiciii_derived.weightdurations` wd
  on  ur.icustay_id = wd.icustay_id
  and ur.charttime >= wd.starttime
  and ur.charttime <  wd.endtime
order by icustay_id, charttime;
