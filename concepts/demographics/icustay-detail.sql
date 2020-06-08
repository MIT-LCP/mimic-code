-- ------------------------------------------------------------------
-- Title: Detailed information on ICUSTAY_ID
-- Description: This query provides a useful set of information regarding patient
--              ICU stays. The information is combined from the admissions, patients, and
--              icustays tables. It includes age, length of stay, sequence, and expiry flags.
-- MIMIC version: MIMIC-III v1.3
-- ------------------------------------------------------------------

-- This query extracts useful demographic/administrative information for patient ICU stays

SELECT ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient level factors
, pat.gender, pat.dod

-- hospital level factors
, adm.admittime, adm.dischtime
, DATETIME_DIFF(adm.dischtime, adm.admittime, DAY) as los_hospital
, DATETIME_DIFF(ie.intime, pat.dob, YEAR) as admission_age
, adm.ethnicity
, case when ethnicity in
  (
       'WHITE' --  40996
     , 'WHITE - RUSSIAN' --    164
     , 'WHITE - OTHER EUROPEAN' --     81
     , 'WHITE - BRAZILIAN' --     59
     , 'WHITE - EASTERN EUROPEAN' --     25
  ) then 'white'
  when ethnicity in
  (
      'BLACK/AFRICAN AMERICAN' --   5440
    , 'BLACK/CAPE VERDEAN' --    200
    , 'BLACK/HAITIAN' --    101
    , 'BLACK/AFRICAN' --     44
    , 'CARIBBEAN ISLAND' --      9
  ) then 'black'
  when ethnicity in
    (
      'HISPANIC OR LATINO' --   1696
    , 'HISPANIC/LATINO - PUERTO RICAN' --    232
    , 'HISPANIC/LATINO - DOMINICAN' --     78
    , 'HISPANIC/LATINO - GUATEMALAN' --     40
    , 'HISPANIC/LATINO - CUBAN' --     24
    , 'HISPANIC/LATINO - SALVADORAN' --     19
    , 'HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)' --     13
    , 'HISPANIC/LATINO - MEXICAN' --     13
    , 'HISPANIC/LATINO - COLOMBIAN' --      9
    , 'HISPANIC/LATINO - HONDURAN' --      4
  ) then 'hispanic'
  when ethnicity in
  (
      'ASIAN' --   1509
    , 'ASIAN - CHINESE' --    277
    , 'ASIAN - ASIAN INDIAN' --     85
    , 'ASIAN - VIETNAMESE' --     53
    , 'ASIAN - FILIPINO' --     25
    , 'ASIAN - CAMBODIAN' --     17
    , 'ASIAN - OTHER' --     17
    , 'ASIAN - KOREAN' --     13
    , 'ASIAN - JAPANESE' --      7
    , 'ASIAN - THAI' --      4
  ) then 'asian'
  when ethnicity in
  (
       'AMERICAN INDIAN/ALASKA NATIVE' --     51
     , 'AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE' --      3
  ) then 'native'
  when ethnicity in
  (
      'UNKNOWN/NOT SPECIFIED' --   4523
    , 'UNABLE TO OBTAIN' --    814
    , 'PATIENT DECLINED TO ANSWER' --    559
  ) then 'unknown'
  else 'other' end as ethnicity_grouped
  -- , 'OTHER' --   1512
  -- , 'MULTI RACE ETHNICITY' --    130
  -- , 'PORTUGUESE' --     61
  -- , 'MIDDLE EASTERN' --     43
  -- , 'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER' --     18
  -- , 'SOUTH AMERICAN' --      8
, adm.hospital_expire_flag
, DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) AS hospstay_seq
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY adm.subject_id ORDER BY adm.admittime) = 1 THEN True
    ELSE False END AS first_hosp_stay

-- icu level factors
, ie.intime, ie.outtime
, DATETIME_DIFF(ie.outtime, ie.intime, DAY) as los_icu
, DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) AS icustay_seq

-- first ICU stay *for the current hospitalization*
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) = 1 THEN True
    ELSE False END AS first_icu_stay

FROM `physionet-data.mimiciii_clinical.icustays` ie
INNER JOIN `physionet-data.mimiciii_clinical.admissions` adm
    ON ie.hadm_id = adm.hadm_id
INNER JOIN `physionet-data.mimiciii_clinical.patients` pat
    ON ie.subject_id = pat.subject_id
WHERE adm.has_chartevents_data = 1
ORDER BY ie.subject_id, adm.admittime, ie.intime;
