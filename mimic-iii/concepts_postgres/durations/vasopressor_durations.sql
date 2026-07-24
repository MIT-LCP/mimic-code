-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.vasopressor_durations; CREATE TABLE mimiciii_derived.vasopressor_durations AS
/* This query extracts durations of vasopressor administration */ /* It groups together any administration of the below list of drugs: */ /*  norepinephrine - 30047,30120,221906 */ /*  epinephrine - 30044,30119,30309,221289 */ /*  phenylephrine - 30127,30128,221749 */ /*  vasopressin - 30051,222315 (42273, 42802 also for 2 patients) */ /*  dopamine - 30043,30307,221662 */ /*  dobutamine - 30042,30306,221653 */ /*  milrinone - 30125,221986 */ /* Consecutive administrations are numbered 1, 2, ... */ /* Total time on the drug can be calculated from this table */ /* by grouping using ICUSTAY_ID */ /* select only the ITEMIDs from the inputevents_cv table related to vasopressors */
WITH io_cv AS (
  SELECT
    icustay_id,
    charttime,
    itemid,
    stopped, /* ITEMIDs (42273, 42802) accidentally store rate in amount column */
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
), io_mv /* select only the ITEMIDs from the inputevents_mv table related to vasopressors */ AS (
  SELECT
    icustay_id,
    starttime,
    endtime
  FROM mimiciii.inputevents_mv AS io
  /* Subselect the vasopressor ITEMIDs */
  WHERE
    itemid IN (221906, 221289, 221749, 222315, 221662, 221653, 221986)
    AND statusdescription <> 'Rewritten' /* only valid orders */
), vasocv1 AS (
  SELECT
    icustay_id,
    charttime,
    itemid, /* case statement determining whether the ITEMID is an instance of vasopressor usage */
    1 AS vaso, /* the 'stopped' column indicates if a vasopressor has been disconnected */
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
    itemid, /* , (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, vaso order by charttime))) AS delta */
    vaso,
    vaso_rate,
    vaso_amount,
    vaso_stopped,
    vaso_prevrate_ifnull, /* We define start time here */
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
), vasocv5 /* propagate start/stop flags forward in time */ AS (
  SELECT
    v.*,
    SUM(vaso_start) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) AS vaso_first
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
      WHEN LEAD(CHARTTIME, 1) OVER (PARTITION BY icustay_id, itemid, vaso ORDER BY charttime NULLS FIRST) IS NULL
      THEN vaso_first
      ELSE NULL
    END AS vaso_stop
  FROM vasocv5 AS v
), vasocv /* -- if you want to look at the results of the table before grouping: */ /* select */ /*   icustay_id, charttime, vaso, vaso_rate, vaso_amount */ /*     , case when vaso_stopped = 1 then 'Y' else '' end as stopped */ /*     , vaso_start */ /*     , vaso_first */ /*     , vaso_stop */ /* from vasocv6 order by charttime; */ AS (
  /* below groups together vasopressor administrations into groups */
  SELECT
    icustay_id,
    itemid, /* the first non-null rate is considered the starttime */
    MIN(CASE WHEN NOT vaso_rate IS NULL THEN charttime ELSE NULL END) AS starttime, /* the *first* time the first/last flags agree is the stop time for this duration */
    MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END) AS endtime
  FROM vasocv6
  WHERE
    NOT vaso_first IS NULL /* bogus data */
    AND vaso_first <> 0 /* sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered */
    AND NOT icustay_id IS NULL /* there are data for "floating" admissions, we don't worry about these */
  GROUP BY
    icustay_id,
    itemid,
    vaso_first
  /* ensure start time is not the same as end time */
  HAVING
    MIN(charttime) <> MIN(CASE WHEN vaso_first = vaso_stop THEN charttime ELSE NULL END)
    AND MAX(vaso_rate) > 0 /* if the rate was always 0 or null, we consider it not a real drug delivery */
), vasocv_grp /* we do not group by ITEMID in below query */ /* this is because we want to collapse all vasopressors together */ AS (
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
), vasomv /* keep each MetaVision interval; do not bridge Paused gaps via linkorderid (#1808) */ AS (
  SELECT
    icustay_id,
    starttime,
    endtime
  FROM io_mv
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
  icustay_id, /* generate a sequential integer for convenience */
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', endtime) - DATE_TRUNC('hour', starttime)) / 3600 AS BIGINT) AS duration_hours
/* add durations */
FROM vasocv_grp
UNION ALL
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS vasonum,
  starttime,
  endtime,
  CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', endtime) - DATE_TRUNC('hour', starttime)) / 3600 AS BIGINT) AS duration_hours
/* add durations */
FROM vasomv_grp
ORDER BY
  icustay_id NULLS FIRST,
  vasonum NULLS FIRST