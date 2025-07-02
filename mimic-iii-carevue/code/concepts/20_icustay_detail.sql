drop table if exists icustay_detail; create table icustay_detail as 

-- This query extracts useful demographic/administrative information for patient ICU stays

select ie.subject_id, ie.hadm_id, ie.icustay_id

-- patient level factors
, pat.gender, pat.dod

-- hospital level factors
, adm.admittime, adm.dischtime
, round((cast(extract(epoch from (adm.dischtime - adm.admittime))/(60*60*24) as numeric)), 8) as los_hospital
, round((cast(extract(epoch from (ie.intime - pat.dob))/(60*60*24*365) as numeric)), 8) as admission_age
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
, dense_rank() over (partition by adm.subject_id order by adm.admittime) as hospstay_seq
, case
    when dense_rank() over (partition by adm.subject_id order by adm.admittime) = 1 then true
    else false end as first_hosp_stay

-- icu level factors
, ie.intime, ie.outtime
, round((cast(extract(epoch from (ie.outtime - ie.intime))/(60*60*24) as numeric)), 8) as los_icu
, dense_rank() over (partition by ie.hadm_id order by ie.intime) as icustay_seq

-- first ICU stay *for the current hospitalization*
, case
    when dense_rank() over (partition by ie.hadm_id order by ie.intime) = 1 then true
    else false end as first_icu_stay

from icustays ie
inner join admissions adm
    on ie.hadm_id = adm.hadm_id
inner join patients pat
    on ie.subject_id = pat.subject_id
where adm.has_chartevents_data = 1
order by ie.subject_id, adm.admittime, ie.intime;