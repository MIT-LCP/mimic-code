-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.creatinine_baseline; CREATE TABLE mimiciv_derived.creatinine_baseline AS
/* This query extracts the serum creatinine baselines of adult patients */ /* on each hospital admission. */ /* The baseline is determined by the following rules: */ /*     i. if the lowest creatinine value during this admission is normal (<1.1), */ /*          then use the value */ /*     ii. if the patient is diagnosed with chronic kidney disease (CKD), */ /*          then use the lowest creatinine value during the admission, */ /*          although it may be rather large. */ /*     iii. Otherwise, we estimate the baseline using Simplified MDRD: */ /*          eGFR = 186 × Scr^(-1.154) × Age^(-0.203) × 0.742Female */
WITH p AS (
  SELECT
    ag.subject_id,
    ag.hadm_id,
    ag.age,
    p.gender,
    CASE
      WHEN p.gender = 'F'
      THEN CAST(CAST(CAST(75.0 AS DOUBLE PRECISION) / 186.0 AS DOUBLE PRECISION) / ag.age ^ -0.203 AS DOUBLE PRECISION) / 0.742 ^ CAST(-1 AS DOUBLE PRECISION) / 1.154
      ELSE CAST(CAST(75.0 AS DOUBLE PRECISION) / 186.0 AS DOUBLE PRECISION) / ag.age ^ -0.203 ^ CAST(-1 AS DOUBLE PRECISION) / 1.154
    END AS mdrd_est
  FROM mimiciv_derived.age AS ag
  LEFT JOIN mimiciv_hosp.patients AS p
    ON ag.subject_id = p.subject_id
  WHERE
    ag.age >= 18
), lab AS (
  SELECT
    hadm_id,
    MIN(creatinine) AS scr_min
  FROM mimiciv_derived.chemistry
  GROUP BY
    hadm_id
), ckd AS (
  SELECT
    hadm_id,
    MAX(1) AS ckd_flag
  FROM mimiciv_hosp.diagnoses_icd
  WHERE
    (
      SUBSTR(icd_code, 1, 3) = '585' AND icd_version = 9
    )
    OR (
      SUBSTR(icd_code, 1, 3) = 'N18' AND icd_version = 10
    )
  GROUP BY
    hadm_id
)
SELECT
  p.hadm_id,
  p.gender,
  p.age,
  lab.scr_min,
  COALESCE(ckd.ckd_flag, 0) AS ckd,
  p.mdrd_est,
  CASE
    WHEN lab.scr_min <= 1.1
    THEN scr_min
    WHEN ckd.ckd_flag = 1
    THEN scr_min
    ELSE mdrd_est
  END AS scr_baseline
FROM p
LEFT JOIN lab
  ON p.hadm_id = lab.hadm_id
LEFT JOIN ckd
  ON p.hadm_id = ckd.hadm_id