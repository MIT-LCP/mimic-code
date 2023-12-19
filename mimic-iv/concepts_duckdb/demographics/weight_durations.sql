-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.weight_durations; CREATE TABLE mimiciv_derived.weight_durations AS
WITH wt_stg AS (
  SELECT
    c.stay_id,
    c.charttime,
    CASE WHEN c.itemid = 226512 THEN 'admit' ELSE 'daily' END AS weight_type,
    c.valuenum AS weight
  FROM mimiciv_icu.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL AND c.itemid IN (226512, 224639) AND c.valuenum > 0
), wt_stg1 AS (
  SELECT
    stay_id,
    charttime,
    weight_type,
    weight,
    ROW_NUMBER() OVER (PARTITION BY stay_id, weight_type ORDER BY charttime NULLS FIRST) AS rn
  FROM wt_stg
  WHERE
    NOT weight IS NULL
), wt_stg2 AS (
  SELECT
    wt_stg1.stay_id,
    ie.intime,
    ie.outtime,
    wt_stg1.weight_type,
    CASE
      WHEN wt_stg1.weight_type = 'admit' AND wt_stg1.rn = 1
      THEN ie.intime - INTERVAL '2' HOUR
      ELSE wt_stg1.charttime
    END AS starttime,
    wt_stg1.weight
  FROM wt_stg1
  INNER JOIN mimiciv_icu.icustays AS ie
    ON ie.stay_id = wt_stg1.stay_id
), wt_stg3 AS (
  SELECT
    stay_id,
    intime,
    outtime,
    starttime,
    COALESCE(
      LEAD(starttime) OVER (PARTITION BY stay_id ORDER BY starttime NULLS FIRST),
      outtime + INTERVAL '2' HOUR
    ) AS endtime,
    weight,
    weight_type
  FROM wt_stg2
), wt1 AS (
  SELECT
    stay_id,
    starttime,
    COALESCE(
      endtime,
      LEAD(starttime) OVER (PARTITION BY stay_id ORDER BY starttime NULLS FIRST),
      outtime + INTERVAL '2' HOUR
    ) AS endtime,
    weight,
    weight_type
  FROM wt_stg3
), wt_fix AS (
  SELECT
    ie.stay_id,
    ie.intime - INTERVAL '2' HOUR AS starttime,
    wt.starttime AS endtime,
    wt.weight,
    wt.weight_type
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN (
    SELECT
      wt1.stay_id,
      wt1.starttime,
      wt1.weight,
      weight_type,
      ROW_NUMBER() OVER (PARTITION BY wt1.stay_id ORDER BY wt1.starttime NULLS FIRST) AS rn
    FROM wt1
  ) AS wt
    ON ie.stay_id = wt.stay_id AND wt.rn = 1 AND ie.intime < wt.starttime
)
SELECT
  wt1.stay_id,
  wt1.starttime,
  wt1.endtime,
  wt1.weight,
  wt1.weight_type
FROM wt1
UNION ALL
SELECT
  wt_fix.stay_id,
  wt_fix.starttime,
  wt_fix.endtime,
  wt_fix.weight,
  wt_fix.weight_type
FROM wt_fix