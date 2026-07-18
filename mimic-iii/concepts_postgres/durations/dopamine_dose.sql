-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.dopamine_dose; CREATE TABLE mimiciii_derived.dopamine_dose AS
/* This query extracts dose+durations of dopamine administration */ /* Get drug administration data from CareVue first */
WITH vasocv1 AS (
  SELECT
    icustay_id,
    charttime, /* case statement determining whether the ITEMID is an instance of vasopressor usage */
    MAX(CASE WHEN itemid IN (30043, 30307) THEN 1 ELSE 0 END) AS vaso, /* dopamine */ /* the 'stopped' column indicates if a vasopressor has been disconnected */
    MAX(
      CASE
        WHEN itemid IN (30043, 30307) AND (
          stopped = 'Stopped' OR stopped LIKE 'D/C%'
        )
        THEN 1
        ELSE 0
      END
    ) AS vaso_stopped,
    MAX(CASE WHEN itemid IN (30043, 30307) AND NOT rate IS NULL THEN 1 ELSE 0 END) AS vaso_null,
    MAX(CASE WHEN itemid IN (30043, 30307) THEN rate ELSE NULL END) AS vaso_rate,
    MAX(CASE WHEN itemid IN (30043, 30307) THEN amount ELSE NULL END) AS vaso_amount
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (30043, 30307 /* dopamine */)
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
    charttime, /* , (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, vaso order by charttime))) AS delta */
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stopped,
    vaso_prevrate_ifnull, /* We define start time here */
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
), vasocv5 /* propagate start/stop flags forward in time */ AS (
  SELECT
    v.*,
    SUM(vaso_start) OVER (PARTITION BY icustay_id, vaso ORDER BY charttime NULLS FIRST) AS vaso_first
  FROM vasocv4 AS v
), vasocv6 AS (
  SELECT
    v.*, /* We define end time here */
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
), vasocv7 /* -- if you want to look at the results of the table before grouping: */ /* select */ /*   icustay_id, charttime, vaso, vaso_rate, vaso_amount */ /*     , vaso_stopped */ /*     , vaso_start */ /*     , vaso_first */ /*     , vaso_stop */ /* from vasocv6 order by icustay_id, charttime; */ AS (
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
    NOT vaso_first IS NULL /* bogus data */
    AND vaso_first <> 0 /* sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered */
    AND NOT icustay_id IS NULL /* there are data for "floating" admissions, we don't worry about these */
), vasocv8 /* table of start/stop times for event */ AS (
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
), vasocv9 /* collapse these start/stop times down if the rate doesn't change */ AS (
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
), vasomv /* now we extract the associated data for metavision patients */ AS (
  SELECT
    icustay_id,
    linkorderid,
    rate AS vaso_rate,
    amount AS vaso_amount,
    starttime,
    endtime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid = 221662 /* dopamine */
    AND statusdescription <> 'Rewritten' /* only valid orders */
)
/* now assign this data to every hour of the patient's stay */ /* vaso_amount for carevue is not accurate */
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