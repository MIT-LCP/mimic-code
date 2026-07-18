-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.vitals_first_day; CREATE TABLE mimiciii_derived.vitals_first_day AS
/* This query pivots the vital signs for the first 24 hours of a patient's stay */ /* Vital signs include heart rate, blood pressure, respiration rate, and temperature */
SELECT
  pvt.subject_id,
  pvt.hadm_id,
  pvt.icustay_id, /* Easier names */
  MIN(CASE WHEN VitalID = 1 THEN valuenum ELSE NULL END) AS heartrate_min,
  MAX(CASE WHEN VitalID = 1 THEN valuenum ELSE NULL END) AS heartrate_max,
  AVG(CASE WHEN VitalID = 1 THEN valuenum ELSE NULL END) AS heartrate_mean,
  MIN(CASE WHEN VitalID = 2 THEN valuenum ELSE NULL END) AS sysbp_min,
  MAX(CASE WHEN VitalID = 2 THEN valuenum ELSE NULL END) AS sysbp_max,
  AVG(CASE WHEN VitalID = 2 THEN valuenum ELSE NULL END) AS sysbp_mean,
  MIN(CASE WHEN VitalID = 3 THEN valuenum ELSE NULL END) AS diasbp_min,
  MAX(CASE WHEN VitalID = 3 THEN valuenum ELSE NULL END) AS diasbp_max,
  AVG(CASE WHEN VitalID = 3 THEN valuenum ELSE NULL END) AS diasbp_mean,
  MIN(CASE WHEN VitalID = 4 THEN valuenum ELSE NULL END) AS meanbp_min,
  MAX(CASE WHEN VitalID = 4 THEN valuenum ELSE NULL END) AS meanbp_max,
  AVG(CASE WHEN VitalID = 4 THEN valuenum ELSE NULL END) AS meanbp_mean,
  MIN(CASE WHEN VitalID = 5 THEN valuenum ELSE NULL END) AS resprate_min,
  MAX(CASE WHEN VitalID = 5 THEN valuenum ELSE NULL END) AS resprate_max,
  AVG(CASE WHEN VitalID = 5 THEN valuenum ELSE NULL END) AS resprate_mean,
  MIN(CASE WHEN VitalID = 6 THEN valuenum ELSE NULL END) AS tempc_min,
  MAX(CASE WHEN VitalID = 6 THEN valuenum ELSE NULL END) AS tempc_max,
  AVG(CASE WHEN VitalID = 6 THEN valuenum ELSE NULL END) AS tempc_mean,
  MIN(CASE WHEN VitalID = 7 THEN valuenum ELSE NULL END) AS spo2_min,
  MAX(CASE WHEN VitalID = 7 THEN valuenum ELSE NULL END) AS spo2_max,
  AVG(CASE WHEN VitalID = 7 THEN valuenum ELSE NULL END) AS spo2_mean,
  MIN(CASE WHEN VitalID = 8 THEN valuenum ELSE NULL END) AS glucose_min,
  MAX(CASE WHEN VitalID = 8 THEN valuenum ELSE NULL END) AS glucose_max,
  AVG(CASE WHEN VitalID = 8 THEN valuenum ELSE NULL END) AS glucose_mean
FROM (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
    CASE
      WHEN itemid IN (211, 220045) AND valuenum > 0 AND valuenum < 300
      THEN 1 /* HeartRate */
      WHEN itemid IN (51, 442, 455, 6701, 220179, 220050) AND valuenum > 0 AND valuenum < 400
      THEN 2 /* SysBP */
      WHEN itemid IN (8368, 8440, 8441, 8555, 220180, 220051)
      AND valuenum > 0
      AND valuenum < 300
      THEN 3 /* DiasBP */
      WHEN itemid IN (456, 52, 6702, 443, 220052, 220181, 225312)
      AND valuenum > 0
      AND valuenum < 300
      THEN 4 /* MeanBP */
      WHEN itemid IN (615, 618, 220210, 224690) AND valuenum > 0 AND valuenum < 70
      THEN 5 /* RespRate */
      WHEN itemid IN (223761, 678) AND valuenum > 70 AND valuenum < 120
      THEN 6 /* TempF, converted to degC in valuenum call */
      WHEN itemid IN (223762, 676) AND valuenum > 10 AND valuenum < 50
      THEN 6 /* TempC */
      WHEN itemid IN (646, 220277) AND valuenum > 0 AND valuenum <= 100
      THEN 7 /* SpO2 */
      WHEN itemid IN (807, 811, 1529, 3745, 3744, 225664, 220621, 226537) AND valuenum > 0
      THEN 8 /* Glucose */
      ELSE NULL
    END AS vitalid, /* convert F to C */
    CASE
      WHEN itemid IN (223761, 678)
      THEN CAST((
        valuenum - 32
      ) AS DOUBLE PRECISION) / 1.8
      ELSE valuenum
    END AS valuenum
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii.chartevents AS ce
    ON ie.icustay_id = ce.icustay_id
    AND ce.charttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
    AND CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', ce.charttime) - DATE_TRUNC('second', ie.intime)) / 1 AS BIGINT) > 0
    AND CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', ce.charttime) - DATE_TRUNC('hour', ie.intime)) / 3600 AS BIGINT) <= 24
    AND /* exclude rows marked as error */ (
      ce.error IS NULL OR ce.error = 0
    )
  WHERE
    ce.itemid IN (
      211, /* HEART RATE */ /* "Heart Rate" */
      220045, /* "Heart Rate" */
      51, /* Systolic/diastolic */ /*	Arterial BP [Systolic] */
      442, /*	Manual BP [Systolic] */
      455, /*	NBP [Systolic] */
      6701, /*	Arterial BP #2 [Systolic] */
      220179, /*	Non Invasive Blood Pressure systolic */
      220050, /*	Arterial Blood Pressure systolic */
      8368, /*	Arterial BP [Diastolic] */
      8440, /*	Manual BP [Diastolic] */
      8441, /*	NBP [Diastolic] */
      8555, /*	Arterial BP #2 [Diastolic] */
      220180, /*	Non Invasive Blood Pressure diastolic */
      220051, /*	Arterial Blood Pressure diastolic */
      456, /* MEAN ARTERIAL PRESSURE */ /* "NBP Mean" */
      52, /* "Arterial BP Mean" */
      6702, /*	Arterial BP Mean #2 */
      443, /*	Manual BP Mean(calc) */
      220052, /* "Arterial Blood Pressure mean" */
      220181, /* "Non Invasive Blood Pressure mean" */
      225312, /* "ART BP mean" */
      618, /* RESPIRATORY RATE */ /*	Respiratory Rate */
      615, /*	Resp Rate (Total) */
      220210, /*	Respiratory Rate */
      224690, /*	Respiratory Rate (Total) */
      646, /* SPO2, peripheral */
      220277,
      807, /* GLUCOSE, both lab and fingerstick */ /*	Fingerstick Glucose */
      811, /*	Glucose (70-105) */
      1529, /*	Glucose */
      3745, /*	BloodGlucose */
      3744, /*	Blood Glucose */
      225664, /*	Glucose finger stick */
      220621, /*	Glucose (serum) */
      226537, /*	Glucose (whole blood) */
      223762, /* TEMPERATURE */ /* "Temperature Celsius" */
      676, /* "Temperature C" */
      223761, /* "Temperature Fahrenheit" */
      678 /*	"Temperature F" */
    )
) AS pvt
GROUP BY
  pvt.subject_id,
  pvt.hadm_id,
  pvt.icustay_id
ORDER BY
  pvt.subject_id NULLS FIRST,
  pvt.hadm_id NULLS FIRST,
  pvt.icustay_id NULLS FIRST