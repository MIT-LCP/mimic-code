-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.crrt_durations; CREATE TABLE mimiciii_derived.crrt_durations AS
WITH crrt_settings AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    MAX(
      CASE
        WHEN ce.itemid IN (
          224149,
          224144,
          228004,
          225183,
          225977,
          224154,
          224151,
          224150,
          225958,
          224145,
          224191,
          228005,
          228006,
          225976,
          224153,
          224152,
          226457
        )
        THEN 1
        WHEN ce.itemid IN (29, 173, 192, 624, 79, 142, 146, 611, 5683)
        THEN 1
        WHEN ce.itemid = 665
        AND value IN ('Active', 'Clot Increasing', 'Clots Present', 'No Clot Present')
        THEN 1
        WHEN ce.itemid = 147 AND value = 'Yes'
        THEN 1
        ELSE 0
      END
    ) AS RRT,
    MAX(
      CASE
        WHEN ce.itemid = 224146 AND value IN ('New Filter', 'Reinitiated')
        THEN 1
        WHEN ce.itemid = 665 AND value IN ('Initiated')
        THEN 1
        ELSE 0
      END
    ) AS RRT_start,
    MAX(
      CASE
        WHEN ce.itemid = 224146 AND value IN ('Discontinued', 'Recirculating')
        THEN 1
        WHEN ce.itemid = 665 AND (
          value = 'Clotted' OR value LIKE 'DC%'
        )
        THEN 1
        WHEN ce.itemid = 225956
        THEN 1
        ELSE 0
      END
    ) AS RRT_end
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.itemid IN (
      224146,
      225956,
      224149,
      224144,
      228004,
      225183,
      225977,
      224154,
      224151,
      224150,
      225958,
      224145,
      224191,
      228005,
      228006,
      225976,
      224153,
      224152,
      226457,
      665,
      147,
      612,
      29,
      173,
      192,
      624,
      142,
      79,
      146,
      611,
      5683
    )
    AND NOT ce.value IS NULL
    AND COALESCE(ce.valuenum, 1) <> 0
  GROUP BY
    icustay_id,
    charttime
), vd_lag AS (
  SELECT
    icustay_id,
    LAG(CHARTTIME, 1) OVER W AS charttime_prev_row,
    charttime,
    RRT,
    RRT_start,
    RRT_end,
    LAG(RRT_end, 1) OVER W AS rrt_ended_prev_row
  FROM crrt_settings
  WINDOW w AS (
    PARTITION BY icustay_id, CASE WHEN RRT = 1 OR RRT_end = 1 THEN 1 ELSE 0 END
    ORDER BY charttime NULLS FIRST
  )
), vd1 AS (
  SELECT
    icustay_id,
    charttime,
    RRT,
    RRT_start,
    RRT_end,
    CASE
      WHEN RRT_start = 1
      THEN 1
      WHEN RRT_end = 1
      THEN 0
      WHEN rrt_ended_prev_row = 1
      THEN 1
      WHEN DATE_DIFF('HOUR', charttime_prev_row, charttime) <= 2
      THEN 0
      ELSE 1
    END AS NewCRRT
  FROM vd_lag
), vd2 AS (
  SELECT
    vd1.*,
    CASE
      WHEN RRT_start = 1 OR RRT = 1 OR RRT_end = 1
      THEN SUM(NewCRRT) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST)
      ELSE NULL
    END AS num
  FROM vd1
  WHERE
    RRT_start = 1 OR RRT = 1 OR RRT_end = 1
), fin AS (
  SELECT
    icustay_id,
    num,
    MIN(charttime) AS starttime,
    MAX(charttime) AS endtime,
    DATE_DIFF('HOUR', MIN(charttime), MAX(charttime)) AS duration_hours
  FROM vd2
  GROUP BY
    icustay_id,
    num
  HAVING
    MIN(charttime) <> MAX(charttime)
)
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS num,
  starttime,
  endtime,
  duration_hours
FROM fin
ORDER BY
  icustay_id NULLS FIRST,
  num NULLS FIRST