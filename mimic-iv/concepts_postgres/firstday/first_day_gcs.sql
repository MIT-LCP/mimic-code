-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_gcs; CREATE TABLE mimiciv_derived.first_day_gcs AS
/* Glasgow Coma Scale, a measure of neurological function. */ /* Ranges from 3 (worst, comatose) to 15 (best, normal function). */ /* Note: */ /* The GCS for sedated patients is defaulted to 15 in this code. */ /* This follows common practice for scoring patients with severity */ /* of illness scores. */ /*  e.g., from the SAPS II publication: */ /*    For sedated patients, the Glasgow Coma Score before sedation was used. */ /*    This was ascertained either from interviewing the physician who ordered */ /*    the sedation, or by reviewing the patient's medical record. */
WITH gcs_final AS (
  SELECT
    ie.subject_id,
    ie.stay_id,
    g.gcs,
    g.gcs_motor,
    g.gcs_verbal,
    g.gcs_eyes,
    g.gcs_unable, /* This sorts the data by GCS */ /* rn = 1 is the the lowest total GCS value */
    ROW_NUMBER() OVER (PARTITION BY g.stay_id ORDER BY g.gcs NULLS FIRST) AS gcs_seq
  FROM mimiciv_icu.icustays AS ie
  /* Only get data for the first 24 hours */
  LEFT JOIN mimiciv_derived.gcs AS g
    ON ie.stay_id = g.stay_id
    AND g.charttime >= ie.intime - INTERVAL '6 HOUR'
    AND g.charttime <= ie.intime + INTERVAL '1 DAY'
)
SELECT
  ie.subject_id,
  ie.stay_id, /* The minimum GCS is determined by the above row partition */ /* we only join if gcs_seq = 1 */
  gcs AS gcs_min,
  gcs_motor,
  gcs_verbal,
  gcs_eyes,
  gcs_unable
FROM mimiciv_icu.icustays AS ie
LEFT JOIN gcs_final AS gs
  ON ie.stay_id = gs.stay_id AND gs.gcs_seq = 1