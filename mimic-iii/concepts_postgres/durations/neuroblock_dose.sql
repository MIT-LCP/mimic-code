-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.neuroblock_dose; CREATE TABLE mimiciii_derived.neuroblock_dose AS
/* This query extracts dose+durations of neuromuscular blocking agents */ /* Note: we assume that injections will be filtered for carevue as they will have starttime = stopttime. */ /* Get drug administration data from CareVue and MetaVision */ /* metavision is simple and only requires one temporary table */
WITH drugmv AS (
  SELECT
    icustay_id,
    orderid,
    rate AS drug_rate,
    amount AS drug_amount,
    starttime,
    endtime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid IN (
      222062, /* Vecuronium (664 rows, 154 infusion rows) */
      221555 /* Cisatracurium (9334 rows, 8970 infusion rows) */
    )
    AND statusdescription <> 'Rewritten' /* only valid orders */
    AND NOT rate IS NULL /* only continuous infusions */
), drugcv1 AS (
  SELECT
    icustay_id,
    charttime, /* where clause below ensures all rows are instance of the drug */
    1 AS drug, /* the 'stopped' column indicates if a drug has been disconnected */
    MAX(CASE WHEN stopped IN ('Stopped', 'D/C' || 'd') THEN 1 ELSE 0 END) AS drug_stopped, /* we only include continuous infusions, therefore expect a rate */
    MAX(
      CASE
        WHEN itemid >= 40000 AND NOT amount IS NULL
        THEN 1
        WHEN itemid < 40000 AND NOT rate IS NULL
        THEN 1
        ELSE 0
      END
    ) AS drug_null,
    MAX(CASE WHEN itemid >= 40000 THEN COALESCE(rate, amount) ELSE rate END) AS drug_rate,
    MAX(amount) AS drug_amount
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (
      30114, /* Cisatracurium (63994 rows) */
      30138, /* Vecuronium	 (5160 rows) */
      30113, /* Atracurium  (1163 rows) */ /* Below rows are less frequent ad-hoc documentation, but worth including! */
      42174, /* nimbex cc/hr (207 rows) */
      42385, /* Cisatracurium gtt (156 rows) */
      41916, /* NIMBEX	inputevents_cv (136 rows) */
      42100, /* cistatracurium	(132 rows) */
      42045, /* nimbex mcg/kg/min (78 rows) */
      42246, /* CISATRICARIUM CC/HR (70 rows) */
      42291, /* NIMBEX CC/HR (48 rows) */
      42590, /* nimbex	inputevents_cv (38 rows) */
      42284, /* CISATRACURIUM DRIP (9 rows) */
      45096 /* Vecuronium drip (2 rows) */
    )
  GROUP BY
    icustay_id,
    charttime
  UNION
  /* add data from chartevents */
  SELECT
    icustay_id,
    charttime, /* where clause below ensures all rows are instance of the drug */
    1 AS drug, /* the 'stopped' column indicates if a drug has been disconnected */
    MAX(CASE WHEN stopped IN ('Stopped', 'D/C' || 'd') THEN 1 ELSE 0 END) AS drug_stopped,
    MAX(CASE WHEN valuenum <= 10 THEN 0 ELSE 1 END) AS drug_null, /* educated guess! */
    MAX(CASE WHEN valuenum <= 10 THEN valuenum ELSE NULL END) AS drug_rate,
    MAX(CASE WHEN valuenum > 10 THEN valuenum ELSE NULL END) AS drug_amount
  FROM mimiciii.chartevents
  WHERE
    itemid IN (
      1856, /* Vecuronium mcg/min  (8 rows) */
      2164, /* NIMBEX MG/KG/HR  (243 rows) */
      2548, /* nimbex mg/kg/hr  (103 rows) */
      2285, /* nimbex mcg/kg/min  (85 rows) */
      2290, /* nimbex mcg/kg/m  (32 rows) */
      2670, /* nimbex  (38 rows) */
      2546, /* CISATRACURIUMMG/KG/H  (7 rows) */
      1098, /* cisatracurium mg/kg  (36 rows) */
      2390, /* cisatracurium mg/hr  (15 rows) */
      2511, /* CISATRACURIUM GTT  (4 rows) */
      1028, /* Cisatracurium  (208 rows) */
      1858 /* cisatracurium  (351 rows) */
    )
  GROUP BY
    icustay_id,
    charttime
), drugcv2 AS (
  SELECT
    v.*,
    SUM(drug_null) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS drug_partition
  FROM drugcv1 AS v
), drugcv3 AS (
  SELECT
    v.*,
    FIRST_VALUE(drug_rate) OVER (PARTITION BY icustay_id, drug_partition ORDER BY charttime NULLS FIRST) AS drug_prevrate_ifnull
  FROM drugcv2 AS v
), drugcv4 AS (
  SELECT
    icustay_id,
    charttime, /* , (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, drug order by charttime))) AS delta */
    drug,
    drug_rate,
    drug_amount,
    drug_stopped,
    drug_prevrate_ifnull, /* We define start time here */
    CASE
      WHEN drug = 0
      THEN NULL
      WHEN drug_rate > 0
      AND LAG(drug_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, drug, drug_null ORDER BY charttime NULLS FIRST) IS NULL
      THEN 1
      WHEN drug_rate = 0
      AND LAG(drug_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST) = 0
      THEN 0
      WHEN drug_prevrate_ifnull = 0
      AND LAG(drug_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST) = 0
      THEN 0
      WHEN LAG(drug_prevrate_ifnull, 1) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST) = 0
      THEN 1
      WHEN LAG(drug_stopped, 1) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST) = 1
      THEN 1
      WHEN (
        CHARTTIME - (
          LAG(CHARTTIME, 1) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST)
        )
      ) > (
        INTERVAL '8 HOURS'
      )
      THEN 1
      ELSE NULL
    END AS drug_start
  FROM drugcv3
), drugcv5 /* propagate start/stop flags forward in time */ AS (
  SELECT
    v.*,
    SUM(drug_start) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST) AS drug_first
  FROM drugcv4 AS v
), drugcv6 AS (
  SELECT
    v.*, /* We define end time here */
    CASE
      WHEN drug = 0
      THEN NULL
      WHEN drug_stopped = 1
      THEN drug_first
      WHEN drug_rate = 0
      THEN drug_first
      WHEN LEAD(CHARTTIME, 1) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST) IS NULL
      THEN drug_first
      ELSE NULL
    END AS drug_stop
  FROM drugcv5 AS v
), drugcv7 /* -- if you want to look at the results of the table before grouping: */ /* select */ /*   icustay_id, charttime, drug, drug_rate, drug_amount */ /*     , drug_stopped */ /*     , drug_start */ /*     , drug_first */ /*     , drug_stop */ /* from drugcv6 order by icustay_id, charttime; */ AS (
  SELECT
    icustay_id,
    charttime AS starttime,
    LEAD(charttime) OVER (PARTITION BY icustay_id, drug_first ORDER BY charttime NULLS FIRST) AS endtime,
    drug,
    drug_rate,
    drug_amount,
    drug_stop,
    drug_start,
    drug_first
  FROM drugcv6
  WHERE
    NOT drug_first IS NULL /* bogus data */
    AND drug_first <> 0 /* sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered */
    AND NOT icustay_id IS NULL /* there are data for "floating" admissions, we don't worry about these */
), drugcv8 /* table of start/stop times for event */ AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    drug,
    drug_rate,
    drug_amount,
    drug_stop,
    drug_start,
    drug_first
  FROM drugcv7
  WHERE
    NOT endtime IS NULL AND drug_rate > 0 AND starttime <> endtime
), drugcv9 /* collapse these start/stop times down if the rate doesn't change */ AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    CASE
      WHEN LAG(endtime) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST, endtime NULLS FIRST) = starttime
      AND LAG(drug_rate) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST, endtime NULLS FIRST) = drug_rate
      THEN 0
      ELSE 1
    END AS drug_groups,
    drug,
    drug_rate,
    drug_amount,
    drug_stop,
    drug_start,
    drug_first
  FROM drugcv8
  WHERE
    NOT endtime IS NULL AND drug_rate > 0 AND starttime <> endtime
), drugcv10 AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    drug_groups,
    SUM(drug_groups) OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST, endtime NULLS FIRST) AS drug_groups_sum,
    drug,
    drug_rate,
    drug_amount,
    drug_stop,
    drug_start,
    drug_first
  FROM drugcv9
), drugcv AS (
  SELECT
    icustay_id,
    MIN(starttime) AS starttime,
    MAX(endtime) AS endtime,
    drug_groups_sum,
    drug_rate,
    SUM(drug_amount) AS drug_amount
  FROM drugcv10
  GROUP BY
    icustay_id,
    drug_groups_sum,
    drug_rate
)
/* now assign this data to every hour of the patient's stay */ /* drug_amount for carevue is not accurate */
SELECT
  icustay_id,
  starttime,
  endtime,
  drug_rate,
  drug_amount
FROM drugcv
UNION
SELECT
  icustay_id,
  starttime,
  endtime,
  drug_rate,
  drug_amount
FROM drugmv
ORDER BY
  icustay_id NULLS FIRST,
  starttime NULLS FIRST