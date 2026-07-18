-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.epinephrine_durations; CREATE TABLE mimiciii_derived.epinephrine_durations AS
/* This query extracts durations of epinephrine administration */ /* Consecutive administrations are numbered 1, 2, ... */ /* Total time on the drug can be calculated from this table by grouping using ICUSTAY_ID */ /* Get drug administration data from CareVue first */
WITH vasocv1 AS (
  SELECT
    icustay_id,
    charttime, /* case statement determining whether the ITEMID is an instance of vasopressor usage */
    MAX(CASE WHEN itemid IN (30044, 30119, 30309) THEN 1 ELSE 0 END) AS vaso, /* epinephrine */ /* the 'stopped' column indicates if a vasopressor has been disconnected */
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
    MAX(CASE WHEN itemid IN (30044, 30119, 30309) THEN rate ELSE NULL END) AS vaso_rate,
    MAX(CASE WHEN itemid IN (30044, 30119, 30309) THEN amount ELSE NULL END) AS vaso_amount
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (30044, 30119, 30309 /* epinephrine */)
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
), vasocv /* -- if you want to look at the results of the table before grouping: */ /* select */ /*   icustay_id, charttime, vaso, vaso_rate, vaso_amount */ /*     , case when vaso_stopped = 1 then 'Y' else '' end as stopped */ /*     , vaso_start */ /*     , vaso_first */ /*     , vaso_stop */ /* from vasocv6 order by charttime; */ AS (
  /* below groups together vasopressor administrations into groups */
  SELECT
    icustay_id, /* the first non-null rate is considered the starttime */
    MIN(CASE WHEN NOT vaso_rate IS NULL THEN charttime ELSE NULL END) AS starttime, /* the *first* time the first/last flags agree is the stop time for this duration */
    MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END) AS endtime
  FROM vasocv6
  WHERE
    NOT vaso_first IS NULL /* bogus data */
    AND vaso_first <> 0 /* sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered */
    AND NOT icustay_id IS NULL /* there are data for "floating" admissions, we don't worry about these */
  GROUP BY
    icustay_id,
    vaso_first
  /* ensure start time is not the same as end time */
  HAVING
    MIN(charttime) <> MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END)
    AND MAX(vaso_rate) > 0 /* if the rate was always 0 or null, we consider it not a real drug delivery */
), vasomv /* now we extract the associated data for metavision patients */ AS (
  SELECT
    icustay_id,
    linkorderid,
    MIN(starttime) AS starttime,
    MAX(endtime) AS endtime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid = 221289 /* epinephrine */
    AND statusdescription <> 'Rewritten' /* only valid orders */
  GROUP BY
    icustay_id,
    linkorderid
)
SELECT
  icustay_id, /* generate a sequential integer for convenience */
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', endtime) - DATE_TRUNC('hour', starttime)) / 3600 AS BIGINT) AS duration_hours
/* add durations */
FROM vasocv
UNION ALL
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', endtime) - DATE_TRUNC('hour', starttime)) / 3600 AS BIGINT) AS duration_hours
/* add durations */
FROM vasomv
ORDER BY
  icustay_id NULLS FIRST,
  vasonum NULLS FIRST