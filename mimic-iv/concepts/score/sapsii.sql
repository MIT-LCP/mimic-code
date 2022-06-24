-- ------------------------------------------------------------------
-- Title: Simplified Acute Physiology Score II (SAPS II)
-- This query extracts the simplified acute physiology score II.
-- This score is a measure of patient severity of illness.
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for SAPS II:
--    Le Gall, Jean-Roger, Stanley Lemeshow, and Fabienne Saulnier.
--    "A new simplified acute physiology score (SAPS II) based on a European/North American multicenter study."
--    JAMA 270, no. 24 (1993): 2957-2963.

-- Variables used in SAPS II:
--  Age, GCS
--  VITALS: Heart rate, systolic blood pressure, temperature
--  FLAGS: ventilation/cpap
--  IO: urine output
--  LABS: PaO2/FiO2 ratio, blood urea nitrogen, WBC, potassium, sodium, HCO3
with co as
(
    select 
        subject_id
        , hadm_id
        , stay_id
        , intime AS starttime
        , DATETIME_ADD(intime, INTERVAL '24' HOUR) AS endtime
    from `physionet-data.mimiciv_icu.icustays` ie
)
, cpap as
(
  select 
    co.subject_id
    , co.stay_id
    , GREATEST(min(DATETIME_SUB(charttime, INTERVAL '1' HOUR)), co.starttime) as starttime
    , LEAST(max(DATETIME_ADD(charttime, INTERVAL '4' HOUR)), co.endtime) as endtime
    , max(case when REGEXP_CONTAINS(lower(ce.value), '(cpap mask|bipap)') then 1 else 0 end) as cpap
  from co
  inner join `physionet-data.mimiciv_icu.chartevents` ce
    on co.stay_id = ce.stay_id
    and ce.charttime > co.starttime
    and ce.charttime <= co.endtime
  where ce.itemid = 226732
  and REGEXP_CONTAINS(lower(ce.value), '(cpap mask|bipap)')
  group by co.subject_id, co.stay_id, co.starttime,co.endtime
)

-- extract a flag for surgical service
-- this combined with "elective" from admissions table defines elective/non-elective surgery
, surgflag as
(
  select adm.hadm_id
    , case when lower(curr_service) like '%surg%' then 1 else 0 end as surgical
    , ROW_NUMBER() over
    (
      PARTITION BY adm.HADM_ID
      ORDER BY TRANSFERTIME
    ) as serviceOrder
  from `physionet-data.mimiciv_hosp.admissions` adm
  left join `physionet-data.mimiciv_hosp.services` se
    on adm.hadm_id = se.hadm_id
)
-- icd-9 diagnostic codes are our best source for comorbidity information
-- unfortunately, they are technically a-causal
-- however, this shouldn't matter too much for the SAPS II comorbidities
, comorb as
(
select hadm_id
-- these are slightly different than elixhauser comorbidities, but based on them
-- they include some non-comorbid ICD-9 codes (e.g. 20302, relapse of multiple myeloma)
  , MAX(CASE
    WHEN icd_version = 9 AND SUBSTR(icd_code, 1, 3) BETWEEN '042' AND '044'
      THEN 1
    WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) BETWEEN 'B20' AND 'B22' THEN 1
    WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) = 'B24' THEN 1
  ELSE 0 END) AS aids  /* HIV and AIDS */
  , MAX(
    CASE WHEN icd_version = 9 THEN
      CASE
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20000' AND '20238' THEN 1 -- lymphoma
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20240' AND '20248' THEN 1 -- leukemia
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20250' AND '20302' THEN 1 -- lymphoma
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20310' AND '20312' THEN 1 -- leukemia
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20302' AND '20382' THEN 1 -- lymphoma
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20400' AND '20522' THEN 1 -- chronic leukemia
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20580' AND '20702' THEN 1 -- other myeloid leukemia
        WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20720' AND '20892' THEN 1 -- other myeloid leukemia
        WHEN SUBSTR(icd_code, 1, 4) IN ('2386', '2733') then 1 -- lymphoma
      ELSE 0 END
    WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) BETWEEN 'C81' AND 'C96' THEN 1
  ELSE 0 END) as hem
  , MAX(CASE
    WHEN icd_version = 9 THEN
      CASE
      WHEN SUBSTR(icd_code, 1, 4) BETWEEN '1960' AND '1991' THEN 1
      WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20970' AND '20975' THEN 1
      WHEN SUBSTR(icd_code, 1, 5) IN ('20979', '78951') THEN 1
      ELSE 0 END
    WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) BETWEEN 'C77' AND 'C79' THEN 1
    WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 4) = 'C800' THEN 1
    ELSE 0 END) as mets      /* Metastatic cancer */
    from `physionet-data.mimiciv_hosp.diagnoses_icd`
  group by hadm_id
)

, pafi1 as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  -- also join to cpap table for the same purpose
  select 
    co.stay_id
  , bg.charttime
  , pao2fio2ratio AS PaO2FiO2
  , case when vd.stay_id is not null then 1 else 0 end as vent
  , case when cp.subject_id is not null then 1 else 0 end as cpap
  from co
  LEFT JOIN `physionet-data.mimiciv_derived.bg` bg
    ON co.subject_id = bg.subject_id
    AND bg.specimen = 'ART.'
    AND bg.charttime > co.starttime
    AND bg.charttime <= co.endtime
  left join `physionet-data.mimiciv_derived.ventilation` vd
    on co.stay_id = vd.stay_id
    and bg.charttime > vd.starttime
    and bg.charttime <= vd.endtime
    and vd.ventilation_status = 'InvasiveVent'
  left join cpap cp
    on bg.subject_id = cp.subject_id
    and bg.charttime > cp.starttime
    and bg.charttime <= cp.endtime
)
, pafi2 as
(
  -- get the minimum PaO2/FiO2 ratio *only for ventilated/cpap patients*
  select stay_id
  , min(PaO2FiO2) as PaO2FiO2_vent_min
  from pafi1
  where vent = 1 or cpap = 1
  group by stay_id
)

, gcs AS
(
    select co.stay_id
    , MIN(gcs.gcs) AS mingcs
    FROM co
    left join `physionet-data.mimiciv_derived.gcs` gcs
    ON co.stay_id = gcs.stay_id
    AND co.starttime < gcs.charttime
    AND gcs.charttime <= co.endtime
    GROUP BY co.stay_id
)

, vital AS 
(
    SELECT 
        co.stay_id
      , MIN(vital.heart_rate) AS heartrate_min
      , MAX(vital.heart_rate) AS heartrate_max
      , MIN(vital.sbp) AS sysbp_min
      , MAX(vital.sbp) AS sysbp_max
      , MIN(vital.temperature) AS tempc_min
      , MAX(vital.temperature) AS tempc_max
    FROM co
    left join `physionet-data.mimiciv_derived.vitalsign` vital
      on co.subject_id = vital.subject_id
      AND co.starttime < vital.charttime
      AND co.endtime >= vital.charttime
    GROUP BY co.stay_id
)
, uo AS
(
    SELECT 
        co.stay_id
      , SUM(uo.urineoutput) as urineoutput
    FROM co
    left join `physionet-data.mimiciv_derived.urine_output` uo
      on co.stay_id = uo.stay_id
      AND co.starttime < uo.charttime
      AND co.endtime >= uo.charttime
    GROUP BY co.stay_id
)
, labs AS
(
    SELECT 
        co.stay_id
      , MIN(labs.bun) AS bun_min
      , MAX(labs.bun) AS bun_max
      , MIN(labs.potassium) AS potassium_min
      , MAX(labs.potassium) AS potassium_max
      , MIN(labs.sodium) AS sodium_min
      , MAX(labs.sodium) AS sodium_max
      , MIN(labs.bicarbonate) AS bicarbonate_min
      , MAX(labs.bicarbonate) AS bicarbonate_max               
    FROM co
    left join `physionet-data.mimiciv_derived.chemistry` labs
      on co.subject_id = labs.subject_id
      AND co.starttime < labs.charttime
      AND co.endtime >= labs.charttime
    group by co.stay_id
)
, cbc AS
(
    SELECT 
        co.stay_id
      , MIN(cbc.wbc) AS wbc_min
      , MAX(cbc.wbc) AS wbc_max  
    FROM co
    LEFT JOIN `physionet-data.mimiciv_derived.complete_blood_count` cbc
      ON co.subject_id = cbc.subject_id
      AND co.starttime < cbc.charttime
      AND co.endtime >= cbc.charttime
    GROUP BY co.stay_id
)
, enz AS
(
    SELECT 
        co.stay_id
      , MIN(enz.bilirubin_total) AS bilirubin_min
      , MAX(enz.bilirubin_total) AS bilirubin_max  
    FROM co
    LEFT JOIN `physionet-data.mimiciv_derived.enzyme` enz
      ON co.subject_id = enz.subject_id
      AND co.starttime < enz.charttime
      AND co.endtime >= enz.charttime
    GROUP BY co.stay_id
)

, cohort as
(
select 
    ie.subject_id, ie.hadm_id, ie.stay_id
      , ie.intime
      , ie.outtime
      , va.age
      , co.starttime
      , co.endtime
    
      , vital.heartrate_max
      , vital.heartrate_min
      , vital.sysbp_max
      , vital.sysbp_min
      , vital.tempc_max
      , vital.tempc_min

      -- this value is non-null iff the patient is on vent/cpap
      , pf.PaO2FiO2_vent_min

      , uo.urineoutput

      , labs.bun_min
      , labs.bun_max
      , cbc.wbc_min
      , cbc.wbc_max
      , labs.potassium_min
      , labs.potassium_max
      , labs.sodium_min
      , labs.sodium_max
      , labs.bicarbonate_min
      , labs.bicarbonate_max
    
      , enz.bilirubin_min
      , enz.bilirubin_max

      , gcs.mingcs

      , comorb.AIDS
      , comorb.HEM
      , comorb.METS

      , case
          when adm.ADMISSION_TYPE = 'ELECTIVE' and sf.surgical = 1
            then 'ScheduledSurgical'
          when adm.ADMISSION_TYPE != 'ELECTIVE' and sf.surgical = 1
            then 'UnscheduledSurgical'
          else 'Medical'
        end as AdmissionType


from `physionet-data.mimiciv_icu.icustays` ie
inner join `physionet-data.mimiciv_hosp.admissions` adm
  on ie.hadm_id = adm.hadm_id
LEFT JOIN `physionet-data.mimiciv_derived.age` va
  on ie.hadm_id = va.hadm_id
inner join co
  on ie.stay_id = co.stay_id
    
-- join to above views
left join pafi2 pf
  on ie.stay_id = pf.stay_id
left join surgflag sf
  on adm.hadm_id = sf.hadm_id and sf.serviceOrder = 1
left join comorb
  on ie.hadm_id = comorb.hadm_id

-- join to custom tables to get more data....
left join gcs gcs
  on ie.stay_id = gcs.stay_id
left join vital
  on ie.stay_id = vital.stay_id
left join uo
  on ie.stay_id = uo.stay_id
left join labs
  on ie.stay_id = labs.stay_id
left join cbc
  on ie.stay_id = cbc.stay_id
left join enz
  on ie.stay_id = enz.stay_id
)
, scorecomp as
(
select
  cohort.*
  -- Below code calculates the component scores needed for SAPS
  , case
      when age is null then null
      when age <  40 then 0
      when age <  60 then 7
      when age <  70 then 12
      when age <  75 then 15
      when age <  80 then 16
      when age >= 80 then 18
    end as age_score

  , case
      when heartrate_max is null then null
      when heartrate_min <   40 then 11
      when heartrate_max >= 160 then 7
      when heartrate_max >= 120 then 4
      when heartrate_min  <  70 then 2
      when  heartrate_max >= 70 and heartrate_max < 120
        and heartrate_min >= 70 and heartrate_min < 120
      then 0
    end as hr_score

  , case
      when  sysbp_min is null then null
      when  sysbp_min <   70 then 13
      when  sysbp_min <  100 then 5
      when  sysbp_max >= 200 then 2
      when  sysbp_max >= 100 and sysbp_max < 200
        and sysbp_min >= 100 and sysbp_min < 200
        then 0
    end as sysbp_score

  , case
      when tempc_max is null then null
      when tempc_max >= 39.0 then 3
      when tempc_min <  39.0 then 0
    end as temp_score

  , case
      when PaO2FiO2_vent_min is null then null
      when PaO2FiO2_vent_min <  100 then 11
      when PaO2FiO2_vent_min <  200 then 9
      when PaO2FiO2_vent_min >= 200 then 6
    end as PaO2FiO2_score

  , case
      when UrineOutput is null then null
      when UrineOutput <   500.0 then 11
      when UrineOutput <  1000.0 then 4
      when UrineOutput >= 1000.0 then 0
    end as uo_score

  , case
      when bun_max is null then null
      when bun_max <  28.0 then 0
      when bun_max <  84.0 then 6
      when bun_max >= 84.0 then 10
    end as bun_score

  , case
      when wbc_max is null then null
      when wbc_min <   1.0 then 12
      when wbc_max >= 20.0 then 3
      when wbc_max >=  1.0 and wbc_max < 20.0
       and wbc_min >=  1.0 and wbc_min < 20.0
        then 0
    end as wbc_score

  , case
      when potassium_max is null then null
      when potassium_min <  3.0 then 3
      when potassium_max >= 5.0 then 3
      when potassium_max >= 3.0 and potassium_max < 5.0
       and potassium_min >= 3.0 and potassium_min < 5.0
        then 0
      end as potassium_score

  , case
      when sodium_max is null then null
      when sodium_min  < 125 then 5
      when sodium_max >= 145 then 1
      when sodium_max >= 125 and sodium_max < 145
       and sodium_min >= 125 and sodium_min < 145
        then 0
      end as sodium_score

  , case
      when bicarbonate_max is null then null
      when bicarbonate_min <  15.0 then 5
      when bicarbonate_min <  20.0 then 3
      when bicarbonate_max >= 20.0
       and bicarbonate_min >= 20.0
          then 0
      end as bicarbonate_score

  , case
      when bilirubin_max is null then null
      when bilirubin_max  < 4.0 then 0
      when bilirubin_max  < 6.0 then 4
      when bilirubin_max >= 6.0 then 9
      end as bilirubin_score

   , case
      when mingcs is null then null
        when mingcs <  3 then null -- erroneous value/on trach
        when mingcs <  6 then 26
        when mingcs <  9 then 13
        when mingcs < 11 then 7
        when mingcs < 14 then 5
        when mingcs >= 14
         and mingcs <= 15
          then 0
        end as gcs_score

    , case
        when AIDS = 1 then 17
        when HEM  = 1 then 10
        when METS = 1 then 9
        else 0
      end as comorbidity_score

    , case
        when AdmissionType = 'ScheduledSurgical' then 0
        when AdmissionType = 'Medical' then 6
        when AdmissionType = 'UnscheduledSurgical' then 8
        else null
      end as admissiontype_score

from cohort
)
-- Calculate SAPS II here so we can use it in the probability calculation below
, score as
(
  select s.*
  -- coalesce statements impute normal score of zero if data element is missing
  , coalesce(age_score,0)
  + coalesce(hr_score,0)
  + coalesce(sysbp_score,0)
  + coalesce(temp_score,0)
  + coalesce(PaO2FiO2_score,0)
  + coalesce(uo_score,0)
  + coalesce(bun_score,0)
  + coalesce(wbc_score,0)
  + coalesce(potassium_score,0)
  + coalesce(sodium_score,0)
  + coalesce(bicarbonate_score,0)
  + coalesce(bilirubin_score,0)
  + coalesce(gcs_score,0)
  + coalesce(comorbidity_score,0)
  + coalesce(admissiontype_score,0)
    as SAPSII
  from scorecomp s
)
select s.subject_id, s.hadm_id, s.stay_id
, s.starttime
, s.endtime
, sapsii
, 1 / (1 + exp(- (-7.7631 + 0.0737*(SAPSII) + 0.9971*(ln(SAPSII + 1))) )) as sapsii_prob
, age_score
, hr_score
, sysbp_score
, temp_score
, PaO2FiO2_score
, uo_score
, bun_score
, wbc_score
, potassium_score
, sodium_score
, bicarbonate_score
, bilirubin_score
, gcs_score
, comorbidity_score
, admissiontype_score
from score s
;
