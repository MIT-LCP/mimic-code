-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.kdigo_uo; CREATE TABLE mimiciii_derived.kdigo_uo AS
WITH ur_stg AS (
  SELECT
    io.icustay_id,
    io.charttime,
    SUM(
      CASE
        WHEN DATE_DIFF('HOUR', iosum.charttime, io.charttime) <= 5
        THEN iosum.VALUE
        ELSE NULL
      END
    ) AS urineoutput_6hr,
    SUM(
      CASE
        WHEN DATE_DIFF('HOUR', iosum.charttime, io.charttime) <= 11
        THEN iosum.VALUE
        ELSE NULL
      END
    ) AS urineoutput_12hr,
    SUM(iosum.VALUE) AS urineoutput_24hr,
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
  LEFT JOIN mimiciii_derived.urine_output AS iosum
    ON io.icustay_id = iosum.icustay_id
    AND io.charttime >= iosum.charttime
    AND io.charttime <= (
      iosum.charttime + INTERVAL '23' HOUR
    )
  GROUP BY
    io.icustay_id,
    io.charttime
), ur_stg2 AS (
  SELECT
    icustay_id,
    charttime,
    urineoutput_6hr,
    urineoutput_12hr,
    urineoutput_24hr,
    ROUND(DATE_DIFF('HOUR', starttime_6hr, charttime), 4) + 1 AS uo_tm_6hr,
    ROUND(DATE_DIFF('HOUR', starttime_12hr, charttime), 4) + 1 AS uo_tm_12hr,
    ROUND(DATE_DIFF('HOUR', starttime_24hr, charttime), 4) + 1 AS uo_tm_24hr
  FROM ur_stg
)
SELECT
  ur.icustay_id,
  ur.charttime,
  wd.weight,
  ur.urineoutput_6hr,
  ur.urineoutput_12hr,
  ur.urineoutput_24hr,
  ROUND(CAST((
    ur.urineoutput_6hr / wd.weight / uo_tm_6hr
  ) AS DECIMAL(38, 9)), 4) AS uo_rt_6hr,
  ROUND(CAST((
    ur.urineoutput_12hr / wd.weight / uo_tm_12hr
  ) AS DECIMAL(38, 9)), 4) AS uo_rt_12hr,
  ROUND(CAST((
    ur.urineoutput_24hr / wd.weight / uo_tm_24hr
  ) AS DECIMAL(38, 9)), 4) AS uo_rt_24hr,
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