-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.urine_output_rate; CREATE TABLE mimiciv_derived.urine_output_rate AS
WITH tm AS (
  SELECT
    ie.stay_id,
    MIN(charttime) AS intime_hr,
    MAX(charttime) AS outtime_hr
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_icu.chartevents AS ce
    ON ie.stay_id = ce.stay_id
    AND ce.itemid = 220045
    AND ce.charttime > ie.intime - INTERVAL '1' MONTH
    AND ce.charttime < ie.outtime + INTERVAL '1' MONTH
  GROUP BY
    ie.stay_id
), uo_tm AS (
  SELECT
    tm.stay_id,
    CASE
      WHEN LAG(charttime) OVER w IS NULL
      THEN DATE_DIFF('microseconds', intime_hr, charttime)/60000000.0
      ELSE DATE_DIFF('microseconds', LAG(charttime) OVER w, charttime)/60000000.0
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
    io.charttime,
    SUM(DISTINCT io.urineoutput) AS uo,
    SUM(
      CASE
        WHEN DATE_DIFF('microseconds', iosum.charttime, io.charttime)/3600000000.0 <= 5
        THEN iosum.urineoutput
        ELSE NULL
      END
    ) AS urineoutput_6hr,
    SUM(
      CASE
        WHEN DATE_DIFF('microseconds', iosum.charttime, io.charttime)/3600000000.0 <= 5
        THEN iosum.tm_since_last_uo
        ELSE NULL
      END
    ) / 60.0 AS uo_tm_6hr,
    SUM(
      CASE
        WHEN DATE_DIFF('microseconds', iosum.charttime, io.charttime)/3600000000.0 <= 11
        THEN iosum.urineoutput
        ELSE NULL
      END
    ) AS urineoutput_12hr,
    SUM(
      CASE
        WHEN DATE_DIFF('microseconds', iosum.charttime, io.charttime)/3600000000.0 <= 11
        THEN iosum.tm_since_last_uo
        ELSE NULL
      END
    ) / 60.0 AS uo_tm_12hr,
    SUM(iosum.urineoutput) AS urineoutput_24hr,
    SUM(iosum.tm_since_last_uo) / 60.0 AS uo_tm_24hr
  FROM uo_tm AS io
  LEFT JOIN uo_tm AS iosum
    ON io.stay_id = iosum.stay_id
    AND io.charttime >= iosum.charttime
    AND io.charttime <= (
      iosum.charttime + INTERVAL '23' HOUR
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
    THEN ROUND(TRY_CAST((
      ur.urineoutput_6hr / wd.weight / uo_tm_6hr
    ) AS DECIMAL), 4)
  END AS uo_mlkghr_6hr,
  CASE
    WHEN uo_tm_12hr >= 12
    THEN ROUND(TRY_CAST((
      ur.urineoutput_12hr / wd.weight / uo_tm_12hr
    ) AS DECIMAL), 4)
  END AS uo_mlkghr_12hr,
  CASE
    WHEN uo_tm_24hr >= 24
    THEN ROUND(TRY_CAST((
      ur.urineoutput_24hr / wd.weight / uo_tm_24hr
    ) AS DECIMAL), 4)
  END AS uo_mlkghr_24hr,
  ROUND(TRY_CAST(uo_tm_6hr AS DECIMAL), 2) AS uo_tm_6hr,
  ROUND(TRY_CAST(uo_tm_12hr AS DECIMAL), 2) AS uo_tm_12hr,
  ROUND(TRY_CAST(uo_tm_24hr AS DECIMAL), 2) AS uo_tm_24hr
FROM ur_stg AS ur
LEFT JOIN mimiciv_derived.weight_durations AS wd
  ON ur.stay_id = wd.stay_id
  AND ur.charttime > wd.starttime
  AND ur.charttime <= wd.endtime
  AND wd.weight > 0