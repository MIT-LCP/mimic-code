-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.vitalsign; CREATE TABLE mimiciv_derived.vitalsign AS
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
    TRY_CAST(AVG(
      CASE
        WHEN itemid IN (223761) AND valuenum > 70 AND valuenum < 120
        THEN (
          valuenum - 32
        ) / 1.8
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
  AND ce.itemid IN (220045, 225309, 225310, 225312, 220050, 220051, 220052, 220179, 220180, 220181, 220210, 224690, 220277, 225664, 220621, 226537, 223762, 223761, 224642)
GROUP BY
  ce.subject_id,
  ce.stay_id,
  ce.charttime