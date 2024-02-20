-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.urine_output_rate; CREATE TABLE mimiciv_derived.urine_output_rate AS
/* attempt to calculate urine output per hour */ /* rate/hour is the interpretable measure of kidney function */ /* though it is difficult to estimate from aperiodic point measures */ /* first we get the earliest heart rate documented for the stay */
WITH tm AS (
  SELECT
    ie.stay_id,
    MIN(charttime) AS intime_hr,
    MAX(charttime) AS outtime_hr
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_icu.chartevents AS ce
    ON ie.stay_id = ce.stay_id
    AND ce.itemid = 220045
    AND ce.charttime > ie.intime - INTERVAL '1 MONTH'
    AND ce.charttime < ie.outtime + INTERVAL '1 MONTH'
  GROUP BY
    ie.stay_id
), uo_tm AS (
  SELECT
    tm.stay_id,
    CASE
      WHEN LAG(charttime) OVER w IS NULL
      THEN EXTRACT(EPOCH FROM charttime - intime_hr) / 60.0
      ELSE EXTRACT(EPOCH FROM charttime - LAG(charttime) OVER w) / 60.0
    END AS tm_since_last_uo,
    uo.charttime,
    uo.urineoutput
  FROM tm
  INNER JOIN mimiciv_derived.urine_output AS uo
    ON tm.stay_id = uo.stay_id
  WINDOW w AS (PARTITION BY tm.stay_id ORDER BY charttime NULLS FIRST)
), ur_stg AS (
  SELECT
    io.stay_id,
    io.charttime, /* we have joined each row to all rows preceding within 24 hours */ /* we can now sum these rows to get total UO over the last 24 hours */ /* we can use case statements to restrict it to only the last 6/12 hours */ /* therefore we have three sums: */ /* 1) over a 6 hour period */ /* 2) over a 12 hour period */ /* 3) over a 24 hour period */
    SUM(DISTINCT io.urineoutput) AS uo, /* note that we assume data charted at charttime corresponds */ /* to 1 hour of UO, therefore we use '5' and '11' to restrict the */ /* period, rather than 6/12 this assumption may overestimate UO rate */ /* when documentation is done less than hourly */
    SUM(
      CASE
        WHEN EXTRACT(EPOCH FROM io.charttime - iosum.charttime) / 3600.0 <= 5
        THEN iosum.urineoutput
        ELSE NULL
      END
    ) AS urineoutput_6hr,
    CAST(SUM(
      CASE
        WHEN EXTRACT(EPOCH FROM io.charttime - iosum.charttime) / 3600.0 <= 5
        THEN iosum.tm_since_last_uo
        ELSE NULL
      END
    ) AS DOUBLE PRECISION) / 60.0 AS uo_tm_6hr,
    SUM(
      CASE
        WHEN EXTRACT(EPOCH FROM io.charttime - iosum.charttime) / 3600.0 <= 11
        THEN iosum.urineoutput
        ELSE NULL
      END
    ) AS urineoutput_12hr,
    CAST(SUM(
      CASE
        WHEN EXTRACT(EPOCH FROM io.charttime - iosum.charttime) / 3600.0 <= 11
        THEN iosum.tm_since_last_uo
        ELSE NULL
      END
    ) AS DOUBLE PRECISION) / 60.0 AS uo_tm_12hr, /* 24 hours */
    SUM(iosum.urineoutput) AS urineoutput_24hr,
    CAST(SUM(iosum.tm_since_last_uo) AS DOUBLE PRECISION) / 60.0 AS uo_tm_24hr
  FROM uo_tm AS io
  /* this join gives you all UO measurements over a 24 hour period */
  LEFT JOIN uo_tm AS iosum
    ON io.stay_id = iosum.stay_id
    AND io.charttime >= iosum.charttime
    AND io.charttime <= (
      iosum.charttime + INTERVAL '23 HOUR'
    )
  GROUP BY
    io.stay_id,
    io.charttime
)
SELECT
  ur.stay_id,
  ur.charttime,
  wd.weight,
  ur.uo,
  ur.urineoutput_6hr,
  ur.urineoutput_12hr,
  ur.urineoutput_24hr,
  CASE
    WHEN uo_tm_6hr >= 6
    THEN ROUND(
      CAST((
        CAST(CAST(ur.urineoutput_6hr AS DOUBLE PRECISION) / wd.weight AS DOUBLE PRECISION) / uo_tm_6hr
      ) AS DECIMAL),
      4
    )
  END AS uo_mlkghr_6hr,
  CASE
    WHEN uo_tm_12hr >= 12
    THEN ROUND(
      CAST((
        CAST(CAST(ur.urineoutput_12hr AS DOUBLE PRECISION) / wd.weight AS DOUBLE PRECISION) / uo_tm_12hr
      ) AS DECIMAL),
      4
    )
  END AS uo_mlkghr_12hr,
  CASE
    WHEN uo_tm_24hr >= 24
    THEN ROUND(
      CAST((
        CAST(CAST(ur.urineoutput_24hr AS DOUBLE PRECISION) / wd.weight AS DOUBLE PRECISION) / uo_tm_24hr
      ) AS DECIMAL),
      4
    )
  END AS uo_mlkghr_24hr, /* time of earliest UO measurement that was used to calculate the rate */
  ROUND(CAST(uo_tm_6hr AS DECIMAL), 2) AS uo_tm_6hr,
  ROUND(CAST(uo_tm_12hr AS DECIMAL), 2) AS uo_tm_12hr,
  ROUND(CAST(uo_tm_24hr AS DECIMAL), 2) AS uo_tm_24hr
FROM ur_stg AS ur
LEFT JOIN mimiciv_derived.weight_durations AS wd
  ON ur.stay_id = wd.stay_id
  AND ur.charttime > wd.starttime
  AND ur.charttime <= wd.endtime
  AND wd.weight > 0