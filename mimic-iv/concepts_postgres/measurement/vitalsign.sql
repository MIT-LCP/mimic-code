-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.vitalsign; CREATE TABLE mimiciv_derived.vitalsign AS
/* This query pivots the vital signs for the entire patient stay. */ /* The result is a tabler with stay_id, charttime, and various */ /* vital signs, with one row per charted time. */
SELECT
  ce.subject_id,
  ce.stay_id,
  ce.charttime,
  AVG(
    CASE WHEN itemid IN (220045) AND valuenum > 0 AND valuenum < 300 THEN valuenum END
  ) AS heart_rate,
  AVG(
    CASE
      WHEN itemid IN (220179, 220050, 225309) AND valuenum > 0 AND valuenum < 400
      THEN valuenum
    END
  ) AS sbp,
  AVG(
    CASE
      WHEN itemid IN (220180, 220051, 225310) AND valuenum > 0 AND valuenum < 300
      THEN valuenum
    END
  ) AS dbp,
  AVG(
    CASE
      WHEN itemid IN (220052, 220181, 225312) AND valuenum > 0 AND valuenum < 300
      THEN valuenum
    END
  ) AS mbp,
  AVG(CASE WHEN itemid = 220179 AND valuenum > 0 AND valuenum < 400 THEN valuenum END) AS sbp_ni,
  AVG(CASE WHEN itemid = 220180 AND valuenum > 0 AND valuenum < 300 THEN valuenum END) AS dbp_ni,
  AVG(CASE WHEN itemid = 220181 AND valuenum > 0 AND valuenum < 300 THEN valuenum END) AS mbp_ni,
  AVG(
    CASE
      WHEN itemid IN (220210, 224690) AND valuenum > 0 AND valuenum < 70
      THEN valuenum
    END
  ) AS resp_rate,
  ROUND(
    CAST(AVG(
      CASE
        WHEN itemid IN (223761) AND valuenum > 70 AND valuenum < 120
        THEN CAST((
          valuenum - 32
        ) AS DOUBLE PRECISION) / 1.8
        WHEN itemid IN (223762) AND valuenum > 10 AND valuenum < 50
        THEN valuenum
      END
    ) AS DECIMAL),
    2
  ) AS temperature,
  MAX(CASE WHEN itemid = 224642 THEN value END) AS temperature_site,
  AVG(
    CASE WHEN itemid IN (220277) AND valuenum > 0 AND valuenum <= 100 THEN valuenum END
  ) AS spo2,
  AVG(CASE WHEN itemid IN (225664, 220621, 226537) AND valuenum > 0 THEN valuenum END) AS glucose
FROM mimiciv_icu.chartevents AS ce
WHERE
  NOT ce.stay_id IS NULL
  AND ce.itemid IN (220045 /* Heart Rate */, 225309 /* ART BP Systolic */, 225310 /* ART BP Diastolic */, 225312 /* ART BP Mean */, 220050 /* Arterial Blood Pressure systolic */, 220051 /* Arterial Blood Pressure diastolic */, 220052 /* Arterial Blood Pressure mean */, 220179 /* Non Invasive Blood Pressure systolic */, 220180 /* Non Invasive Blood Pressure diastolic */, 220181 /* Non Invasive Blood Pressure mean */, 220210 /* Respiratory Rate */, 224690 /* Respiratory Rate (Total) */, 220277 /* SPO2, peripheral */ /* GLUCOSE, both lab and fingerstick */, 225664 /* Glucose finger stick */, 220621 /* Glucose (serum) */, 226537 /* Glucose (whole blood) */ /* TEMPERATURE */ /* 226329 -- Blood Temperature CCO (C) */, 223762 /* "Temperature Celsius" */, 223761 /* "Temperature Fahrenheit" */, 224642 /* Temperature Site */)
GROUP BY
  ce.subject_id,
  ce.stay_id,
  ce.charttime