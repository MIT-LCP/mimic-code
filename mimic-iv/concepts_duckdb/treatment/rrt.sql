-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.rrt; CREATE TABLE mimiciv_derived.rrt AS
WITH ce AS (
  SELECT
    ce.stay_id,
    ce.charttime,
    CASE
      WHEN ce.itemid IN (226118, 227357, 225725)
      THEN 1
      WHEN ce.itemid IN (226499, 224154, 225810, 225959, 227639, 225183, 227438, 224191, 225806, 225807, 228004, 228005, 228006, 224144, 224145, 224149, 224150, 224151, 224152, 224153, 224404, 224406, 226457)
      THEN 1
      WHEN ce.itemid IN (224135, 224139, 224146, 225323, 225740, 225776, 225951, 225952, 225953, 225954, 225956, 225958, 225961, 225963, 225965, 225976, 225977, 227124, 227290, 227638, 227640, 227753)
      THEN 1
      ELSE 0
    END AS dialysis_present,
    CASE
      WHEN ce.itemid = 225965 AND value = 'In use'
      THEN 1
      WHEN ce.itemid IN (226499, 224154, 225183, 227438, 224191, 225806, 225807, 228004, 228005, 228006, 224144, 224145, 224153, 226457)
      THEN 1
      ELSE 0
    END AS dialysis_active,
    CASE
      WHEN ce.itemid = 227290
      THEN value
      WHEN ce.itemid IN (225810, 225806, 225807, 225810, 227639, 225959, 225951, 225952, 225961, 225953, 225963, 225965, 227638, 227640)
      THEN 'Peritoneal'
      WHEN ce.itemid = 226499
      THEN 'IHD'
      ELSE NULL
    END AS dialysis_type
  FROM mimiciv_icu.chartevents AS ce
  WHERE
    ce.itemid IN (226118, 227357, 225725, 226499, 224154, 225810, 227639, 225183, 227438, 224191, 225806, 225807, 228004, 228005, 228006, 224144, 224145, 224149, 224150, 224151, 224152, 224153, 224404, 224406, 226457, 225959, 224135, 224139, 224146, 225323, 225740, 225776, 225951, 225952, 225953, 225954, 225956, 225958, 225961, 225963, 225965, 225976, 225977, 227124, 227290, 227638, 227640, 227753)
    AND NOT ce.value IS NULL
), mv_ranges AS (
  SELECT
    stay_id,
    starttime,
    endtime,
    1 AS dialysis_present,
    1 AS dialysis_active,
    'CRRT' AS dialysis_type
  FROM mimiciv_icu.inputevents
  WHERE
    itemid IN (227536, 227525) AND amount > 0
  UNION
  SELECT
    stay_id,
    starttime,
    endtime,
    1 AS dialysis_present,
    CASE WHEN NOT itemid IN (224270, 225436) THEN 1 ELSE 0 END AS dialysis_active,
    CASE
      WHEN itemid = 225441
      THEN 'IHD'
      WHEN itemid = 225802
      THEN 'CRRT'
      WHEN itemid = 225803
      THEN 'CVVHD'
      WHEN itemid = 225805
      THEN 'Peritoneal'
      WHEN itemid = 225809
      THEN 'CVVHDF'
      WHEN itemid = 225955
      THEN 'SCUF'
      ELSE NULL
    END AS dialysis_type
  FROM mimiciv_icu.procedureevents
  WHERE
    itemid IN (225441, 225802, 225803, 225805, 224270, 225809, 225955, 225436)
    AND NOT value IS NULL
), stg0 AS (
  SELECT
    stay_id,
    charttime,
    dialysis_present,
    dialysis_active,
    dialysis_type
  FROM ce
  WHERE
    dialysis_present = 1
  UNION
  SELECT
    stay_id,
    starttime AS charttime,
    dialysis_present,
    dialysis_active,
    dialysis_type
  FROM mv_ranges
)
SELECT
  stg0.stay_id,
  charttime,
  COALESCE(mv.dialysis_present, stg0.dialysis_present) AS dialysis_present,
  COALESCE(mv.dialysis_active, stg0.dialysis_active) AS dialysis_active,
  COALESCE(mv.dialysis_type, stg0.dialysis_type) AS dialysis_type
FROM stg0
LEFT JOIN mv_ranges AS mv
  ON stg0.stay_id = mv.stay_id
  AND stg0.charttime >= mv.starttime
  AND stg0.charttime <= mv.endtime