-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.weight_durations; CREATE TABLE mimiciii_derived.weight_durations AS
/* This query extracts weights for adult ICU patients with start/stop times */ /* if an admission weight is given, then this is assigned from intime to outtime */ /* This query extracts weights for adult ICU patients with start/stop times */ /* if an admission weight is given, then this is assigned from intime to outtime */
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
    AND /* wt_oz/wt_lb/wt_kg are only 0 erroneously, so drop these rows */ c.valuenum > 0
  /* a separate query was run to manually verify only 1 value exists per */ /* icustay_id/charttime/itemid grouping */ /* therefore, we can use max() across itemid to collapse these values to 1 row per group */
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
          WHEN c.value ~ '[^0-9\.]'
          THEN NULL
          WHEN CAST(c.value AS DECIMAL(38, 9)) > 100
          THEN CAST(c.value AS DECIMAL(38, 9)) / 1000
          WHEN CAST(c.value AS DECIMAL(38, 9)) < 10
          THEN CAST(c.value AS DECIMAL(38, 9))
          ELSE NULL
        END /* clean free-text birth weight data */
        WHEN c.itemid = 3723 AND c.valuenum < 10
        THEN c.valuenum
        ELSE NULL
      END
    ) AS wt_kg
  FROM mimiciii.chartevents AS c
  WHERE
    c.itemid IN (3723, 4183) AND NOT c.icustay_id IS NULL AND COALESCE(c.error, 0) = 0
  /* a separate query was run to manually verify only 1 value exists per */ /* icustay_id/charttime/itemid grouping */ /* therefore, we can use max() across itemid to collapse these values to 1 row per group */
  GROUP BY
    c.icustay_id,
    c.charttime
), wt_stg AS (
  SELECT
    c.icustay_id,
    c.charttime,
    CASE WHEN c.itemid IN (762, 226512) THEN 'admit' ELSE 'daily' END AS weight_type, /* TODO: eliminate obvious outliers if there is a reasonable weight */
    c.valuenum AS weight
  FROM mimiciii.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL
    AND c.itemid IN (762, 226512, /* Admit Wt */763, 224639 /* Daily Weight */)
    AND NOT c.icustay_id IS NULL
    AND c.valuenum > 0
    AND /* exclude rows marked as error */ COALESCE(c.error, 0) = 0
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
    b.charttime, /* birth weight of neonates is treated as admission weight */
    'admit' AS weight_type,
    wt_kg AS weight
  FROM birth_wt AS b
), echo /* get more weights from echo - completes data for ~2500 patients */ /* we only use echo data if there is *no* charted data */ /* we impute the median echo weight for their entire ICU stay */ AS (
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
), wt_stg1 /* assign ascending row number */ AS (
  SELECT
    icustay_id,
    charttime,
    weight_type,
    weight,
    ROW_NUMBER() OVER (PARTITION BY icustay_id, weight_type ORDER BY charttime NULLS FIRST) AS rn
  FROM wt_stg0
  WHERE
    NOT weight IS NULL
), wt_stg2 /* change charttime to intime for the first admission weight recorded */ AS (
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
      GREATEST(outtime, starttime) + INTERVAL '2' HOUR
    ) AS endtime,
    weight
  FROM wt_stg2
), wt1 /* this table is the start/stop times from admit/daily weight in charted data */ AS (
  SELECT
    icustay_id,
    starttime,
    COALESCE(
      endtime,
      LEAD(starttime) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST),
      outtime + INTERVAL '2' HOUR /* impute ICU discharge as the end of the final weight measurement */ /* plus a 2 hour "fuzziness" window */
    ) AS endtime,
    weight
  FROM wt_stg3
), wt_fix /* if the intime for the patient is < the first charted daily weight */ /* then we will have a "gap" at the start of their stay */ /* to prevent this, we look for these gaps and backfill the first weight */ /* this adds (153255-149657)=3598 rows, meaning this fix helps for up to 3598 icustay_id */ AS (
  SELECT
    ie.icustay_id, /* we add a 2 hour "fuzziness" window */
    ie.intime - INTERVAL '2' HOUR AS starttime,
    wt.starttime AS endtime,
    wt.weight
  FROM mimiciii.icustays AS ie
  INNER JOIN (
    /* the below subquery returns one row for each unique icustay_id */ /* the row contains: the first starttime and the corresponding weight */
    SELECT
      wt1.icustay_id,
      wt1.starttime,
      wt1.weight,
      ROW_NUMBER() OVER (PARTITION BY wt1.icustay_id ORDER BY wt1.starttime NULLS FIRST) AS rn
    FROM wt1
  ) AS wt
    ON ie.icustay_id = wt.icustay_id AND wt.rn = 1 AND ie.intime < wt.starttime
)
/* add the backfill rows to the main weight table */
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