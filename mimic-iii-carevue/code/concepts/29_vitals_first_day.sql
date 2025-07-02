drop table if exists vitals_first_day; create table vitals_first_day as 
-- This query pivots the vital signs for the first 24 hours of a patient's stay
-- Vital signs include heart rate, blood pressure, respiration rate, and temperature

select pvt.subject_id, pvt.hadm_id, pvt.icustay_id
  -- easier names
  , min(case when vitalid = 1 then valuenum else null end) as heartrate_min
  , max(case when vitalid = 1 then valuenum else null end) as heartrate_max
  , avg(case when vitalid = 1 then valuenum else null end) as heartrate_mean
  , min(case when vitalid = 2 then valuenum else null end) as sysbp_min
  , max(case when vitalid = 2 then valuenum else null end) as sysbp_max
  , avg(case when vitalid = 2 then valuenum else null end) as sysbp_mean
  , min(case when vitalid = 3 then valuenum else null end) as diasbp_min
  , max(case when vitalid = 3 then valuenum else null end) as diasbp_max
  , avg(case when vitalid = 3 then valuenum else null end) as diasbp_mean
  , min(case when vitalid = 4 then valuenum else null end) as meanbp_min
  , max(case when vitalid = 4 then valuenum else null end) as meanbp_max
  , avg(case when vitalid = 4 then valuenum else null end) as meanbp_mean
  , min(case when vitalid = 5 then valuenum else null end) as resprate_min
  , max(case when vitalid = 5 then valuenum else null end) as resprate_max
  , avg(case when vitalid = 5 then valuenum else null end) as resprate_mean
  , min(case when vitalid = 6 then valuenum else null end) as tempc_min
  , max(case when vitalid = 6 then valuenum else null end) as tempc_max
  , avg(case when vitalid = 6 then valuenum else null end) as tempc_mean
  , min(case when vitalid = 7 then valuenum else null end) as spo2_min
  , max(case when vitalid = 7 then valuenum else null end) as spo2_max
  , avg(case when vitalid = 7 then valuenum else null end) as spo2_mean
  , min(case when vitalid = 8 then valuenum else null end) as glucose_min
  , max(case when vitalid = 8 then valuenum else null end) as glucose_max
  , avg(case when vitalid = 8 then valuenum else null end) as glucose_mean
from 
  (
   select 
    ie.subject_id, ie.hadm_id, ie.icustay_id
    , case
        when itemid in (211) and valuenum > 0 and valuenum < 300 then 1 -- HeartRate
        when itemid in (51,442,455,6701) and valuenum > 0 and valuenum < 400 then 2 -- SysBP
        when itemid in (8368,8440,8441,8555) and valuenum > 0 and valuenum < 300 then 3 -- DiasBP
        when itemid in (456,52,6702,443) and valuenum > 0 and valuenum < 300 then 4 -- MeanBP
        when itemid in (615,618) and valuenum > 0 and valuenum < 70 then 5 -- RespRate
        when itemid in (678) and valuenum > 70 and valuenum < 120  then 6 -- TempF, converted to degC in valuenum call
        when itemid in (676) and valuenum > 10 and valuenum < 50  then 6 -- TempC
        when itemid in (646) and valuenum > 0 and valuenum <= 100 then 7 -- SpO2
        when itemid in (807,811,1529,3745,3744) and valuenum > 0 then 8 -- Glucose
        else null end as vitalid
          -- convert F to C
    , case when itemid in (678) then (valuenum-32)/1.8 else valuenum end as valuenum
    from icustays ie
    left join chartevents ce
      on ie.icustay_id = ce.icustay_id
      and ce.charttime between ie.intime and (ie.intime + interval '1 day')
      and (cast(extract(epoch from (ce.charttime - ie.intime)) as numeric)) > 0
      and (cast(extract(epoch from (ie.outtime - ie.intime))/(60*60) as numeric)) <= 24
      -- exclude rows marked as error
      and (ce.error is null or ce.error = 0)
    where ce.itemid in
      (
       -- HEART RATE
       211, --"Heart Rate"
     
       -- Systolic/diastolic
       51, -- Arterial BP [Systolic]
       442, --  Manual BP [Systolic]
       455, --  NBP [Systolic]
       6701, -- Arterial BP #2 [Systolic]
    
       8368, -- Arterial BP [Diastolic]
       8440, -- Manual BP [Diastolic]
       8441, -- NBP [Diastolic]
       8555, -- Arterial BP #2 [Diastolic]
      
       -- MEAN ARTERIAL PRESSURE
       456, --"NBP Mean"
       52, --"Arterial BP Mean"
       6702, -- Arterial BP Mean #2
       443, --  Manual BP Mean(calc)
    
       -- RESPIRATORY RATE
       618,-- Respiratory Rate
       615,-- Resp Rate (Total)
    
       -- SPO2, peripheral
       646,
      
       -- GLUCOSE, both lab and fingerstick
       807,-- Fingerstick Glucose
       811,-- Glucose (70-105)
       1529,--  Glucose
       3745,--  BloodGlucose
       3744,--  Blood Glucose
    
       -- TEMPERATURE
       676, -- "Temperature C"
       678 -- "Temperature F"
       )
  ) pvt
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id;