-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.icustay_detail; CREATE TABLE mimiciv_derived.icustay_detail AS
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.stay_id, /* patient level factors */
  pat.gender,
  pat.dod, /* hospital level factors */
  adm.admittime,
  adm.dischtime,
  EXTRACT(EPOCH FROM adm.dischtime - adm.admittime) / 86400.0 AS los_hospital, /* calculate the age as anchor_age (60) plus difference between */ /* admit year and the anchor year. */ /* the noqa retains the extra long line so the */ /* convert to postgres bash script works */
  pat.anchor_age + EXTRACT(EPOCH FROM adm.admittime - MAKE_TIMESTAMP(pat.anchor_year, 1, 1, 0, 0, 0)) / 31556908.8 AS admission_age, /* noqa: L016 */
  adm.race,
  adm.hospital_expire_flag,
  DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) AS hospstay_seq,
  CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) = 1
    THEN TRUE
    ELSE FALSE
  END AS first_hosp_stay, /* icu level factors */
  ie.intime AS icu_intime,
  ie.outtime AS icu_outtime,
  ROUND(
    CAST(CAST(EXTRACT(EPOCH FROM ie.outtime - ie.intime) / 3600.0 AS DOUBLE PRECISION) / 24.0 AS DECIMAL),
    2
  ) AS los_icu,
  DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime NULLS FIRST) AS icustay_seq, /* first ICU stay *for the current hospitalization* */
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