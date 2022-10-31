-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS kdigo_uo; CREATE TABLE kdigo_uo AS 
with ur_stg as
(
  select io.stay_id, io.charttime
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
  , sum(case when iosum.charttime >= DATETIME_SUB(io.charttime, interval '5' hour)
      then iosum.urineoutput
    else null end) as UrineOutput_6hr
  -- 12 hours
  , sum(case when iosum.charttime >= DATETIME_SUB(io.charttime, interval '11' hour)
      then iosum.urineoutput
    else null end) as UrineOutput_12hr
  -- 24 hours
  , sum(iosum.urineoutput) as UrineOutput_24hr
    
  -- calculate the number of hours over which we've tabulated UO
  , ROUND(CAST(
      DATETIME_DIFF(io.charttime, 
        -- below MIN() gets the earliest time that was used in the summation 
        MIN(case when iosum.charttime >= DATETIME_SUB(io.charttime, interval '5' hour)
          then iosum.charttime
        else null end),
        'SECOND') AS NUMERIC)/3600.0, 4)
     AS uo_tm_6hr
  -- repeat extraction for 12 hours and 24 hours
  , ROUND(CAST(
      DATETIME_DIFF(io.charttime,
        MIN(case when iosum.charttime >= DATETIME_SUB(io.charttime, interval '11' hour)
          then iosum.charttime
        else null end),
        'SECOND') AS NUMERIC)/3600.0, 4)
   AS uo_tm_12hr
  , ROUND(CAST(
      DATETIME_DIFF(io.charttime, MIN(iosum.charttime), 'SECOND')
   AS NUMERIC)/3600.0, 4) AS uo_tm_24hr
  from mimiciv_derived.urine_output io
  -- this join gives all UO measurements over the 24 hours preceding this row
  left join mimiciv_derived.urine_output iosum
    on  io.stay_id = iosum.stay_id
    and iosum.charttime <= io.charttime
    and iosum.charttime >= DATETIME_SUB(io.charttime, interval '23' hour)
  group by io.stay_id, io.charttime
)
select
  ur.stay_id
, ur.charttime
, wd.weight
, ur.urineoutput_6hr
, ur.urineoutput_12hr
, ur.urineoutput_24hr
-- calculate rates - adding 1 hour as we assume data charted at 10:00 corresponds to previous hour
, ROUND(CAST((ur.UrineOutput_6hr/wd.weight/(uo_tm_6hr+1))   AS NUMERIC), 4) AS uo_rt_6hr
, ROUND(CAST((ur.UrineOutput_12hr/wd.weight/(uo_tm_12hr+1)) AS NUMERIC), 4) AS uo_rt_12hr
, ROUND(CAST((ur.UrineOutput_24hr/wd.weight/(uo_tm_24hr+1)) AS NUMERIC), 4) AS uo_rt_24hr
-- number of hours between current UO time and earliest charted UO within the X hour window
, uo_tm_6hr
, uo_tm_12hr
, uo_tm_24hr
from ur_stg ur
left join mimiciv_derived.weight_durations wd
  on  ur.stay_id = wd.stay_id
  and ur.charttime >= wd.starttime
  and ur.charttime <  wd.endtime
;