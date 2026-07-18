-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.vitals_first_day; CREATE TABLE mimiciii_derived.vitals_first_day AS
SELECT
  pvt.subject_id,
  pvt.hadm_id,
  pvt.icustay_id,
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
      THEN 1
      WHEN itemid IN (51, 442, 455, 6701, 220179, 220050) AND valuenum > 0 AND valuenum < 400
      THEN 2
      WHEN itemid IN (8368, 8440, 8441, 8555, 220180, 220051)
      AND valuenum > 0
      AND valuenum < 300
      THEN 3
      WHEN itemid IN (456, 52, 6702, 443, 220052, 220181, 225312)
      AND valuenum > 0
      AND valuenum < 300
      THEN 4
      WHEN itemid IN (615, 618, 220210, 224690) AND valuenum > 0 AND valuenum < 70
      THEN 5
      WHEN itemid IN (223761, 678) AND valuenum > 70 AND valuenum < 120
      THEN 6
      WHEN itemid IN (223762, 676) AND valuenum > 10 AND valuenum < 50
      THEN 6
      WHEN itemid IN (646, 220277) AND valuenum > 0 AND valuenum <= 100
      THEN 7
      WHEN itemid IN (807, 811, 1529, 3745, 3744, 225664, 220621, 226537) AND valuenum > 0
      THEN 8
      ELSE NULL
    END AS vitalid,
    CASE WHEN itemid IN (223761, 678) THEN (
      valuenum - 32
    ) / 1.8 ELSE valuenum END AS valuenum
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii.chartevents AS ce
    ON ie.icustay_id = ce.icustay_id
    AND ce.charttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
    AND DATE_DIFF('SECOND', ie.intime, ce.charttime) > 0
    AND DATE_DIFF('HOUR', ie.intime, ce.charttime) <= 24
    AND (
      ce.error IS NULL OR ce.error = 0
    )
  WHERE
    ce.itemid IN (
      211,
      220045,
      51,
      442,
      455,
      6701,
      220179,
      220050,
      8368,
      8440,
      8441,
      8555,
      220180,
      220051,
      456,
      52,
      6702,
      443,
      220052,
      220181,
      225312,
      618,
      615,
      220210,
      224690,
      646,
      220277,
      807,
      811,
      1529,
      3745,
      3744,
      225664,
      220621,
      226537,
      223762,
      676,
      223761,
      678
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