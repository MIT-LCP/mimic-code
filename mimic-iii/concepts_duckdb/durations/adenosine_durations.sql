-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.adenosine_durations; CREATE TABLE mimiciii_derived.adenosine_durations AS
WITH vasocv1 AS (
  SELECT
    icustay_id,
    charttime,
    MAX(CASE WHEN itemid = 4649 THEN 1 ELSE 0 END) AS vaso,
    0 AS vaso_stopped,
    MAX(CASE WHEN itemid = 4649 AND NOT valuenum IS NULL THEN 1 ELSE 0 END) AS vaso_null,
    MAX(CASE WHEN itemid = 4649 THEN valuenum ELSE NULL END) AS vaso_rate,
    MAX(CASE WHEN itemid = 4649 THEN valuenum ELSE NULL END) AS vaso_amount
  FROM mimiciii.chartevents
  WHERE
    itemid = 4649 AND (
      error IS NULL OR error = 0
    )
  GROUP BY
    icustay_id,
    charttime
), vasocv2 AS (
  SELECT
    v.*,
    SUM(vaso_null) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS vaso_partition
  FROM vasocv1 AS v
), vasocv3 AS (
  SELECT
    v.*,
    FIRST_VALUE(vaso_rate) OVER (PARTITION BY icustay_id, vaso_partition ORDER BY charttime NULLS FIRST) AS vaso_prevrate_ifnull
  FROM vasocv2 AS v
), vasocv4 AS (
  SELECT
    icustay_id,
    charttime,
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stopped,
    vaso_prevrate_ifnull,
    CASE
      WHEN vaso = 0
      THEN NULL
      WHEN vaso_rate > 0
      AND LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, vaso, vaso_null ORDER BY charttime NULLS FIRST) IS NULL
      THEN 1
      WHEN vaso_rate = 0
      AND LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, vaso ORDER BY charttime NULLS FIRST) = 0
      THEN 0
      WHEN vaso_prevrate_ifnull = 0
      AND LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, vaso ORDER BY charttime NULLS FIRST) = 0
      THEN 0
      WHEN LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, vaso ORDER BY charttime NULLS FIRST) = 0
      THEN 1
      WHEN LAG(vaso_stopped, 1) OVER (PARTITION BY icustay_id, vaso ORDER BY charttime NULLS FIRST) = 1
      THEN 1
      ELSE NULL
    END AS vaso_start
  FROM vasocv3
), vasocv5 AS (
  SELECT
    v.*,
    SUM(vaso_start) OVER (PARTITION BY icustay_id, vaso ORDER BY charttime NULLS FIRST) AS vaso_first
  FROM vasocv4 AS v
), vasocv6 AS (
  SELECT
    v.*,
    CASE
      WHEN vaso = 0
      THEN NULL
      WHEN vaso_stopped = 1
      THEN vaso_first
      WHEN vaso_rate = 0
      THEN vaso_first
      WHEN LEAD(CHARTTIME, 1) OVER (PARTITION BY icustay_id, vaso ORDER BY charttime NULLS FIRST) IS NULL
      THEN vaso_first
      ELSE NULL
    END AS vaso_stop
  FROM vasocv5 AS v
), vasocv AS (
  SELECT
    icustay_id,
    MIN(CASE WHEN NOT vaso_rate IS NULL THEN charttime ELSE NULL END) AS starttime,
    MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END) AS endtime
  FROM vasocv6
  WHERE
    NOT vaso_first IS NULL AND vaso_first <> 0 AND NOT icustay_id IS NULL
  GROUP BY
    icustay_id,
    vaso_first
  HAVING
    MIN(charttime) <> MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END)
    AND MAX(vaso_rate) > 0
), vasomv AS (
  SELECT
    icustay_id,
    linkorderid,
    MIN(starttime) AS starttime,
    MAX(endtime) AS endtime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid = 221282 AND statusdescription <> 'Rewritten'
  GROUP BY
    icustay_id,
    linkorderid
)
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  DATE_DIFF('HOUR', starttime, endtime) AS duration_hours
FROM vasocv
UNION ALL
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  DATE_DIFF('HOUR', starttime, endtime) AS duration_hours
FROM vasomv
ORDER BY
  icustay_id NULLS FIRST,
  vasonum NULLS FIRST