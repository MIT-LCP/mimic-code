-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_vital; CREATE TABLE mimiciii_derived.pivoted_vital AS
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
        THEN (
          valuenum - 32
        ) / 1.8
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
  WHERE
    (
      ce.error IS NULL OR ce.error <> 1
    )
    AND NOT ce.icustay_id IS NULL
    AND ce.itemid IN (
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