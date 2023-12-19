-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.creatinine_baseline; CREATE TABLE mimiciv_derived.creatinine_baseline AS
WITH p AS (
  SELECT
    ag.subject_id,
    ag.hadm_id,
    ag.age,
    p.gender,
    CASE
      WHEN p.gender = 'F'
      THEN POWER(75.0 / 186.0 / POWER(ag.age, -0.203) / 0.742, -1 / 1.154)
      ELSE POWER(75.0 / 186.0 / POWER(ag.age, -0.203), -1 / 1.154)
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