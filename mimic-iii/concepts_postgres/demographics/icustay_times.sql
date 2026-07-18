-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.icustay_times; CREATE TABLE mimiciii_derived.icustay_times AS
/* create a table which has fuzzy boundaries on hospital admission */ /* involves first creating a lag/lead version of disch/admit time */
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
    h.hadm_id, /* this rule is: */ /*  if there are two hospitalizations within 24 hours, set the start/stop */ /*  time as half way between the two admissions */
    CASE
      WHEN NOT h.dischtime_lag IS NULL
      AND h.dischtime_lag > (
        h.admittime - INTERVAL '24' HOUR
      )
      THEN h.admittime - CAST(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', h.admittime) - DATE_TRUNC('second', h.dischtime_lag)) / 1 AS BIGINT) AS DOUBLE PRECISION) / 2 AS BIGINT) * INTERVAL '1' SECOND
      ELSE h.admittime - INTERVAL '12' HOUR
    END AS data_start,
    CASE
      WHEN NOT h.admittime_lead IS NULL
      AND h.admittime_lead < (
        h.dischtime + INTERVAL '24' HOUR
      )
      THEN h.dischtime + CAST(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', h.admittime_lead) - DATE_TRUNC('second', h.dischtime)) / 1 AS BIGINT) AS DOUBLE PRECISION) / 2 AS BIGINT) * INTERVAL '1' SECOND
      ELSE (
        h.dischtime + INTERVAL '12' HOUR
      )
    END AS data_end
  FROM h
), t1 /* get first/last heart rate measurement during hospitalization for each ICUSTAY_ID */ AS (
  SELECT
    ce.icustay_id,
    MIN(charttime) AS intime_hr,
    MAX(charttime) AS outtime_hr
  FROM mimiciii.chartevents AS ce
  /* very loose join to admissions to ensure charttime is near patient admission */
  INNER JOIN adm
    ON ce.hadm_id = adm.hadm_id
    AND ce.charttime >= adm.data_start
    AND ce.charttime < adm.data_end
  /* only look at heart rate */
  WHERE
    ce.itemid IN (211, 220045)
  GROUP BY
    ce.icustay_id
)
/* add in subject_id/hadm_id */
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