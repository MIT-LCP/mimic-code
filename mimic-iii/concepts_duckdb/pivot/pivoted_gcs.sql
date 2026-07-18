-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_gcs; CREATE TABLE mimiciii_derived.pivoted_gcs AS
WITH base AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    MAX(CASE WHEN ce.ITEMID IN (454, 223901) THEN ce.valuenum ELSE NULL END) AS gcsmotor,
    MAX(
      CASE
        WHEN ce.ITEMID = 723 AND ce.VALUE = '1.0 ET/Trach'
        THEN 0
        WHEN ce.ITEMID = 223900 AND ce.VALUE = 'No Response-ETT'
        THEN 0
        WHEN ce.ITEMID IN (723, 223900)
        THEN ce.valuenum
        ELSE NULL
      END
    ) AS gcsverbal,
    MAX(CASE WHEN ce.ITEMID IN (184, 220739) THEN ce.valuenum ELSE NULL END) AS gcseyes,
    MAX(
      CASE
        WHEN ce.ITEMID = 723 AND ce.VALUE = '1.0 ET/Trach'
        THEN 1
        WHEN ce.ITEMID = 223900 AND ce.VALUE = 'No Response-ETT'
        THEN 1
        ELSE 0
      END
    ) AS endotrachflag,
    ROW_NUMBER() OVER (PARTITION BY ce.icustay_id ORDER BY ce.charttime ASC NULLS FIRST) AS rn
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.ITEMID IN (184, 454, 723, 223900, 223901, 220739)
    AND (
      ce.error IS NULL OR ce.error <> 1
    )
  GROUP BY
    ce.icustay_id,
    ce.charttime
), gcs_stg0 AS (
  SELECT
    b.*,
    b2.gcsverbal AS gcsverbalprev,
    b2.gcsmotor AS gcsmotorprev,
    b2.gcseyes AS gcseyesprev,
    CASE
      WHEN b.gcsverbal = 0
      THEN 15
      WHEN b.gcsverbal IS NULL AND b2.gcsverbal = 0
      THEN 15
      WHEN b2.gcsverbal = 0
      THEN COALESCE(b.gcsmotor, 6) + COALESCE(b.gcsverbal, 5) + COALESCE(b.gcseyes, 4)
      ELSE COALESCE(b.gcsmotor, COALESCE(b2.gcsmotor, 6)) + COALESCE(b.gcsverbal, COALESCE(b2.gcsverbal, 5)) + COALESCE(b.gcseyes, COALESCE(b2.gcseyes, 4))
    END AS gcs
  FROM base AS b
  LEFT JOIN base AS b2
    ON b.icustay_id = b2.icustay_id
    AND b.rn = b2.rn + 1
    AND b2.charttime > b.charttime - INTERVAL '6' HOUR
), gcs_stg1 AS (
  SELECT
    gs.icustay_id,
    gs.charttime,
    gs.gcs,
    COALESCE(gcsmotor, gcsmotorprev) AS gcsmotor,
    COALESCE(gcsverbal, gcsverbalprev) AS gcsverbal,
    COALESCE(gcseyes, gcseyesprev) AS gcseyes,
    CASE WHEN COALESCE(gcsmotor, gcsmotorprev) IS NULL THEN 0 ELSE 1 END + CASE WHEN COALESCE(gcsverbal, gcsverbalprev) IS NULL THEN 0 ELSE 1 END + CASE WHEN COALESCE(gcseyes, gcseyesprev) IS NULL THEN 0 ELSE 1 END AS components_measured,
    endotrachflag
  FROM gcs_stg0 AS gs
), gcs_priority AS (
  SELECT
    icustay_id,
    charttime,
    gcs,
    gcsmotor,
    gcsverbal,
    gcseyes,
    endotrachflag,
    ROW_NUMBER() OVER (
      PARTITION BY icustay_id, charttime
      ORDER BY components_measured DESC, endotrachflag NULLS FIRST, gcs NULLS FIRST, charttime DESC
    ) AS rn
  FROM gcs_stg1
)
SELECT
  icustay_id,
  charttime,
  gcs,
  gcsmotor,
  gcsverbal,
  gcseyes,
  endotrachflag
FROM gcs_priority AS gs
WHERE
  rn = 1
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST