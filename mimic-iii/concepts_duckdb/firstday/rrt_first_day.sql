-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.rrt_first_day; CREATE TABLE mimiciii_derived.rrt_first_day AS
WITH cv AS (
  SELECT
    ie.icustay_id,
    MAX(
      CASE
        WHEN ce.itemid IN (152, 148, 149, 146, 147, 151, 150) AND NOT value IS NULL
        THEN 1
        WHEN ce.itemid IN (229, 235, 241, 247, 253, 259, 265, 271) AND value = 'Dialysis Line'
        THEN 1
        WHEN ce.itemid = 582
        AND value IN (
          'CAVH Start',
          'CAVH D/C',
          'CVVHD Start',
          'CVVHD D/C',
          'Hemodialysis st',
          'Hemodialysis end'
        )
        THEN 1
        ELSE 0
      END
    ) AS RRT
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.chartevents AS ce
    ON ie.icustay_id = ce.icustay_id
    AND ce.itemid IN (152, 148, 149, 146, 147, 151, 150, 229, 235, 241, 247, 253, 259, 265, 271, 582)
    AND NOT ce.value IS NULL
    AND ce.charttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
  WHERE
    ie.dbsource = 'carevue'
  GROUP BY
    ie.icustay_id
), mv_ce AS (
  SELECT
    ie.icustay_id,
    1 AS RRT
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.chartevents AS ce
    ON ie.icustay_id = ce.icustay_id
    AND ce.charttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
    AND itemid IN (
      226118,
      227357,
      225725,
      226499,
      224154,
      225810,
      227639,
      225183,
      227438,
      224191,
      225806,
      225807,
      228004,
      228005,
      228006,
      224144,
      224145,
      224149,
      224150,
      224151,
      224152,
      224153,
      224404,
      224406,
      226457
    )
    AND valuenum > 0
  GROUP BY
    ie.icustay_id
), mv_ie AS (
  SELECT
    ie.icustay_id,
    1 AS RRT
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.inputevents_mv AS tt
    ON ie.icustay_id = tt.icustay_id
    AND tt.starttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
    AND itemid IN (227536, 227525)
    AND amount > 0
  GROUP BY
    ie.icustay_id
), mv_de AS (
  SELECT
    ie.icustay_id,
    1 AS RRT
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.datetimeevents AS tt
    ON ie.icustay_id = tt.icustay_id
    AND tt.charttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
    AND itemid IN (225318, 225319, 225321, 225322, 225324)
  GROUP BY
    ie.icustay_id
), mv_pe AS (
  SELECT
    ie.icustay_id,
    1 AS RRT
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.procedureevents_mv AS tt
    ON ie.icustay_id = tt.icustay_id
    AND tt.starttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
    AND itemid IN (225441, 225802, 225803, 225805, 224270, 225809, 225955, 225436)
  GROUP BY
    ie.icustay_id
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  CASE
    WHEN cv.RRT = 1
    THEN 1
    WHEN mv_ce.RRT = 1
    THEN 1
    WHEN mv_ie.RRT = 1
    THEN 1
    WHEN mv_de.RRT = 1
    THEN 1
    WHEN mv_pe.RRT = 1
    THEN 1
    ELSE 0
  END AS rrt
FROM mimiciii.icustays AS ie
LEFT JOIN cv
  ON ie.icustay_id = cv.icustay_id
LEFT JOIN mv_ce
  ON ie.icustay_id = mv_ce.icustay_id
LEFT JOIN mv_ie
  ON ie.icustay_id = mv_ie.icustay_id
LEFT JOIN mv_de
  ON ie.icustay_id = mv_de.icustay_id
LEFT JOIN mv_pe
  ON ie.icustay_id = mv_pe.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST