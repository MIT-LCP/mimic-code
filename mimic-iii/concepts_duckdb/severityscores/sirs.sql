-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.sirs; CREATE TABLE mimiciii_derived.sirs AS
WITH bg AS (
  SELECT
    bg.icustay_id,
    MIN(pco2) AS paco2_min
  FROM mimiciii_derived.blood_gas_first_day_arterial AS bg
  WHERE
    specimen_pred = 'ART'
  GROUP BY
    bg.icustay_id
), scorecomp AS (
  SELECT
    ie.icustay_id,
    v.tempc_min,
    v.tempc_max,
    v.heartrate_max,
    v.resprate_max,
    bg.paco2_min,
    l.wbc_min,
    l.wbc_max,
    l.bands_max
  FROM mimiciii.icustays AS ie
  LEFT JOIN bg
    ON ie.icustay_id = bg.icustay_id
  LEFT JOIN mimiciii_derived.vitals_first_day AS v
    ON ie.icustay_id = v.icustay_id
  LEFT JOIN mimiciii_derived.labs_first_day AS l
    ON ie.icustay_id = l.icustay_id
), scorecalc AS (
  SELECT
    icustay_id,
    CASE
      WHEN tempc_min < 36.0
      THEN 1
      WHEN tempc_max > 38.0
      THEN 1
      WHEN tempc_min IS NULL
      THEN NULL
      ELSE 0
    END AS temp_score,
    CASE WHEN heartrate_max > 90.0 THEN 1 WHEN heartrate_max IS NULL THEN NULL ELSE 0 END AS heartrate_score,
    CASE
      WHEN resprate_max > 20.0
      THEN 1
      WHEN paco2_min < 32.0
      THEN 1
      WHEN COALESCE(resprate_max, paco2_min) IS NULL
      THEN NULL
      ELSE 0
    END AS resp_score,
    CASE
      WHEN wbc_min < 4.0
      THEN 1
      WHEN wbc_max > 12.0
      THEN 1
      WHEN bands_max > 10
      THEN 1
      WHEN COALESCE(wbc_min, bands_max) IS NULL
      THEN NULL
      ELSE 0
    END AS wbc_score
  FROM scorecomp
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  COALESCE(temp_score, 0) + COALESCE(heartrate_score, 0) + COALESCE(resp_score, 0) + COALESCE(wbc_score, 0) AS sirs,
  temp_score,
  heartrate_score,
  resp_score,
  wbc_score
FROM mimiciii.icustays AS ie
LEFT JOIN scorecalc AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST