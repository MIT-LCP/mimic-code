-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.martin; CREATE TABLE mimiciii_derived.martin AS
WITH co_dx AS (
  SELECT
    subject_id,
    hadm_id,
    MAX(
      CASE
        WHEN SUBSTRING(icd9_code, 1, 3) = '038'
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 4) IN ('0202', '7907', '1179', '1125')
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 5) = '11281'
        THEN 1
        ELSE 0
      END
    ) AS sepsis,
    MAX(
      CASE
        WHEN SUBSTRING(icd9_code, 1, 4) IN ('7991')
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 5) IN ('51881', '51882', '51885', '78609')
        THEN 1
        ELSE 0
      END
    ) AS respiratory,
    MAX(
      CASE
        WHEN SUBSTRING(icd9_code, 1, 4) IN ('4580', '7855', '4580', '4588', '4589', '7963')
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 5) IN ('785.51', '785.59')
        THEN 1
        ELSE 0
      END
    ) AS cardiovascular,
    MAX(CASE WHEN SUBSTRING(icd9_code, 1, 3) IN ('584', '580', '585') THEN 1 ELSE 0 END) AS renal,
    MAX(
      CASE
        WHEN SUBSTRING(icd9_code, 1, 3) IN ('570')
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 4) IN ('5722', '5733')
        THEN 1
        ELSE 0
      END
    ) AS hepatic,
    MAX(
      CASE
        WHEN SUBSTRING(icd9_code, 1, 4) IN ('2862', '2866', '2869', '2873', '2874', '2875')
        THEN 1
        ELSE 0
      END
    ) AS hematologic,
    MAX(CASE WHEN SUBSTRING(icd9_code, 1, 4) IN ('2762') THEN 1 ELSE 0 END) AS metabolic,
    MAX(
      CASE
        WHEN SUBSTRING(icd9_code, 1, 3) IN ('293')
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 4) IN ('3481', '3483')
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 5) IN ('78001', '78009')
        THEN 1
        ELSE 0
      END
    ) AS neurologic
  FROM mimiciii.diagnoses_icd
  GROUP BY
    subject_id,
    hadm_id
), co_proc AS (
  SELECT
    subject_id,
    hadm_id,
    MAX(CASE WHEN icd9_code = '967' THEN 1 ELSE 0 END) AS respiratory,
    MAX(CASE WHEN icd9_code = '3995' THEN 1 ELSE 0 END) AS renal,
    MAX(CASE WHEN icd9_code = '8914' THEN 1 ELSE 0 END) AS neurologic
  FROM mimiciii.procedures_icd
  GROUP BY
    subject_id,
    hadm_id
)
SELECT
  adm.subject_id,
  adm.hadm_id,
  co_dx.sepsis,
  CASE
    WHEN co_dx.respiratory = 1
    OR co_proc.respiratory = 1
    OR co_dx.cardiovascular = 1
    OR co_dx.renal = 1
    OR co_proc.renal = 1
    OR co_dx.hepatic = 1
    OR co_dx.hematologic = 1
    OR co_dx.metabolic = 1
    OR co_dx.neurologic = 1
    OR co_proc.neurologic = 1
    THEN 1
    ELSE 0
  END AS organ_failure,
  CASE WHEN co_dx.respiratory = 1 OR co_proc.respiratory = 1 THEN 1 ELSE 0 END AS respiratory,
  co_dx.cardiovascular,
  CASE WHEN co_dx.renal = 1 OR co_proc.renal = 1 THEN 1 ELSE 0 END AS renal,
  co_dx.hepatic,
  co_dx.hematologic,
  co_dx.metabolic,
  CASE WHEN co_dx.neurologic = 1 OR co_proc.neurologic = 1 THEN 1 ELSE 0 END AS neurologic
FROM mimiciii.admissions AS adm
LEFT JOIN co_dx
  ON adm.hadm_id = co_dx.hadm_id
LEFT JOIN co_proc
  ON adm.hadm_id = co_proc.hadm_id