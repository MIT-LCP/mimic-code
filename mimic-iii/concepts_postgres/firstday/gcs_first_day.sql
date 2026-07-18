-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.gcs_first_day; CREATE TABLE mimiciii_derived.gcs_first_day AS
/* ITEMIDs used: */ /* CAREVUE */ /*    723 as GCSVerbal */ /*    454 as GCSMotor */ /*    184 as GCSEyes */ /* METAVISION */ /*    223900 GCS - Verbal Response */ /*    223901 GCS - Motor Response */ /*    220739 GCS - Eye Opening */ /* The code combines the ITEMIDs into the carevue itemids, then pivots those */ /* So 223900 is changed to 723, then the ITEMID 723 is pivoted to form GCSVerbal */ /* Note: */ /*  The GCS for sedated patients is defaulted to 15 in this code. */ /*  This is in line with how the data is meant to be collected. */ /*  e.g., from the SAPS II publication: */ /*    For sedated patients, the Glasgow Coma Score before sedation was used. */ /*    This was ascertained either from interviewing the physician who ordered the sedation, */ /*    or by reviewing the patient's medical record. */
WITH base AS (
  SELECT
    pvt.ICUSTAY_ID,
    pvt.charttime, /* Easier names - note we coalesced Metavision and CareVue IDs below */
    MAX(CASE WHEN pvt.itemid = 454 THEN pvt.valuenum ELSE NULL END) AS GCSMotor,
    MAX(CASE WHEN pvt.itemid = 723 THEN pvt.valuenum ELSE NULL END) AS GCSVerbal,
    MAX(CASE WHEN pvt.itemid = 184 THEN pvt.valuenum ELSE NULL END) AS GCSEyes, /* If verbal was set to 0 in the below select, then this is an intubated patient */
    CASE
      WHEN MAX(CASE WHEN pvt.itemid = 723 THEN pvt.valuenum ELSE NULL END) = 0
      THEN 1
      ELSE 0
    END AS EndoTrachFlag,
    ROW_NUMBER() OVER (PARTITION BY pvt.ICUSTAY_ID ORDER BY pvt.charttime ASC NULLS FIRST) AS rn
  FROM (
    SELECT
      l.ICUSTAY_ID, /* merge the ITEMIDs so that the pivot applies to both metavision/carevue data */
      CASE
        WHEN l.ITEMID IN (723, 223900)
        THEN 723
        WHEN l.ITEMID IN (454, 223901)
        THEN 454
        WHEN l.ITEMID IN (184, 220739)
        THEN 184
        ELSE l.ITEMID
      END AS ITEMID, /* convert the data into a number, reserving a value of 0 for ET/Trach */
      CASE
        WHEN l.ITEMID = 723 AND l.VALUE = '1.0 ET/Trach'
        THEN 0 /* carevue */
        WHEN l.ITEMID = 223900 AND l.VALUE = 'No Response-ETT'
        THEN 0 /* metavision */
        ELSE VALUENUM
      END AS VALUENUM,
      l.CHARTTIME
    FROM mimiciii.chartevents AS l
    /* get intime for charttime subselection */
    INNER JOIN mimiciii.icustays AS b
      ON l.icustay_id = b.icustay_id
    /* Isolate the desired GCS variables */
    WHERE
      l.ITEMID IN (
        184, /* 198 -- GCS */ /* GCS components, CareVue */
        454,
        723, /* GCS components, Metavision */
        223900,
        223901,
        220739
      )
      AND /* Only get data for the first 24 hours */ l.charttime BETWEEN b.intime AND b.intime + INTERVAL '1' DAY
      AND /* exclude rows marked as error */ (
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
    b2.GCSEyes AS GCSEyesPrev, /* Calculate GCS, factoring in special case when they are intubated and prev vals */ /* note that the coalesce are used to implement the following if: */ /*  if current value exists, use it */ /*  if previous value exists, use it */ /*  otherwise, default to normal */
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
  /* join to itself within 6 hours to get previous value */
  LEFT JOIN base AS b2
    ON b.ICUSTAY_ID = b2.ICUSTAY_ID
    AND b.rn = b2.rn + 1
    AND b2.charttime > b.charttime - INTERVAL '6' HOUR
), gcs_final AS (
  SELECT
    gcs.*, /* This sorts the data by GCS, so rn=1 is the the lowest GCS values to keep */
    ROW_NUMBER() OVER (
      PARTITION BY gcs.ICUSTAY_ID
      ORDER BY gcs.GCS NULLS FIRST, gcs.charttime NULLS FIRST
    ) AS IsMinGCS
  FROM gcs
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id, /* The minimum GCS is determined by the above row partition, we only join if IsMinGCS=1 */
  GCS AS mingcs,
  COALESCE(GCSMotor, GCSMotorPrev) AS gcsmotor,
  COALESCE(GCSVerbal, GCSVerbalPrev) AS gcsverbal,
  COALESCE(GCSEyes, GCSEyesPrev) AS gcseyes,
  EndoTrachFlag AS endotrachflag
/* subselect down to the cohort of eligible patients */
FROM mimiciii.icustays AS ie
LEFT JOIN gcs_final AS gs
  ON ie.icustay_id = gs.icustay_id AND gs.IsMinGCS = 1
ORDER BY
  ie.icustay_id NULLS FIRST