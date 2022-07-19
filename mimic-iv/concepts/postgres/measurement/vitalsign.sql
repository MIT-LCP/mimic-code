-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS vitalsign; CREATE TABLE vitalsign AS 
-- This query pivots the vital signs for the entire patient stay.
-- Vital signs include heart rate, blood pressure, respiration rate, and temperature
select
    ce.subject_id
  , ce.stay_id
  , ce.charttime
  , AVG(case when itemid in (220045) and valuenum > 0 and valuenum < 300 then valuenum else null end) as heart_rate
  , AVG(case when itemid in (220179,220050) and valuenum > 0 and valuenum < 400 then valuenum else null end) as sbp
  , AVG(case when itemid in (220180,220051) and valuenum > 0 and valuenum < 300 then valuenum else null end) as dbp
  , AVG(case when itemid in (220052,220181,225312) and valuenum > 0 and valuenum < 300 then valuenum else null end) as mbp
  , AVG(case when itemid = 220179 and valuenum > 0 and valuenum < 400 then valuenum else null end) as sbp_ni
  , AVG(case when itemid = 220180 and valuenum > 0 and valuenum < 300 then valuenum else null end) as dbp_ni
  , AVG(case when itemid = 220181 and valuenum > 0 and valuenum < 300 then valuenum else null end) as mbp_ni
  , AVG(case when itemid in (220210,224690) and valuenum > 0 and valuenum < 70 then valuenum else null end) as resp_rate
  , ROUND( CAST( 
      AVG(case when itemid in (223761) and valuenum > 70 and valuenum < 120 then (valuenum-32)/1.8 -- converted to degC in valuenum call
              when itemid in (223762) and valuenum > 10 and valuenum < 50  then valuenum else null end)
     as numeric),2) as temperature
  , MAX(CASE WHEN itemid = 224642 THEN value ELSE NULL END) AS temperature_site
  , AVG(case when itemid in (220277) and valuenum > 0 and valuenum <= 100 then valuenum else null end) as spo2
  , AVG(case when itemid in (225664,220621,226537) and valuenum > 0 then valuenum else null end) as glucose
  FROM mimiciv_icu.chartevents ce
  where ce.stay_id IS NOT NULL
  and ce.itemid in
  (
    220045, -- Heart Rate
    225309, -- ART BP Systolic
    225310, -- ART BP Diastolic
    225312, -- ART BP Mean
    220050, -- Arterial Blood Pressure systolic
    220051, -- Arterial Blood Pressure diastolic
    220052, -- Arterial Blood Pressure mean
    220179, -- Non Invasive Blood Pressure systolic
    220180, -- Non Invasive Blood Pressure diastolic
    220181, -- Non Invasive Blood Pressure mean
    220210, -- Respiratory Rate
    224690, -- Respiratory Rate (Total)
    220277, -- SPO2, peripheral
    -- GLUCOSE, both lab and fingerstick
    225664, -- Glucose finger stick
    220621, -- Glucose (serum)
    226537, -- Glucose (whole blood)
    -- TEMPERATURE
    223762, -- "Temperature Celsius"
    223761,  -- "Temperature Fahrenheit"
    224642 -- Temperature Site
    -- 226329 -- Blood Temperature CCO (C)
)
group by ce.subject_id, ce.stay_id, ce.charttime
;
