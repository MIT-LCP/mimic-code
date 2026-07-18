-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.qsofa; CREATE TABLE mimiciii_derived.qsofa AS
WITH scorecomp AS (
  SELECT
    ie.icustay_id,
    v.sysbp_min,
    v.resprate_max,
    gcs.mingcs
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii_derived.vitals_first_day AS v
    ON ie.icustay_id = v.icustay_id
  LEFT JOIN mimiciii_derived.gcs_first_day AS gcs
    ON ie.icustay_id = gcs.icustay_id
), scorecalc AS (
  SELECT
    icustay_id,
    CASE WHEN sysbp_min IS NULL THEN NULL WHEN sysbp_min <= 100 THEN 1 ELSE 0 END AS sysbp_score,
    CASE WHEN mingcs IS NULL THEN NULL WHEN mingcs <= 13 THEN 1 ELSE 0 END AS gcs_score,
    CASE WHEN resprate_max IS NULL THEN NULL WHEN resprate_max >= 22 THEN 1 ELSE 0 END AS resprate_score
  FROM scorecomp
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  COALESCE(sysbp_score, 0) + COALESCE(gcs_score, 0) + COALESCE(resprate_score, 0) AS qsofa,
  sysbp_score,
  gcs_score,
  resprate_score
FROM mimiciii.icustays AS ie
LEFT JOIN scorecalc AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST