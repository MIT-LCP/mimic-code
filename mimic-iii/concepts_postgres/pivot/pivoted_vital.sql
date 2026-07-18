-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_vital; CREATE TABLE mimiciii_derived.pivoted_vital AS
/* This query pivots the vital signs for the first 24 hours of a patient's stay */ /* Vital signs include heart rate, blood pressure, respiration rate, and temperature */
WITH ce AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    (
      CASE
        WHEN itemid IN (211, 220045) AND valuenum > 0 AND valuenum < 300
        THEN valuenum
        ELSE NULL
      END
    ) AS heartrate,
    (
      CASE
        WHEN itemid IN (51, 442, 455, 6701, 220179, 220050) AND valuenum > 0 AND valuenum < 400
        THEN valuenum
        ELSE NULL
      END
    ) AS sysbp,
    (
      CASE
        WHEN itemid IN (8368, 8440, 8441, 8555, 220180, 220051)
        AND valuenum > 0
        AND valuenum < 300
        THEN valuenum
        ELSE NULL
      END
    ) AS diasbp,
    (
      CASE
        WHEN itemid IN (456, 52, 6702, 443, 220052, 220181, 225312)
        AND valuenum > 0
        AND valuenum < 300
        THEN valuenum
        ELSE NULL
      END
    ) AS meanbp,
    (
      CASE
        WHEN itemid IN (615, 618, 220210, 224690) AND valuenum > 0 AND valuenum < 70
        THEN valuenum
        ELSE NULL
      END
    ) AS resprate,
    (
      CASE
        WHEN itemid IN (223761, 678) AND valuenum > 70 AND valuenum < 120
        THEN CAST((
          valuenum - 32
        ) AS DOUBLE PRECISION) / 1.8 /* converted to degC in valuenum call */
        WHEN itemid IN (223762, 676) AND valuenum > 10 AND valuenum < 50
        THEN valuenum
        ELSE NULL
      END
    ) AS tempc,
    (
      CASE
        WHEN itemid IN (646, 220277) AND valuenum > 0 AND valuenum <= 100
        THEN valuenum
        ELSE NULL
      END
    ) AS spo2,
    (
      CASE
        WHEN itemid IN (807, 811, 1529, 3745, 3744, 225664, 220621, 226537) AND valuenum > 0
        THEN valuenum
        ELSE NULL
      END
    ) AS glucose
  FROM mimiciii.chartevents AS ce
  /* exclude rows marked as error */
  WHERE
    (
      ce.error IS NULL OR ce.error <> 1
    )
    AND NOT ce.icustay_id IS NULL
    AND ce.itemid IN (
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
      646, /* spo2, peripheral */
      220277,
      807, /* glucose, both lab and fingerstick */ /*	Fingerstick glucose */
      811, /*	glucose (70-105) */
      1529, /*	glucose */
      3745, /*	Bloodglucose */
      3744, /*	Blood glucose */
      225664, /*	glucose finger stick */
      220621, /*	glucose (serum) */
      226537, /*	glucose (whole blood) */
      223762, /* TEMPERATURE */ /* "Temperature Celsius" */
      676, /* "Temperature C" */
      223761, /* "Temperature Fahrenheit" */
      678 /*	"Temperature F" */
    )
)
SELECT
  ce.icustay_id,
  ce.charttime,
  AVG(heartrate) AS heartrate,
  AVG(sysbp) AS sysbp,
  AVG(diasbp) AS diasbp,
  AVG(meanbp) AS meanbp,
  AVG(resprate) AS resprate,
  AVG(tempc) AS tempc,
  AVG(spo2) AS spo2,
  AVG(glucose) AS glucose
FROM ce
GROUP BY
  ce.icustay_id,
  ce.charttime
ORDER BY
  ce.icustay_id NULLS FIRST,
  ce.charttime NULLS FIRST