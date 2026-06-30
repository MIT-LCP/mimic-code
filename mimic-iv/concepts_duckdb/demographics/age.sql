-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.age; CREATE TABLE mimiciv_derived.age AS
SELECT
  ad.subject_id,
  ad.hadm_id,
  ad.admittime,
  pa.anchor_age,
  pa.anchor_year,
  pa.anchor_age + DATE_DIFF('YEAR', MAKE_TIMESTAMP(pa.anchor_year, 1, 1, 0, 0, 0), ad.admittime) AS age
FROM mimiciv_hosp.admissions AS ad
INNER JOIN mimiciv_hosp.patients AS pa
  ON ad.subject_id = pa.subject_id