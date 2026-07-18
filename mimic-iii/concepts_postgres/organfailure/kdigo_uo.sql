-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.kdigo_uo; CREATE TABLE mimiciii_derived.kdigo_uo AS
WITH ur_stg AS (
  SELECT
    io.icustay_id,
    io.charttime, /* we have joined each row to all rows preceding within 24 hours */ /* we can now sum these rows to get total UO over the last 24 hours */ /* we can use case statements to restrict it to only the last 6/12 hours */ /* therefore we have three sums: */ /* 1) over a 6 hour period */ /* 2) over a 12 hour period */ /* 3) over a 24 hour period */ /* note that we assume data charted at charttime corresponds to 1 hour of UO */ /* therefore we use '5' and '11' to restrict the period, rather than 6/12 */ /* this assumption may overestimate UO rate when documentation is done less than hourly */
    SUM(
      CASE
        WHEN CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', io.charttime) - DATE_TRUNC('hour', iosum.charttime)) / 3600 AS BIGINT) <= 5
        THEN iosum.VALUE
        ELSE NULL
      END
    ) AS urineoutput_6hr,
    SUM(
      CASE
        WHEN CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', io.charttime) - DATE_TRUNC('hour', iosum.charttime)) / 3600 AS BIGINT) <= 11
        THEN iosum.VALUE
        ELSE NULL
      END
    ) AS urineoutput_12hr, /* 24 hours */
    SUM(iosum.VALUE) AS urineoutput_24hr, /* retain the earliest time used for each summation */ /* this is later used to tabulate rates */
    MIN(
      CASE
        WHEN io.charttime <= iosum.charttime + INTERVAL '5' HOUR
        THEN iosum.charttime
        ELSE NULL
      END
    ) AS starttime_6hr,
    MIN(
      CASE
        WHEN io.charttime <= iosum.charttime + INTERVAL '11' HOUR
        THEN iosum.charttime
        ELSE NULL
      END
    ) AS starttime_12hr,
    MIN(iosum.charttime) AS starttime_24hr
  FROM mimiciii_derived.urine_output AS io
  /* this join gives you all UO measurements over a 24 hour period */
  LEFT JOIN mimiciii_derived.urine_output AS iosum
    ON io.icustay_id = iosum.icustay_id
    AND io.charttime >= iosum.charttime
    AND io.charttime <= (
      iosum.charttime + INTERVAL '23' HOUR
    )
  GROUP BY
    io.icustay_id,
    io.charttime
), ur_stg2 /* calculate hours used to sum UO over */ AS (
  SELECT
    icustay_id,
    charttime,
    urineoutput_6hr,
    urineoutput_12hr,
    urineoutput_24hr, /* calculate time over which we summed UO */ /* note: adding 1 hour as we assume data charted corresponds to previous hour */ /* i.e. if documentation is: */ /*  10:00, 100 mL */ /*  11:00, 50 mL */ /* then this is two hours of documentation, even though (11:00 - 10:00) is 1 hour */
    ROUND(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', charttime) - DATE_TRUNC('hour', starttime_6hr)) / 3600 AS BIGINT) AS NUMERIC), 4) + 1 AS uo_tm_6hr,
    ROUND(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', charttime) - DATE_TRUNC('hour', starttime_12hr)) / 3600 AS BIGINT) AS NUMERIC), 4) + 1 AS uo_tm_12hr,
    ROUND(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', charttime) - DATE_TRUNC('hour', starttime_24hr)) / 3600 AS BIGINT) AS NUMERIC), 4) + 1 AS uo_tm_24hr
  FROM ur_stg
)
SELECT
  ur.icustay_id,
  ur.charttime,
  wd.weight,
  ur.urineoutput_6hr,
  ur.urineoutput_12hr,
  ur.urineoutput_24hr,
  ROUND(
    CAST((
      CAST(CAST(ur.urineoutput_6hr AS DOUBLE PRECISION) / wd.weight AS DOUBLE PRECISION) / uo_tm_6hr
    ) AS DECIMAL(38, 9)),
    4
  ) AS uo_rt_6hr,
  ROUND(
    CAST((
      CAST(CAST(ur.urineoutput_12hr AS DOUBLE PRECISION) / wd.weight AS DOUBLE PRECISION) / uo_tm_12hr
    ) AS DECIMAL(38, 9)),
    4
  ) AS uo_rt_12hr,
  ROUND(
    CAST((
      CAST(CAST(ur.urineoutput_24hr AS DOUBLE PRECISION) / wd.weight AS DOUBLE PRECISION) / uo_tm_24hr
    ) AS DECIMAL(38, 9)),
    4
  ) AS uo_rt_24hr, /* time of earliest UO measurement that was used to calculate the rate */
  uo_tm_6hr,
  uo_tm_12hr,
  uo_tm_24hr
FROM ur_stg2 AS ur
LEFT JOIN mimiciii_derived.weight_durations AS wd
  ON ur.icustay_id = wd.icustay_id
  AND ur.charttime >= wd.starttime
  AND ur.charttime < wd.endtime
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST