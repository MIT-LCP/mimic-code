-- This query pivots the vital signs for the first 24 hours of a patient's stay
-- Vital signs include heart rate, blood pressure, respiration rate, and temperature

SELECT pvt.subject_id, pvt.hadm_id, pvt.icustay_id

-- Easier names
, min(case when VitalID = 1 then valuenum ELSE NULL END) AS heartrate_min
, max(case when VitalID = 1 then valuenum ELSE NULL END) AS heartrate_max
, avg(case when VitalID = 1 then valuenum ELSE NULL END) AS heartrate_mean
, min(case when VitalID = 2 then valuenum ELSE NULL END) AS sysbp_min
, max(case when VitalID = 2 then valuenum ELSE NULL END) AS sysbp_max
, avg(case when VitalID = 2 then valuenum ELSE NULL END) AS sysbp_mean
, min(case when VitalID = 3 then valuenum ELSE NULL END) AS diasbp_min
, max(case when VitalID = 3 then valuenum ELSE NULL END) AS diasbp_max
, avg(case when VitalID = 3 then valuenum ELSE NULL END) AS diasbp_mean
, min(case when VitalID = 4 then valuenum ELSE NULL END) AS meanbp_min
, max(case when VitalID = 4 then valuenum ELSE NULL END) AS meanbp_max
, avg(case when VitalID = 4 then valuenum ELSE NULL END) AS meanbp_mean
, min(case when VitalID = 5 then valuenum ELSE NULL END) AS resprate_min
, max(case when VitalID = 5 then valuenum ELSE NULL END) AS resprate_max
, avg(case when VitalID = 5 then valuenum ELSE NULL END) AS resprate_mean
, min(case when VitalID = 6 then valuenum ELSE NULL END) AS tempc_min
, max(case when VitalID = 6 then valuenum ELSE NULL END) AS tempc_max
, avg(case when VitalID = 6 then valuenum ELSE NULL END) AS tempc_mean
, min(case when VitalID = 7 then valuenum ELSE NULL END) AS spo2_min
, max(case when VitalID = 7 then valuenum ELSE NULL END) AS spo2_max
, avg(case when VitalID = 7 then valuenum ELSE NULL END) AS spo2_mean
, min(case when VitalID = 8 then valuenum ELSE NULL END) AS glucose_min
, max(case when VitalID = 8 then valuenum ELSE NULL END) AS glucose_max
, avg(case when VitalID = 8 then valuenum ELSE NULL END) AS glucose_mean

FROM  (
  select ie.subject_id, ie.hadm_id, ie.icustay_id
  , case
    when itemid in (211,220045) and valuenum > 0 and valuenum < 300 then 1 -- HeartRate
    when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then 2 -- SysBP
    when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then 3 -- DiasBP
    when itemid in (456,52,6702,443,220052,220181,225312) and valuenum > 0 and valuenum < 300 then 4 -- MeanBP
    when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then 5 -- RespRate
    when itemid in (223761,678) and valuenum > 70 and valuenum < 120  then 6 -- TempF, converted to degC in valuenum call
    when itemid in (223762,676) and valuenum > 10 and valuenum < 50  then 6 -- TempC
    when itemid in (646,220277) and valuenum > 0 and valuenum <= 100 then 7 -- SpO2
    when itemid in (807,811,1529,3745,3744,225664,220621,226537) and valuenum > 0 then 8 -- Glucose

    else null end as vitalid
      -- convert F to C
  , case when itemid in (223761,678) then (valuenum-32)/1.8 else valuenum end as valuenum

  from `physionet-data.mimiciii_clinical.icustays` ie
  left join `physionet-data.mimiciii_clinical.chartevents` ce
  on ie.icustay_id = ce.icustay_id
  and ce.charttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  and DATETIME_DIFF(ce.charttime, ie.intime, SECOND) > 0
  and DATETIME_DIFF(ce.charttime, ie.intime, HOUR) <= 24
  -- exclude rows marked as error
  and (ce.error IS NULL or ce.error = 0)
  where ce.itemid in
  (
  -- HEART RATE
  211, --"Heart Rate"
  220045, --"Heart Rate"

  -- Systolic/diastolic

  51, --	Arterial BP [Systolic]
  442, --	Manual BP [Systolic]
  455, --	NBP [Systolic]
  6701, --	Arterial BP #2 [Systolic]
  220179, --	Non Invasive Blood Pressure systolic
  220050, --	Arterial Blood Pressure systolic

  8368, --	Arterial BP [Diastolic]
  8440, --	Manual BP [Diastolic]
  8441, --	NBP [Diastolic]
  8555, --	Arterial BP #2 [Diastolic]
  220180, --	Non Invasive Blood Pressure diastolic
  220051, --	Arterial Blood Pressure diastolic


  -- MEAN ARTERIAL PRESSURE
  456, --"NBP Mean"
  52, --"Arterial BP Mean"
  6702, --	Arterial BP Mean #2
  443, --	Manual BP Mean(calc)
  220052, --"Arterial Blood Pressure mean"
  220181, --"Non Invasive Blood Pressure mean"
  225312, --"ART BP mean"

  -- RESPIRATORY RATE
  618,--	Respiratory Rate
  615,--	Resp Rate (Total)
  220210,--	Respiratory Rate
  224690, --	Respiratory Rate (Total)


  -- SPO2, peripheral
  646, 220277,

  -- GLUCOSE, both lab and fingerstick
  807,--	Fingerstick Glucose
  811,--	Glucose (70-105)
  1529,--	Glucose
  3745,--	BloodGlucose
  3744,--	Blood Glucose
  225664,--	Glucose finger stick
  220621,--	Glucose (serum)
  226537,--	Glucose (whole blood)

  -- TEMPERATURE
  223762, -- "Temperature Celsius"
  676,	-- "Temperature C"
  223761, -- "Temperature Fahrenheit"
  678 --	"Temperature F"

  )
) pvt
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id;
