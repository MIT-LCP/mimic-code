-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.vasopressor_durations; CREATE TABLE mimiciii_derived.vasopressor_durations AS
WITH io_cv AS (
  SELECT
    icustay_id,
    charttime,
    itemid,
    stopped,
    CASE WHEN itemid IN (42273, 42802) THEN amount ELSE rate END AS rate,
    CASE WHEN itemid IN (42273, 42802) THEN rate ELSE amount END AS amount
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (
      30047,
      30120,
      30044,
      30119,
      30309,
      30127,
      30128,
      30051,
      30043,
      30307,
      30042,
      30306,
      30125,
      42273,
      42802
    )
), io_mv AS (
  SELECT
    icustay_id,
    linkorderid,
    starttime,
    endtime
  FROM mimiciii.inputevents_mv AS io
  WHERE
    itemid IN (221906, 221289, 221749, 222315, 221662, 221653, 221986)
    AND statusdescription <> 'Rewritten'
), vasocv1 AS (
  SELECT
    icustay_id,
    charttime,
    itemid,
    1 AS vaso,
    MAX(CASE WHEN (
      stopped = 'Stopped' OR stopped LIKE 'D/C%'
    ) THEN 1 ELSE 0 END) AS vaso_stopped,
    MAX(CASE WHEN NOT rate IS NULL THEN 1 ELSE 0 END) AS vaso_null,
    MAX(rate) AS vaso_rate,
    MAX(amount) AS vaso_amount
  FROM io_cv
  GROUP BY
    icustay_id,
    charttime,
    itemid
), vasocv2 AS (
  SELECT
    v.*,
    SUM(vaso_null) OVER (PARTITION BY icustay_id, itemid ORDER BY charttime NULLS FIRST) AS vaso_partition
  FROM vasocv1 AS v
), vasocv3 AS (
  SELECT
    v.*,
    FIRST_VALUE(vaso_rate) OVER (PARTITION BY icustay_id, itemid, vaso_partition ORDER BY charttime NULLS FIRST) AS vaso_prevrate_ifnull
  FROM vasocv2 AS v
), vasocv4 AS (
  SELECT
    icustay_id,
    charttime,
    itemid,
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stopped,
    vaso_prevrate_ifnull,
    CASE
      WHEN vaso = 0
      THEN NULL
      WHEN vaso_rate > 0
      AND LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, itemid, vaso, vaso_null ORDER BY charttime NULLS FIRST) IS NULL
      THEN 1
      WHEN vaso_rate = 0
      AND LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) = 0
      THEN 0
      WHEN vaso_prevrate_ifnull = 0
      AND LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) = 0
      THEN 0
      WHEN LAG(vaso_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) = 0
      THEN 1
      WHEN LAG(vaso_stopped, 1) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) = 1
      THEN 1
      ELSE NULL
    END AS vaso_start
  FROM vasocv3
), vasocv5 AS (
  SELECT
    v.*,
    SUM(vaso_start) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) AS vaso_first
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
      WHEN LEAD(CHARTTIME, 1) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) IS NULL
      THEN vaso_first
      ELSE NULL
    END AS vaso_stop
  FROM vasocv5 AS v
), vasocv AS (
  SELECT
    icustay_id,
    itemid,
    MIN(CASE WHEN NOT vaso_rate IS NULL THEN charttime ELSE NULL END) AS starttime,
    MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END) AS endtime
  FROM vasocv6
  WHERE
    NOT vaso_first IS NULL AND vaso_first <> 0 AND NOT icustay_id IS NULL
  GROUP BY
    icustay_id,
    itemid,
    vaso_first
  HAVING
    MIN(charttime) <> MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END)
    AND MAX(vaso_rate) > 0
), vasocv_grp AS (
  SELECT
    s1.icustay_id,
    s1.starttime,
    MIN(t1.endtime) AS endtime
  FROM vasocv AS s1
  INNER JOIN vasocv AS t1
    ON s1.icustay_id = t1.icustay_id
    AND s1.starttime <= t1.endtime
    AND NOT EXISTS(
      SELECT
        *
      FROM vasocv AS t2
      WHERE
        t1.icustay_id = t2.icustay_id
        AND t1.endtime >= t2.starttime
        AND t1.endtime < t2.endtime
    )
  WHERE
    NOT EXISTS(
      SELECT
        *
      FROM vasocv AS s2
      WHERE
        s1.icustay_id = s2.icustay_id
        AND s1.starttime > s2.starttime
        AND s1.starttime <= s2.endtime
    )
  GROUP BY
    s1.icustay_id,
    s1.starttime
  ORDER BY
    s1.icustay_id NULLS FIRST,
    s1.starttime NULLS FIRST
), vasomv AS (
  SELECT
    icustay_id,
    linkorderid,
    MIN(starttime) AS starttime,
    MAX(endtime) AS endtime
  FROM io_mv
  GROUP BY
    icustay_id,
    linkorderid
), vasomv_grp AS (
  SELECT
    s1.icustay_id,
    s1.starttime,
    MIN(t1.endtime) AS endtime
  FROM vasomv AS s1
  INNER JOIN vasomv AS t1
    ON s1.icustay_id = t1.icustay_id
    AND s1.starttime <= t1.endtime
    AND NOT EXISTS(
      SELECT
        *
      FROM vasomv AS t2
      WHERE
        t1.icustay_id = t2.icustay_id
        AND t1.endtime >= t2.starttime
        AND t1.endtime < t2.endtime
    )
  WHERE
    NOT EXISTS(
      SELECT
        *
      FROM vasomv AS s2
      WHERE
        s1.icustay_id = s2.icustay_id
        AND s1.starttime > s2.starttime
        AND s1.starttime <= s2.endtime
    )
  GROUP BY
    s1.icustay_id,
    s1.starttime
  ORDER BY
    s1.icustay_id NULLS FIRST,
    s1.starttime NULLS FIRST
)
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  DATE_DIFF('HOUR', starttime, endtime) AS duration_hours
FROM vasocv_grp
UNION ALL
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  DATE_DIFF('HOUR', starttime, endtime) AS duration_hours
FROM vasomv_grp
ORDER BY
  icustay_id NULLS FIRST,
  vasonum NULLS FIRST