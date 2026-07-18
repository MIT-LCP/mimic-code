-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.gcs_first_day; CREATE TABLE mimiciii_derived.gcs_first_day AS
WITH base AS (
  SELECT
    pvt.ICUSTAY_ID,
    pvt.charttime,
    MAX(CASE WHEN pvt.itemid = 454 THEN pvt.valuenum ELSE NULL END) AS GCSMotor,
    MAX(CASE WHEN pvt.itemid = 723 THEN pvt.valuenum ELSE NULL END) AS GCSVerbal,
    MAX(CASE WHEN pvt.itemid = 184 THEN pvt.valuenum ELSE NULL END) AS GCSEyes,
    CASE
      WHEN MAX(CASE WHEN pvt.itemid = 723 THEN pvt.valuenum ELSE NULL END) = 0
      THEN 1
      ELSE 0
    END AS EndoTrachFlag,
    ROW_NUMBER() OVER (PARTITION BY pvt.ICUSTAY_ID ORDER BY pvt.charttime ASC NULLS FIRST) AS rn
  FROM (
    SELECT
      l.ICUSTAY_ID,
      CASE
        WHEN l.ITEMID IN (723, 223900)
        THEN 723
        WHEN l.ITEMID IN (454, 223901)
        THEN 454
        WHEN l.ITEMID IN (184, 220739)
        THEN 184
        ELSE l.ITEMID
      END AS ITEMID,
      CASE
        WHEN l.ITEMID = 723 AND l.VALUE = '1.0 ET/Trach'
        THEN 0
        WHEN l.ITEMID = 223900 AND l.VALUE = 'No Response-ETT'
        THEN 0
        ELSE VALUENUM
      END AS VALUENUM,
      l.CHARTTIME
    FROM mimiciii.chartevents AS l
    INNER JOIN mimiciii.icustays AS b
      ON l.icustay_id = b.icustay_id
    WHERE
      l.ITEMID IN (184, 454, 723, 223900, 223901, 220739)
      AND l.charttime BETWEEN b.intime AND b.intime + INTERVAL '1' DAY
      AND (
        l.error IS NULL OR l.error = 0
      )
  ) AS pvt
  GROUP BY
    pvt.ICUSTAY_ID,
    pvt.charttime
), gcs AS (
  SELECT
    b.*,
    b2.GCSVerbal AS GCSVerbalPrev,
    b2.GCSMotor AS GCSMotorPrev,
    b2.GCSEyes AS GCSEyesPrev,
    CASE
      WHEN b.GCSVerbal = 0
      THEN 15
      WHEN b.GCSVerbal IS NULL AND b2.GCSVerbal = 0
      THEN 15
      WHEN b2.GCSVerbal = 0
      THEN COALESCE(b.GCSMotor, 6) + COALESCE(b.GCSVerbal, 5) + COALESCE(b.GCSEyes, 4)
      ELSE COALESCE(b.GCSMotor, COALESCE(b2.GCSMotor, 6)) + COALESCE(b.GCSVerbal, COALESCE(b2.GCSVerbal, 5)) + COALESCE(b.GCSEyes, COALESCE(b2.GCSEyes, 4))
    END AS GCS
  FROM base AS b
  LEFT JOIN base AS b2
    ON b.ICUSTAY_ID = b2.ICUSTAY_ID
    AND b.rn = b2.rn + 1
    AND b2.charttime > b.charttime - INTERVAL '6' HOUR
), gcs_final AS (
  SELECT
    gcs.*,
    ROW_NUMBER() OVER (
      PARTITION BY gcs.ICUSTAY_ID
      ORDER BY gcs.GCS NULLS FIRST, gcs.charttime NULLS FIRST
    ) AS IsMinGCS
  FROM gcs
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  GCS AS mingcs,
  COALESCE(GCSMotor, GCSMotorPrev) AS gcsmotor,
  COALESCE(GCSVerbal, GCSVerbalPrev) AS gcsverbal,
  COALESCE(GCSEyes, GCSEyesPrev) AS gcseyes,
  EndoTrachFlag AS endotrachflag
FROM mimiciii.icustays AS ie
LEFT JOIN gcs_final AS gs
  ON ie.icustay_id = gs.icustay_id AND gs.IsMinGCS = 1
ORDER BY
  ie.icustay_id NULLS FIRST