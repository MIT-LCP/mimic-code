-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_gcs; CREATE TABLE mimiciii_derived.pivoted_gcs AS
/* This query extracts the Glasgow Coma Scale, a measure of neurological function. */ /* The query has a few special rules: */ /*    (1) The verbal component can be set to 0 if the patient is ventilated. */ /*    This is corrected to 5 - the overall GCS is set to 15 in these cases. */ /*    (2) Often only one of three components is documented. The other components */ /*    are carried forward. */ /* ITEMIDs used: */ /* CAREVUE */ /*    723 as gcsverbal */ /*    454 as gcsmotor */ /*    184 as gcseyes */ /* METAVISION */ /*    223900 GCS - Verbal Response */ /*    223901 GCS - Motor Response */ /*    220739 GCS - Eye Opening */ /* The code combines the ITEMIDs into the carevue itemids, then pivots those */ /* So 223900 is changed to 723, then the ITEMID 723 is pivoted to form gcsverbal */ /* Note: */ /*  The GCS for sedated patients is defaulted to 15 in this code. */ /*  This is in line with how the data is meant to be collected. */ /*  e.g., from the SAPS II publication: */ /*    For sedated patients, the Glasgow Coma Score before sedation was used. */ /*    This was ascertained either from interviewing the physician who ordered the sedation, */ /*    or by reviewing the patient's medical record. */
WITH base AS (
  SELECT
    ce.icustay_id,
    ce.charttime, /* pivot each value into its own column */
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
    MAX(CASE WHEN ce.ITEMID IN (184, 220739) THEN ce.valuenum ELSE NULL END) AS gcseyes, /* convert the data into a number, reserving a value of 0 for ET/Trach */
    MAX(
      CASE
        WHEN ce.ITEMID = 723 AND ce.VALUE = '1.0 ET/Trach'
        THEN 1 /* carevue */
        WHEN ce.ITEMID = 223900 AND ce.VALUE = 'No Response-ETT'
        THEN 1 /* metavision */
        ELSE 0
      END
    ) AS endotrachflag,
    ROW_NUMBER() OVER (PARTITION BY ce.icustay_id ORDER BY ce.charttime ASC NULLS FIRST) AS rn
  FROM mimiciii.chartevents AS ce
  /* Isolate the desired GCS variables */
  WHERE
    ce.ITEMID IN (
      184, /* 198 -- GCS */ /* GCS components, CareVue */
      454,
      723, /* GCS components, Metavision */
      223900,
      223901,
      220739
    )
    AND /* exclude rows marked as error */ (
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
    b2.gcseyes AS gcseyesprev, /* Calculate GCS, factoring in special case when they are intubated and prev vals */ /* note that the coalesce are used to implement the following if: */ /*  if current value exists, use it */ /*  if previous value exists, use it */ /*  otherwise, default to normal */
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
  /* join to itself within 6 hours to get previous value */
  LEFT JOIN base AS b2
    ON b.icustay_id = b2.icustay_id
    AND b.rn = b2.rn + 1
    AND b2.charttime > b.charttime - INTERVAL '6' HOUR
), gcs_stg1 /* combine components with previous within 6 hours */ /* filter down to cohort which is not excluded */ /* truncate charttime to the hour */ AS (
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
), gcs_priority /* priority is: */ /*  (i) complete data, (ii) non-sedated GCS, (iii) lowest GCS, (iv) charttime */ AS (
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
      ORDER BY components_measured DESC NULLS LAST, endotrachflag NULLS FIRST, gcs NULLS FIRST, charttime DESC NULLS LAST
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