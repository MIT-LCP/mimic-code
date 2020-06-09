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
    else null end) as urineoutput_6hr
  , sum(case when DATETIME_DIFF(io.charttime, iosum.charttime, HOUR) <= 11
      then iosum.VALUE
    else null end) as urineoutput_12hr
  -- 24 hours
  , sum(iosum.VALUE) as urineoutput_24hr

  -- retain the earliest time used for each summation
  -- this is later used to tabulate rates
  , MIN(case when io.charttime <= DATETIME_ADD(iosum.charttime, INTERVAL '5' HOUR)
      then iosum.charttime
    else null end)
    AS starttime_6hr
  , MIN(case when io.charttime <= DATETIME_ADD(iosum.charttime, INTERVAL '11' HOUR)
      then iosum.charttime
    else null end)
    AS starttime_12hr
  , MIN(iosum.charttime) AS starttime_24hr
  from `physionet-data.mimiciii_derived.urine_output` io
  -- this join gives you all UO measurements over a 24 hour period
  left join `physionet-data.mimiciii_derived.urine_output` iosum
    on  io.icustay_id = iosum.icustay_id
    and io.charttime >= iosum.charttime
    and io.charttime <= (DATETIME_ADD(iosum.charttime, INTERVAL '23' HOUR))
  group by io.icustay_id, io.charttime
)
-- calculate hours used to sum UO over
, ur_stg2 AS
(
  select
    icustay_id
  , charttime
  , urineoutput_6hr
  , urineoutput_12hr
  , urineoutput_24hr
  -- calculate time over which we summed UO
  -- note: adding 1 hour as we assume data charted corresponds to previous hour
  -- i.e. if documentation is:
  --  10:00, 100 mL
  --  11:00, 50 mL
  -- then this is two hours of documentation, even though (11:00 - 10:00) is 1 hour
  , ROUND(DATETIME_DIFF(charttime, starttime_6hr, HOUR), 4) + 1 AS uo_tm_6hr
  , ROUND(DATETIME_DIFF(charttime, starttime_12hr, HOUR), 4) + 1 AS uo_tm_12hr
  , ROUND(DATETIME_DIFF(charttime, starttime_24hr, HOUR), 4) + 1 AS uo_tm_24hr
  from ur_stg
)
select
  ur.icustay_id
, ur.charttime
, wd.weight
, ur.urineoutput_6hr
, ur.urineoutput_12hr
, ur.urineoutput_24hr
, ROUND(CAST((ur.urineoutput_6hr/wd.weight/uo_tm_6hr) AS NUMERIC), 4) AS uo_rt_6hr
, ROUND(CAST((ur.urineoutput_12hr/wd.weight/uo_tm_12hr) AS NUMERIC), 4) AS uo_rt_12hr
, ROUND(CAST((ur.urineoutput_24hr/wd.weight/uo_tm_24hr) AS NUMERIC), 4) AS uo_rt_24hr
-- time of earliest UO measurement that was used to calculate the rate
, uo_tm_6hr
, uo_tm_12hr
, uo_tm_24hr
from ur_stg2 ur
left join `physionet-data.mimiciii_derived.weight_durations` wd
  on  ur.icustay_id = wd.icustay_id
  and ur.charttime >= wd.starttime
  and ur.charttime <  wd.endtime
order by icustay_id, charttime;
