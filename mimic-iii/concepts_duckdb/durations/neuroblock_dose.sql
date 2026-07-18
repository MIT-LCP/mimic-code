-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.neuroblock_dose; CREATE TABLE mimiciii_derived.neuroblock_dose AS
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
    itemid IN (222062, 221555)
    AND statusdescription <> 'Rewritten'
    AND NOT rate IS NULL
), drugcv1 AS (
  SELECT
    icustay_id,
    charttime,
    1 AS drug,
    MAX(CASE WHEN stopped IN ('Stopped', 'D/C' || 'd') THEN 1 ELSE 0 END) AS drug_stopped,
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
      30114,
      30138,
      30113,
      42174,
      42385,
      41916,
      42100,
      42045,
      42246,
      42291,
      42590,
      42284,
      45096
    )
  GROUP BY
    icustay_id,
    charttime
  UNION
  SELECT
    icustay_id,
    charttime,
    1 AS drug,
    MAX(CASE WHEN stopped IN ('Stopped', 'D/C' || 'd') THEN 1 ELSE 0 END) AS drug_stopped,
    MAX(CASE WHEN valuenum <= 10 THEN 0 ELSE 1 END) AS drug_null,
    MAX(CASE WHEN valuenum <= 10 THEN valuenum ELSE NULL END) AS drug_rate,
    MAX(CASE WHEN valuenum > 10 THEN valuenum ELSE NULL END) AS drug_amount
  FROM mimiciii.chartevents
  WHERE
    itemid IN (1856, 2164, 2548, 2285, 2290, 2670, 2546, 1098, 2390, 2511, 1028, 1858)
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
    charttime,
    drug,
    drug_rate,
    drug_amount,
    drug_stopped,
    drug_prevrate_ifnull,
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
        INTERVAL '8' HOURS
      )
      THEN 1
      ELSE NULL
    END AS drug_start
  FROM drugcv3
), drugcv5 AS (
  SELECT
    v.*,
    SUM(drug_start) OVER (PARTITION BY icustay_id, drug ORDER BY charttime NULLS FIRST) AS drug_first
  FROM drugcv4 AS v
), drugcv6 AS (
  SELECT
    v.*,
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
), drugcv7 AS (
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
    NOT drug_first IS NULL AND drug_first <> 0 AND NOT icustay_id IS NULL
), drugcv8 AS (
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
), drugcv9 AS (
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