-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.icustay_detail; CREATE TABLE mimiciii_derived.icustay_detail AS
/* ------------------------------------------------------------------ */ /* Title: Detailed information on ICUSTAY_ID */ /* Description: This query provides a useful set of information regarding patient */ /*              ICU stays. The information is combined from the admissions, patients, and */ /*              icustays tables. It includes age, length of stay, sequence, and expiry flags. */ /* MIMIC version: MIMIC-III v1.3 */ /* ------------------------------------------------------------------ */ /* This query extracts useful demographic/administrative information for patient ICU stays */
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id, /* patient level factors */
  pat.gender,
  pat.dod, /* hospital level factors */
  adm.admittime,
  adm.dischtime,
  (CAST(adm.dischtime AS DATE) - CAST(adm.admittime AS DATE)) AS los_hospital,
  CAST(EXTRACT(YEAR FROM ie.intime) - EXTRACT(YEAR FROM pat.dob) AS BIGINT) AS admission_age,
  adm.ethnicity,
  CASE
    WHEN ethnicity IN (
      'WHITE', /*  40996 */
      'WHITE - RUSSIAN', /*    164 */
      'WHITE - OTHER EUROPEAN', /*     81 */
      'WHITE - BRAZILIAN', /*     59 */
      'WHITE - EASTERN EUROPEAN' /*     25 */
    )
    THEN 'white'
    WHEN ethnicity IN (
      'BLACK/AFRICAN AMERICAN', /*   5440 */
      'BLACK/CAPE VERDEAN', /*    200 */
      'BLACK/HAITIAN', /*    101 */
      'BLACK/AFRICAN', /*     44 */
      'CARIBBEAN ISLAND' /*      9 */
    )
    THEN 'black'
    WHEN ethnicity IN (
      'HISPANIC OR LATINO', /*   1696 */
      'HISPANIC/LATINO - PUERTO RICAN', /*    232 */
      'HISPANIC/LATINO - DOMINICAN', /*     78 */
      'HISPANIC/LATINO - GUATEMALAN', /*     40 */
      'HISPANIC/LATINO - CUBAN', /*     24 */
      'HISPANIC/LATINO - SALVADORAN', /*     19 */
      'HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)', /*     13 */
      'HISPANIC/LATINO - MEXICAN', /*     13 */
      'HISPANIC/LATINO - COLOMBIAN', /*      9 */
      'HISPANIC/LATINO - HONDURAN' /*      4 */
    )
    THEN 'hispanic'
    WHEN ethnicity IN (
      'ASIAN', /*   1509 */
      'ASIAN - CHINESE', /*    277 */
      'ASIAN - ASIAN INDIAN', /*     85 */
      'ASIAN - VIETNAMESE', /*     53 */
      'ASIAN - FILIPINO', /*     25 */
      'ASIAN - CAMBODIAN', /*     17 */
      'ASIAN - OTHER', /*     17 */
      'ASIAN - KOREAN', /*     13 */
      'ASIAN - JAPANESE', /*      7 */
      'ASIAN - THAI' /*      4 */
    )
    THEN 'asian'
    WHEN ethnicity IN (
      'AMERICAN INDIAN/ALASKA NATIVE', /*     51 */
      'AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE' /*      3 */
    )
    THEN 'native'
    WHEN ethnicity IN (
      'UNKNOWN/NOT SPECIFIED', /*   4523 */
      'UNABLE TO OBTAIN', /*    814 */
      'PATIENT DECLINED TO ANSWER' /*    559 */
    )
    THEN 'unknown'
    ELSE 'other'
  END AS ethnicity_grouped, /* , 'OTHER' --   1512 */ /* , 'MULTI RACE ETHNICITY' --    130 */ /* , 'PORTUGUESE' --     61 */ /* , 'MIDDLE EASTERN' --     43 */ /* , 'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER' --     18 */ /* , 'SOUTH AMERICAN' --      8 */
  adm.hospital_expire_flag,
  DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) AS hospstay_seq,
  CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime NULLS FIRST) = 1
    THEN TRUE
    ELSE FALSE
  END AS first_hosp_stay, /* icu level factors */
  ie.intime,
  ie.outtime,
  (CAST(ie.outtime AS DATE) - CAST(ie.intime AS DATE)) AS los_icu,
  DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime NULLS FIRST) AS icustay_seq, /* first ICU stay *for the current hospitalization* */
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