-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.central_line_durations; CREATE TABLE mimiciii_derived.central_line_durations AS
WITH mv AS (
  SELECT
    pe.icustay_id,
    pe.starttime,
    pe.endtime,
    CASE
      WHEN (
        locationcategory <> 'Invasive Arterial' OR locationcategory IS NULL
      )
      THEN 1
      ELSE 0
    END AS central_line
  FROM mimiciii.procedureevents_mv AS pe
  WHERE
    pe.itemid IN (
      224263,
      224264,
      224267,
      224268,
      225199,
      225202,
      225203,
      225315,
      225752,
      227719,
      224270
    )
), cv_grp AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    MAX(CASE WHEN itemid = 229 THEN value ELSE NULL END) AS INV1_Type,
    MAX(CASE WHEN itemid = 8392 THEN value ELSE NULL END) AS INV1_Site,
    MAX(CASE WHEN itemid = 235 THEN value ELSE NULL END) AS INV2_Type,
    MAX(CASE WHEN itemid = 8393 THEN value ELSE NULL END) AS INV2_Site,
    MAX(CASE WHEN itemid = 241 THEN value ELSE NULL END) AS INV3_Type,
    MAX(CASE WHEN itemid = 8394 THEN value ELSE NULL END) AS INV3_Site,
    MAX(CASE WHEN itemid = 247 THEN value ELSE NULL END) AS INV4_Type,
    MAX(CASE WHEN itemid = 8395 THEN value ELSE NULL END) AS INV4_Site,
    MAX(CASE WHEN itemid = 253 THEN value ELSE NULL END) AS INV5_Type,
    MAX(CASE WHEN itemid = 8396 THEN value ELSE NULL END) AS INV5_Site,
    MAX(CASE WHEN itemid = 259 THEN value ELSE NULL END) AS INV6_Type,
    MAX(CASE WHEN itemid = 8397 THEN value ELSE NULL END) AS INV6_Site,
    MAX(CASE WHEN itemid = 265 THEN value ELSE NULL END) AS INV7_Type,
    MAX(CASE WHEN itemid = 8398 THEN value ELSE NULL END) AS INV7_Site,
    MAX(CASE WHEN itemid = 271 THEN value ELSE NULL END) AS INV8_Type,
    MAX(CASE WHEN itemid = 8399 THEN value ELSE NULL END) AS INV8_Site
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.itemid IN (
      229,
      235,
      241,
      247,
      253,
      259,
      265,
      271,
      8392,
      8393,
      8394,
      8395,
      8396,
      8397,
      8398,
      8399
    )
    AND NOT ce.value IS NULL
  GROUP BY
    ce.icustay_id,
    ce.charttime
), cv AS (
  SELECT DISTINCT
    icustay_id,
    charttime
  FROM cv_grp
  WHERE
    (
      inv1_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
    OR (
      inv2_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
    OR (
      inv3_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
    OR (
      inv4_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
    OR (
      inv5_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
    OR (
      inv6_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
    OR (
      inv7_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
    OR (
      inv8_type IN (
        'Multi-lumen',
        'PICC line',
        'Dialysis Line',
        'Introducer',
        'Trauma Line',
        'Portacath',
        'Venous Access',
        'Hickman',
        'PacerIntroducer',
        'TripleIntroducer'
      )
    )
), cv0 AS (
  SELECT
    icustay_id,
    LAG(CHARTTIME, 1) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS charttime_lag,
    charttime
  FROM cv
), cv1 AS (
  SELECT
    icustay_id,
    charttime,
    charttime_lag,
    DATE_DIFF('HOUR', charttime_lag, charttime) AS central_line_duration,
    CASE WHEN DATE_DIFF('HOUR', charttime_lag, charttime) > 16 THEN 1 ELSE 0 END AS central_line_new
  FROM cv0
), cv2 AS (
  SELECT
    cv1.*,
    SUM(central_line_new) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS central_line_rownum
  FROM cv1
), cv_dur AS (
  SELECT
    icustay_id,
    central_line_rownum,
    MIN(charttime) AS starttime,
    MAX(charttime) AS endtime,
    DATE_DIFF('HOUR', MIN(charttime), MAX(charttime)) AS duration_hours
  FROM cv2
  GROUP BY
    icustay_id,
    central_line_rownum
  HAVING
    MIN(charttime) <> MAX(charttime)
)
SELECT
  icustay_id,
  starttime,
  endtime,
  duration_hours
FROM cv_dur
UNION ALL
SELECT
  icustay_id,
  starttime,
  endtime,
  DATE_DIFF('HOUR', starttime, endtime) AS duration_hours
FROM mv
WHERE
  central_line = 1
ORDER BY
  icustay_id NULLS FIRST,
  starttime NULLS FIRST