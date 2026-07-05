-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.icustay_detail; CREATE TABLE mimiciv_derived.icustay_detail AS
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.stay_id,
  pat.gender,
  pat.dod,
  adm.admittime,
  adm.dischtime,
  DATE_DIFF('DAY', adm.admittime, adm.dischtime) AS los_hospital,
  pat.anchor_age + DATE_DIFF('YEAR', MAKE_TIMESTAMP(pat.anchor_year, 1, 1, 0, 0, 0), adm.admittime) AS admission_age,
  adm.race,
  adm.hospital_expire_flag,
  DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) AS hospstay_seq,
  CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) = 1
    THEN TRUE
    ELSE FALSE
  END AS first_hosp_stay,
  ie.intime AS icu_intime,
  ie.outtime AS icu_outtime,
  ROUND(CAST(DATE_DIFF('HOUR', ie.intime, ie.outtime) / 24.0 AS DECIMAL(38, 9)), 2) AS los_icu,
  DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime NULLS FIRST) AS icustay_seq,
  CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime NULLS FIRST) = 1
    THEN TRUE
    ELSE FALSE
  END AS first_icu_stay
FROM mimiciv_icu.icustays AS ie
INNER JOIN mimiciv_hosp.admissions AS adm
  ON ie.hadm_id = adm.hadm_id
INNER JOIN mimiciv_hosp.patients AS pat
  ON ie.subject_id = pat.subject_id