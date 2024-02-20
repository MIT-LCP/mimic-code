-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.age; CREATE TABLE mimiciv_derived.age AS
SELECT
  ad.subject_id,
  ad.hadm_id,
  ad.admittime,
  pa.anchor_age,
  pa.anchor_year,
  pa.anchor_age + DATE_DIFF('microseconds', MAKE_TIMESTAMP(pa.anchor_year, 1, 1, 0, 0, 0), ad.admittime)/31556908800000.0 AS age
FROM mimiciv_hosp.admissions AS ad
INNER JOIN mimiciv_hosp.patients AS pa
  ON ad.subject_id = pa.subject_id