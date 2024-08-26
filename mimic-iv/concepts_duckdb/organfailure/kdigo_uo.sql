-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.kdigo_uo; CREATE TABLE mimiciv_derived.kdigo_uo AS
WITH uo_stg1 AS (
  SELECT
    ie.stay_id,
    uo.charttime,
    TRY_CAST(DATE_DIFF('microseconds', intime, charttime)/1000000.0 AS INT) AS seconds_since_admit,
    COALESCE(
      DATE_DIFF('microseconds', LAG(charttime) OVER (PARTITION BY ie.stay_id ORDER BY charttime NULLS FIRST), charttime)/1000000.0 / 3600.0,
      1
    ) AS hours_since_previous_row,
    urineoutput
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_derived.urine_output AS uo
    ON ie.stay_id = uo.stay_id
), uo_stg2 AS (
  SELECT
    stay_id,
    charttime,
    hours_since_previous_row,
    urineoutput,
    SUM(urineoutput) OVER (PARTITION BY stay_id ORDER BY seconds_since_admit NULLS FIRST RANGE BETWEEN 21600 PRECEDING AND CURRENT ROW) AS urineoutput_6hr,
    SUM(urineoutput) OVER (PARTITION BY stay_id ORDER BY seconds_since_admit NULLS FIRST RANGE BETWEEN 43200 PRECEDING AND CURRENT ROW) AS urineoutput_12hr,
    SUM(urineoutput) OVER (PARTITION BY stay_id ORDER BY seconds_since_admit NULLS FIRST RANGE BETWEEN 86400 PRECEDING AND CURRENT ROW) AS urineoutput_24hr,
    SUM(hours_since_previous_row) OVER (PARTITION BY stay_id ORDER BY seconds_since_admit NULLS FIRST RANGE BETWEEN 21600 PRECEDING AND CURRENT ROW) AS uo_tm_6hr,
    SUM(hours_since_previous_row) OVER (PARTITION BY stay_id ORDER BY seconds_since_admit NULLS FIRST RANGE BETWEEN 43200 PRECEDING AND CURRENT ROW) AS uo_tm_12hr,
    SUM(hours_since_previous_row) OVER (PARTITION BY stay_id ORDER BY seconds_since_admit NULLS FIRST RANGE BETWEEN 86400 PRECEDING AND CURRENT ROW) AS uo_tm_24hr
  FROM uo_stg1
)
SELECT
  ur.stay_id,
  ur.charttime,
  wd.weight,
  ur.urineoutput_6hr,
  ur.urineoutput_12hr,
  ur.urineoutput_24hr,
  CASE
    WHEN uo_tm_6hr >= 6 AND uo_tm_6hr < 12
    THEN ROUND(TRY_CAST((
      ur.urineoutput_6hr / wd.weight / uo_tm_6hr
    ) AS DECIMAL), 4)
    ELSE NULL
  END AS uo_rt_6hr,
  CASE
    WHEN uo_tm_12hr >= 12
    THEN ROUND(TRY_CAST((
      ur.urineoutput_12hr / wd.weight / uo_tm_12hr
    ) AS DECIMAL), 4)
    ELSE NULL
  END AS uo_rt_12hr,
  CASE
    WHEN uo_tm_24hr >= 24
    THEN ROUND(TRY_CAST((
      ur.urineoutput_24hr / wd.weight / uo_tm_24hr
    ) AS DECIMAL), 4)
    ELSE NULL
  END AS uo_rt_24hr,
  uo_tm_6hr,
  uo_tm_12hr,
  uo_tm_24hr
FROM uo_stg2 AS ur
LEFT JOIN mimiciv_derived.weight_durations AS wd
  ON ur.stay_id = wd.stay_id
  AND ur.charttime >= wd.starttime
  AND ur.charttime < wd.endtime