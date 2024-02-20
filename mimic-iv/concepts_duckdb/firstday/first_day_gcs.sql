-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_gcs; CREATE TABLE mimiciv_derived.first_day_gcs AS
WITH gcs_final AS (
  SELECT
    ie.subject_id,
    ie.stay_id,
    g.gcs,
    g.gcs_motor,
    g.gcs_verbal,
    g.gcs_eyes,
    g.gcs_unable,
    ROW_NUMBER() OVER (PARTITION BY g.stay_id ORDER BY g.gcs NULLS FIRST) AS gcs_seq
  FROM mimiciv_icu.icustays AS ie
  LEFT JOIN mimiciv_derived.gcs AS g
    ON ie.stay_id = g.stay_id
    AND g.charttime >= ie.intime - INTERVAL '6' HOUR
    AND g.charttime <= ie.intime + INTERVAL '1' DAY
)
SELECT
  ie.subject_id,
  ie.stay_id,
  gcs AS gcs_min,
  gcs_motor,
  gcs_verbal,
  gcs_eyes,
  gcs_unable
FROM mimiciv_icu.icustays AS ie
LEFT JOIN gcs_final AS gs
  ON ie.stay_id = gs.stay_id AND gs.gcs_seq = 1