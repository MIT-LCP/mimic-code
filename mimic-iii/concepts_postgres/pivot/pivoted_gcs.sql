-- =====================================================================
-- PostgreSQL version of BigQuery pivoted-gcs.sql (MIMIC-III)
-- Output table:
--   mimiciii_derived.pivoted_gcs
--
-- Source:
--   mimiciii_clinical.chartevents
-- =====================================================================

DROP TABLE IF EXISTS mimiciii_derived.pivoted_gcs;

CREATE TABLE mimiciii_derived.pivoted_gcs AS
WITH base AS
(
  SELECT
      ce.icustay_id
    , ce.charttime
    , MAX(CASE WHEN ce.itemid IN (454, 223901) THEN ce.valuenum ELSE NULL END) AS gcsmotor
    , MAX(
        CASE
          WHEN ce.itemid = 723    AND ce.value = '1.0 ET/Trach'      THEN 0
          WHEN ce.itemid = 223900 AND ce.value = 'No Response-ETT'   THEN 0
          WHEN ce.itemid IN (723, 223900)                           THEN ce.valuenum
          ELSE NULL
        END
      ) AS gcsverbal
    , MAX(CASE WHEN ce.itemid IN (184, 220739) THEN ce.valuenum ELSE NULL END) AS gcseyes
    , MAX(
        CASE
          WHEN ce.itemid = 723    AND ce.value = '1.0 ET/Trach'    THEN 1
          WHEN ce.itemid = 223900 AND ce.value = 'No Response-ETT' THEN 1
          ELSE 0
        END
      ) AS endotrachflag
    , ROW_NUMBER() OVER (PARTITION BY ce.icustay_id ORDER BY ce.charttime ASC) AS rn
  FROM mimiciii_clinical.chartevents ce
  WHERE ce.itemid IN
  (
    184, 454, 723,
    223900, 223901, 220739
  )
    AND (ce.error IS NULL OR ce.error != 1)
    AND ce.charttime IS NOT NULL
  GROUP BY ce.icustay_id, ce.charttime
)
, gcs_stg0 AS
(
  SELECT
      b.*
    , b2.gcsverbal AS gcsverbalprev
    , b2.gcsmotor  AS gcsmotorprev
    , b2.gcseyes   AS gcseyesprev
    , CASE
        -- replace GCS during sedation with 15
        WHEN b.gcsverbal = 0 THEN 15
        WHEN b.gcsverbal IS NULL AND b2.gcsverbal = 0 THEN 15

        -- if previously they were intub, but they aren't now, do not use previous GCS values
        WHEN b2.gcsverbal = 0 THEN
            COALESCE(b.gcsmotor, 6)
          + COALESCE(b.gcsverbal, 5)
          + COALESCE(b.gcseyes,  4)

        -- otherwise, add up normally, imputing previous if missing now
        ELSE
            COALESCE(b.gcsmotor, COALESCE(b2.gcsmotor, 6))
          + COALESCE(b.gcsverbal, COALESCE(b2.gcsverbal, 5))
          + COALESCE(b.gcseyes,  COALESCE(b2.gcseyes,  4))
      END AS gcs
  FROM base b
  LEFT JOIN base b2
    ON b.icustay_id = b2.icustay_id
   AND b.rn = b2.rn + 1
   AND b2.charttime > (b.charttime - INTERVAL '6' HOUR)
)
, gcs_stg1 AS
(
  SELECT
      gs.icustay_id
    , gs.charttime
    , gs.gcs
    , COALESCE(gcsmotor, gcsmotorprev) AS gcsmotor
    , COALESCE(gcsverbal, gcsverbalprev) AS gcsverbal
    , COALESCE(gcseyes, gcseyesprev) AS gcseyes
    , (CASE WHEN COALESCE(gcsmotor, gcsmotorprev) IS NULL THEN 0 ELSE 1 END
     + CASE WHEN COALESCE(gcsverbal, gcsverbalprev) IS NULL THEN 0 ELSE 1 END
     + CASE WHEN COALESCE(gcseyes,  gcseyesprev)  IS NULL THEN 0 ELSE 1 END) AS components_measured
    , endotrachflag
  FROM gcs_stg0 gs
)
, gcs_priority AS
(
  SELECT
      icustay_id
    , charttime
    , gcs
    , gcsmotor
    , gcsverbal
    , gcseyes
    , endotrachflag
    , ROW_NUMBER() OVER
      (
        PARTITION BY icustay_id, charttime
        ORDER BY components_measured DESC, endotrachflag, gcs, charttime DESC
      ) AS rn
  FROM gcs_stg1
)
SELECT
    icustay_id
  , charttime
  , gcs
  , gcsmotor
  , gcsverbal
  , gcseyes
  , endotrachflag
FROM gcs_priority
WHERE rn = 1
ORDER BY icustay_id, charttime;

-- Suggested index (optional)
-- CREATE INDEX IF NOT EXISTS idx_pivoted_gcs_icustay_charttime
--   ON mimiciii_derived.pivoted_gcs (icustay_id, charttime);
