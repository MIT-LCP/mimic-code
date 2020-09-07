-- This query pivots the vital signs for the first 24 hours of a patient's stay
-- Vital signs include heart rate, blood pressure, respiration rate, AND temperature

WITH pvt AS (
    SELECT
        ie.subject_id
        , ie.hadm_id
        , ie.stay_id
        , CASE
            WHEN itemid IN (220045) AND valuenum > 0 AND valuenum < 300 THEN 1 -- HeartRate
            WHEN itemid IN (220179,220050) AND valuenum > 0 AND valuenum < 400 THEN 2 -- SysBP
            WHEN itemid IN (220180,220051) AND valuenum > 0 AND valuenum < 300 THEN 3 -- DiasBP
            WHEN itemid IN (220052,220181,225312) AND valuenum > 0 AND valuenum < 300 THEN 4 -- MeanBP
            WHEN itemid IN (220210,224690) AND valuenum > 0 AND valuenum < 70 THEN 5 -- RespRate
            WHEN itemid IN (223761,678) AND valuenum > 70 AND valuenum < 120  THEN 6 -- TempF, converted to degC in valuenum call
            WHEN itemid IN (223762,676) AND valuenum > 10 AND valuenum < 50  THEN 6 -- TempC
            WHEN itemid IN (220277) AND valuenum > 0 AND valuenum <= 100 THEN 7 -- SpO2
            WHEN itemid IN (225664,220621,226537) AND valuenum > 0 THEN 8 -- Glucose
        END AS vitalid
        -- convert F to C
        , CASE WHEN itemid IN (223761,678) THEN (valuenum-32)/1.8 ELSE valuenum END AS valuenum
    FROM `physionet-data.mimic_icu.icustays` ie
    LEFT JOIN `physionet-data.mimic_icu.chartevents` ce ON
        ie.stay_id = ce.stay_id
        AND ce.charttime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    WHERE ce.itemid IN (
        -- HEART RATE
        220045, --"Heart Rate"

        -- Systolic/diastolic
        220179, --	Non Invasive Blood Pressure systolic
        220050, --	Arterial Blood Pressure systolic

        220180, --	Non Invasive Blood Pressure diastolic
        220051, --	Arterial Blood Pressure diastolic


        -- MEAN ARTERIAL PRESSURE
        220052, --"Arterial Blood Pressure mean"
        220181, --"Non Invasive Blood Pressure mean"
        225312, --"ART BP mean"

        -- RESPIRATORY RATE
        220210,--	Respiratory Rate
        224690, --	Respiratory Rate (Total)


        -- SPO2, peripheral
        220277,

        -- GLUCOSE, both lab AND fingerstick
        225664,--	Glucose finger stick
        220621,--	Glucose (serum)
        226537,--	Glucose (whole blood)

        -- TEMPERATURE
        223762, -- "Temperature Celsius"
        223761 -- "Temperature Fahrenheit"
        )
)
SELECT
    pvt.subject_id
    , pvt.hadm_id
    , pvt.stay_id
    -- Easier names
    , MIN(CASE WHEN VitalID = 1 THEN valuenum ELSE NULL END) AS heartrate_min
    , MAX(CASE WHEN VitalID = 1 THEN valuenum ELSE NULL END) AS heartrate_max
    , AVG(CASE WHEN VitalID = 1 THEN valuenum ELSE NULL END) AS heartrate_mean
    , MIN(CASE WHEN VitalID = 2 THEN valuenum ELSE NULL END) AS sysbp_min
    , MAX(CASE WHEN VitalID = 2 THEN valuenum ELSE NULL END) AS sysbp_max
    , AVG(CASE WHEN VitalID = 2 THEN valuenum ELSE NULL END) AS sysbp_mean
    , MIN(CASE WHEN VitalID = 3 THEN valuenum ELSE NULL END) AS diasbp_min
    , MAX(CASE WHEN VitalID = 3 THEN valuenum ELSE NULL END) AS diasbp_max
    , AVG(CASE WHEN VitalID = 3 THEN valuenum ELSE NULL END) AS diasbp_mean
    , MIN(CASE WHEN VitalID = 4 THEN valuenum ELSE NULL END) AS meanbp_min
    , MAX(CASE WHEN VitalID = 4 THEN valuenum ELSE NULL END) AS meanbp_max
    , AVG(CASE WHEN VitalID = 4 THEN valuenum ELSE NULL END) AS meanbp_mean
    , MIN(CASE WHEN VitalID = 5 THEN valuenum ELSE NULL END) AS resprate_min
    , MAX(CASE WHEN VitalID = 5 THEN valuenum ELSE NULL END) AS resprate_max
    , AVG(CASE WHEN VitalID = 5 THEN valuenum ELSE NULL END) AS resprate_mean
    , MIN(CASE WHEN VitalID = 6 THEN valuenum ELSE NULL END) AS tempc_min
    , MAX(CASE WHEN VitalID = 6 THEN valuenum ELSE NULL END) AS tempc_max
    , AVG(CASE WHEN VitalID = 6 THEN valuenum ELSE NULL END) AS tempc_mean
    , MIN(CASE WHEN VitalID = 7 THEN valuenum ELSE NULL END) AS spo2_min
    , MAX(CASE WHEN VitalID = 7 THEN valuenum ELSE NULL END) AS spo2_max
    , AVG(CASE WHEN VitalID = 7 THEN valuenum ELSE NULL END) AS spo2_mean
    , MIN(CASE WHEN VitalID = 8 THEN valuenum ELSE NULL END) AS glucose_min
    , MAX(CASE WHEN VitalID = 8 THEN valuenum ELSE NULL END) AS glucose_max
    , AVG(CASE WHEN VitalID = 8 THEN valuenum ELSE NULL END) AS glucose_mean
FROM  pvt
GROUP BY pvt.subject_id, pvt.hadm_id, pvt.stay_id
ORDER BY pvt.subject_id, pvt.hadm_id, pvt.stay_id;
