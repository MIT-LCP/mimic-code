-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.weight_durations; CREATE TABLE mimiciii_derived.weight_durations AS
WITH wt_neonate AS (
  SELECT
    c.icustay_id,
    c.charttime,
    MAX(CASE WHEN c.itemid = 3580 THEN c.valuenum END) AS wt_kg,
    MAX(CASE WHEN c.itemid = 3581 THEN c.valuenum END) AS wt_lb,
    MAX(CASE WHEN c.itemid = 3582 THEN c.valuenum END) AS wt_oz
  FROM mimiciii.chartevents AS c
  WHERE
    c.itemid IN (3580, 3581, 3582)
    AND NOT c.icustay_id IS NULL
    AND COALESCE(c.error, 0) = 0
    AND c.valuenum > 0
  GROUP BY
    c.icustay_id,
    c.charttime
), birth_wt AS (
  SELECT
    c.icustay_id,
    c.charttime,
    MAX(
      CASE
        WHEN c.itemid = 4183
        THEN CASE
          WHEN REGEXP_MATCHES(c.value, '[^0-9\.]')
          THEN NULL
          WHEN CAST(c.value AS DECIMAL(38, 9)) > 100
          THEN CAST(c.value AS DECIMAL(38, 9)) / 1000
          WHEN CAST(c.value AS DECIMAL(38, 9)) < 10
          THEN CAST(c.value AS DECIMAL(38, 9))
          ELSE NULL
        END
        WHEN c.itemid = 3723 AND c.valuenum < 10
        THEN c.valuenum
        ELSE NULL
      END
    ) AS wt_kg
  FROM mimiciii.chartevents AS c
  WHERE
    c.itemid IN (3723, 4183) AND NOT c.icustay_id IS NULL AND COALESCE(c.error, 0) = 0
  GROUP BY
    c.icustay_id,
    c.charttime
), wt_stg AS (
  SELECT
    c.icustay_id,
    c.charttime,
    CASE WHEN c.itemid IN (762, 226512) THEN 'admit' ELSE 'daily' END AS weight_type,
    c.valuenum AS weight
  FROM mimiciii.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL
    AND c.itemid IN (762, 226512, 763, 224639)
    AND NOT c.icustay_id IS NULL
    AND c.valuenum > 0
    AND COALESCE(c.error, 0) = 0
  UNION ALL
  SELECT
    n.icustay_id,
    n.charttime,
    'daily' AS weight_type,
    CASE
      WHEN NOT wt_kg IS NULL
      THEN wt_kg
      WHEN NOT wt_lb IS NULL
      THEN wt_lb * 0.45359237 + wt_oz * 0.0283495231
      ELSE NULL
    END AS weight
  FROM wt_neonate AS n
  UNION ALL
  SELECT
    b.icustay_id,
    b.charttime,
    'admit' AS weight_type,
    wt_kg AS weight
  FROM birth_wt AS b
), echo AS (
  SELECT
    ie.icustay_id,
    ec.charttime,
    'echo' AS weight_type,
    0.453592 * ec.weight AS weight
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii_derived.echo_data AS ec
    ON ie.hadm_id = ec.hadm_id
  WHERE
    NOT ec.weight IS NULL
    AND NOT ie.icustay_id IN (
      SELECT DISTINCT
        icustay_id
      FROM wt_stg
    )
), wt_stg0 AS (
  SELECT
    icustay_id,
    charttime,
    weight_type,
    weight
  FROM wt_stg
  UNION ALL
  SELECT
    icustay_id,
    charttime,
    weight_type,
    weight
  FROM echo
), wt_stg1 AS (
  SELECT
    icustay_id,
    charttime,
    weight_type,
    weight,
    ROW_NUMBER() OVER (PARTITION BY icustay_id, weight_type ORDER BY charttime NULLS FIRST) AS rn
  FROM wt_stg0
  WHERE
    NOT weight IS NULL
), wt_stg2 AS (
  SELECT
    wt_stg1.icustay_id,
    ie.intime,
    ie.outtime,
    CASE
      WHEN wt_stg1.weight_type = 'admit' AND wt_stg1.rn = 1
      THEN ie.intime - INTERVAL '2' HOUR
      ELSE wt_stg1.charttime
    END AS starttime,
    wt_stg1.weight
  FROM wt_stg1
  INNER JOIN mimiciii.icustays AS ie
    ON ie.icustay_id = wt_stg1.icustay_id
), wt_stg3 AS (
  SELECT
    icustay_id,
    intime,
    outtime,
    starttime,
    COALESCE(
      LEAD(starttime) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST),
      CASE
        WHEN outtime IS NULL OR starttime IS NULL
        THEN NULL
        ELSE GREATEST(outtime, starttime)
      END + INTERVAL '2' HOUR
    ) AS endtime,
    weight
  FROM wt_stg2
), wt1 AS (
  SELECT
    icustay_id,
    starttime,
    COALESCE(
      endtime,
      LEAD(starttime) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST),
      outtime + INTERVAL '2' HOUR
    ) AS endtime,
    weight
  FROM wt_stg3
), wt_fix AS (
  SELECT
    ie.icustay_id,
    ie.intime - INTERVAL '2' HOUR AS starttime,
    wt.starttime AS endtime,
    wt.weight
  FROM mimiciii.icustays AS ie
  INNER JOIN (
    SELECT
      wt1.icustay_id,
      wt1.starttime,
      wt1.weight,
      ROW_NUMBER() OVER (PARTITION BY wt1.icustay_id ORDER BY wt1.starttime NULLS FIRST) AS rn
    FROM wt1
  ) AS wt
    ON ie.icustay_id = wt.icustay_id AND wt.rn = 1 AND ie.intime < wt.starttime
)
SELECT
  wt1.icustay_id,
  wt1.starttime,
  wt1.endtime,
  wt1.weight
FROM wt1
UNION ALL
SELECT
  wt_fix.icustay_id,
  wt_fix.starttime,
  wt_fix.endtime,
  wt_fix.weight
FROM wt_fix