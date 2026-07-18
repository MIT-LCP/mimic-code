-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.icustay_detail; CREATE TABLE mimiciii_derived.icustay_detail AS
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  pat.gender,
  pat.dod,
  adm.admittime,
  adm.dischtime,
  DATE_DIFF('DAY', adm.admittime, adm.dischtime) AS los_hospital,
  DATE_DIFF('YEAR', pat.dob, ie.intime) AS admission_age,
  adm.ethnicity,
  CASE
    WHEN ethnicity IN (
      'WHITE',
      'WHITE - RUSSIAN',
      'WHITE - OTHER EUROPEAN',
      'WHITE - BRAZILIAN',
      'WHITE - EASTERN EUROPEAN'
    )
    THEN 'white'
    WHEN ethnicity IN (
      'BLACK/AFRICAN AMERICAN',
      'BLACK/CAPE VERDEAN',
      'BLACK/HAITIAN',
      'BLACK/AFRICAN',
      'CARIBBEAN ISLAND'
    )
    THEN 'black'
    WHEN ethnicity IN (
      'HISPANIC OR LATINO',
      'HISPANIC/LATINO - PUERTO RICAN',
      'HISPANIC/LATINO - DOMINICAN',
      'HISPANIC/LATINO - GUATEMALAN',
      'HISPANIC/LATINO - CUBAN',
      'HISPANIC/LATINO - SALVADORAN',
      'HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)',
      'HISPANIC/LATINO - MEXICAN',
      'HISPANIC/LATINO - COLOMBIAN',
      'HISPANIC/LATINO - HONDURAN'
    )
    THEN 'hispanic'
    WHEN ethnicity IN (
      'ASIAN',
      'ASIAN - CHINESE',
      'ASIAN - ASIAN INDIAN',
      'ASIAN - VIETNAMESE',
      'ASIAN - FILIPINO',
      'ASIAN - CAMBODIAN',
      'ASIAN - OTHER',
      'ASIAN - KOREAN',
      'ASIAN - JAPANESE',
      'ASIAN - THAI'
    )
    THEN 'asian'
    WHEN ethnicity IN (
      'AMERICAN INDIAN/ALASKA NATIVE',
      'AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE'
    )
    THEN 'native'
    WHEN ethnicity IN ('UNKNOWN/NOT SPECIFIED', 'UNABLE TO OBTAIN', 'PATIENT DECLINED TO ANSWER')
    THEN 'unknown'
    ELSE 'other'
  END AS ethnicity_grouped,
  adm.hospital_expire_flag,
  DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) AS hospstay_seq,
  CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) = 1
    THEN TRUE
    ELSE FALSE
  END AS first_hosp_stay,
  ie.intime,
  ie.outtime,
  DATE_DIFF('DAY', ie.intime, ie.outtime) AS los_icu,
  DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime NULLS FIRST) AS icustay_seq,
  CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime NULLS FIRST) = 1
    THEN TRUE
    ELSE FALSE
  END AS first_icu_stay
FROM mimiciii.icustays AS ie
INNER JOIN mimiciii.admissions AS adm
  ON ie.hadm_id = adm.hadm_id
INNER JOIN mimiciii.patients AS pat
  ON ie.subject_id = pat.subject_id
WHERE
  adm.has_chartevents_data = 1
ORDER BY
  ie.subject_id NULLS FIRST,
  adm.admittime NULLS FIRST,
  ie.intime NULLS FIRST