-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.explicit; CREATE TABLE mimiciii_derived.explicit AS
/* This code extracts explicit sepsis using ICD-9 diagnosis codes */ /* That is, the two codes 995.92 (severe sepsis) or 785.52 (septic shock) */ /* These codes are extremely specific to sepsis, but have very low sensitivity */ /* From Iwashyna et al. (vs. chart reviews): 100% PPV, 9.3% sens, 100% specificity */
WITH co_dx AS (
  SELECT
    hadm_id, /* sepsis codes */
    MAX(CASE WHEN icd9_code = '99592' THEN 1 ELSE 0 END) AS severe_sepsis,
    MAX(CASE WHEN icd9_code = '78552' THEN 1 ELSE 0 END) AS septic_shock
  FROM mimiciii.diagnoses_icd
  GROUP BY
    hadm_id
)
SELECT
  adm.subject_id,
  adm.hadm_id,
  co_dx.severe_sepsis,
  co_dx.septic_shock,
  CASE WHEN co_dx.severe_sepsis = 1 OR co_dx.septic_shock = 1 THEN 1 ELSE 0 END AS sepsis
FROM mimiciii.admissions AS adm
LEFT JOIN co_dx
  ON adm.hadm_id = co_dx.hadm_id
ORDER BY
  adm.subject_id NULLS FIRST,
  adm.hadm_id NULLS FIRST