-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.meld; CREATE TABLE mimiciv_derived.meld AS
WITH cohort AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.stay_id,
    ie.intime,
    ie.outtime,
    labs.creatinine_max,
    labs.bilirubin_total_max,
    labs.inr_max,
    labs.sodium_min,
    r.dialysis_present AS rrt
  FROM mimiciv_icu.icustays AS ie
  LEFT JOIN mimiciv_derived.first_day_lab AS labs
    ON ie.stay_id = labs.stay_id
  LEFT JOIN mimiciv_derived.first_day_rrt AS r
    ON ie.stay_id = r.stay_id
), score AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    rrt,
    creatinine_max,
    bilirubin_total_max,
    inr_max,
    sodium_min,
    CASE
      WHEN sodium_min IS NULL
      THEN 0.0
      WHEN sodium_min > 137
      THEN 0.0
      WHEN sodium_min < 125
      THEN 12.0
      ELSE 137.0 - sodium_min
    END AS sodium_score,
    CASE
      WHEN rrt = 1 OR creatinine_max > 4.0
      THEN (
        0.957 * LN(4)
      )
      WHEN creatinine_max < 1
      THEN (
        0.957 * LN(1)
      )
      ELSE 0.957 * COALESCE(LN(creatinine_max), LN(1))
    END AS creatinine_score,
    CASE
      WHEN bilirubin_total_max < 1
      THEN 0.378 * LN(1)
      ELSE 0.378 * COALESCE(LN(bilirubin_total_max), LN(1))
    END AS bilirubin_score,
    CASE
      WHEN inr_max < 1
      THEN (
        1.120 * LN(1) + 0.643
      )
      ELSE (
        1.120 * COALESCE(LN(inr_max), LN(1)) + 0.643
      )
    END AS inr_score
  FROM cohort
), score2 AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    rrt,
    creatinine_max,
    bilirubin_total_max,
    inr_max,
    sodium_min,
    creatinine_score,
    sodium_score,
    bilirubin_score,
    inr_score,
    CASE
      WHEN (
        creatinine_score + bilirubin_score + inr_score
      ) > 4
      THEN 40.0
      ELSE ROUND(TRY_CAST(creatinine_score + bilirubin_score + inr_score AS DECIMAL), 1) * 10
    END AS meld_initial
  FROM score
)
SELECT
  subject_id,
  hadm_id,
  stay_id,
  meld_initial,
  CASE
    WHEN meld_initial > 11
    THEN meld_initial + 1.32 * sodium_score - 0.033 * meld_initial * sodium_score
    ELSE meld_initial
  END AS meld,
  rrt,
  creatinine_max,
  bilirubin_total_max,
  inr_max,
  sodium_min
FROM score2