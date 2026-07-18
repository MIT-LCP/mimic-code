-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.icustay_times; CREATE TABLE mimiciii_derived.icustay_times AS
WITH h AS (
  SELECT
    subject_id,
    hadm_id,
    admittime,
    dischtime,
    LAG(dischtime) OVER (PARTITION BY subject_id ORDER BY admittime NULLS FIRST) AS dischtime_lag,
    LEAD(admittime) OVER (PARTITION BY subject_id ORDER BY admittime NULLS FIRST) AS admittime_lead
  FROM mimiciii.admissions
), adm AS (
  SELECT
    h.subject_id,
    h.hadm_id,
    CASE
      WHEN NOT h.dischtime_lag IS NULL
      AND h.dischtime_lag > (
        h.admittime - INTERVAL '24' HOUR
      )
      THEN h.admittime - INTERVAL (CAST(DATE_DIFF('SECOND', h.dischtime_lag, h.admittime) / 2 AS BIGINT)) SECOND
      ELSE h.admittime - INTERVAL '12' HOUR
    END AS data_start,
    CASE
      WHEN NOT h.admittime_lead IS NULL
      AND h.admittime_lead < (
        h.dischtime + INTERVAL '24' HOUR
      )
      THEN h.dischtime + INTERVAL (CAST(DATE_DIFF('SECOND', h.dischtime, h.admittime_lead) / 2 AS BIGINT)) SECOND
      ELSE (
        h.dischtime + INTERVAL '12' HOUR
      )
    END AS data_end
  FROM h
), t1 AS (
  SELECT
    ce.icustay_id,
    MIN(charttime) AS intime_hr,
    MAX(charttime) AS outtime_hr
  FROM mimiciii.chartevents AS ce
  INNER JOIN adm
    ON ce.hadm_id = adm.hadm_id
    AND ce.charttime >= adm.data_start
    AND ce.charttime < adm.data_end
  WHERE
    ce.itemid IN (211, 220045)
  GROUP BY
    ce.icustay_id
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  t1.intime_hr,
  t1.outtime_hr
FROM mimiciii.icustays AS ie
LEFT JOIN t1
  ON ie.icustay_id = t1.icustay_id
ORDER BY
  ie.subject_id NULLS FIRST,
  ie.hadm_id NULLS FIRST,
  ie.icustay_id NULLS FIRST