-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.epinephrine_dose; CREATE TABLE mimiciii_derived.epinephrine_dose AS
WITH vasocv1 AS (
  SELECT
    cv.icustay_id,
    cv.charttime,
    MAX(CASE WHEN itemid IN (30044, 30119, 30309) THEN 1 ELSE 0 END) AS vaso,
    MAX(
      CASE
        WHEN itemid IN (30044, 30119, 30309)
        AND (
          stopped = 'Stopped' OR stopped LIKE 'D/C%'
        )
        THEN 1
        ELSE 0
      END
    ) AS vaso_stopped,
    MAX(CASE WHEN itemid IN (30044, 30119, 30309) AND NOT rate IS NULL THEN 1 ELSE 0 END) AS vaso_null,
    MAX(
      CASE
        WHEN itemid = 30044 AND wd.weight IS NULL
        THEN rate / 80.0
        WHEN itemid = 30044
        THEN rate / wd.weight
        WHEN itemid IN (30119, 30309)
        THEN rate
        ELSE NULL
      END
    ) AS vaso_rate,
    MAX(CASE WHEN itemid IN (30044, 30119, 30309) THEN amount ELSE NULL END) AS vaso_amount
  FROM mimiciii.inputevents_cv AS cv
  LEFT JOIN mimiciii_derived.weight_durations AS wd
    ON cv.icustay_id = wd.icustay_id
    AND cv.charttime BETWEEN wd.starttime AND wd.endtime
  WHERE
    itemid IN (30044, 30119, 30309) AND NOT cv.icustay_id IS NULL
  GROUP BY
    cv.icustay_id,
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
), vasocv7 AS (
  SELECT
    icustay_id,
    charttime AS starttime,
    LEAD(charttime) OVER (PARTITION BY icustay_id, vaso_first ORDER BY charttime NULLS FIRST) AS endtime,
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stop,
    vaso_start,
    vaso_first
  FROM vasocv6
  WHERE
    NOT vaso_first IS NULL AND vaso_first <> 0 AND NOT icustay_id IS NULL
), vasocv8 AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stop,
    vaso_start,
    vaso_first
  FROM vasocv7
  WHERE
    NOT endtime IS NULL AND vaso_rate > 0 AND starttime <> endtime
), vasocv9 AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    CASE
      WHEN LAG(endtime) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST, endtime NULLS FIRST) = starttime
      AND LAG(vaso_rate) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST, endtime NULLS FIRST) = vaso_rate
      THEN 0
      ELSE 1
    END AS vaso_groups,
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stop,
    vaso_start,
    vaso_first
  FROM vasocv8
  WHERE
    NOT endtime IS NULL AND vaso_rate > 0 AND starttime <> endtime
), vasocv10 AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    vaso_groups,
    SUM(vaso_groups) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST, endtime NULLS FIRST) AS vaso_groups_sum,
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stop,
    vaso_start,
    vaso_first
  FROM vasocv9
), vasocv AS (
  SELECT
    icustay_id,
    MIN(starttime) AS starttime,
    MAX(endtime) AS endtime,
    vaso_groups_sum,
    vaso_rate,
    SUM(vaso_amount) AS vaso_amount
  FROM vasocv10
  GROUP BY
    icustay_id,
    vaso_groups_sum,
    vaso_rate
), vasomv AS (
  SELECT
    icustay_id,
    linkorderid,
    rate AS vaso_rate,
    amount AS vaso_amount,
    starttime,
    endtime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid = 221289 AND statusdescription <> 'Rewritten'
)
SELECT
  icustay_id,
  starttime,
  endtime,
  vaso_rate,
  vaso_amount
FROM vasocv
UNION ALL
SELECT
  icustay_id,
  starttime,
  endtime,
  vaso_rate,
  vaso_amount
FROM vasomv
ORDER BY
  icustay_id NULLS FIRST,
  starttime NULLS FIRST