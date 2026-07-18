-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_invasive_lines; CREATE TABLE mimiciii_derived.pivoted_invasive_lines AS
WITH stg0 AS (
  SELECT
    icustay_id,
    charttime,
    storetime,
    itemid,
    CASE
      WHEN itemid IN (229, 8392)
      THEN 1
      WHEN itemid IN (235, 8393)
      THEN 2
      WHEN itemid IN (241, 8394)
      THEN 3
      WHEN itemid IN (247, 8395)
      THEN 4
      WHEN itemid IN (253, 8396)
      THEN 5
      WHEN itemid IN (259, 8397)
      THEN 6
      WHEN itemid IN (265, 8398)
      THEN 7
      WHEN itemid IN (271, 8399)
      THEN 8
      ELSE NULL
    END AS line_number,
    CASE WHEN itemid < 8000 THEN value ELSE NULL END AS line_type,
    CASE WHEN itemid > 8000 THEN value ELSE NULL END AS line_site,
    CASE
      WHEN ce.stopped = 'D/C''d'
      THEN 1
      WHEN ce.stopped = 'NotStopd'
      THEN 0
      ELSE NULL
    END AS line_dc
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
    AND NOT icustay_id IS NULL
    AND COALESCE(ce.error, 0) = 0
), stg0_rn AS (
  SELECT
    icustay_id,
    charttime,
    line_number,
    line_type,
    line_site,
    line_dc,
    ROW_NUMBER() OVER (PARTITION BY icustay_id, charttime, itemid ORDER BY storetime DESC) AS rn_last_stored
  FROM stg0
), stg1 AS (
  SELECT
    icustay_id,
    charttime,
    line_number,
    MAX(line_type) AS line_type,
    MAX(line_site) AS line_site,
    MAX(line_dc) AS line_dc
  FROM stg0_rn
  WHERE
    rn_last_stored = 1
  GROUP BY
    icustay_id,
    charttime,
    line_number
), stg2 AS (
  SELECT
    icustay_id,
    charttime,
    line_number,
    line_type,
    line_site,
    line_dc,
    CASE
      WHEN LAG(line_dc) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime NULLS FIRST) = 1
      THEN 1
      WHEN LAG(line_type) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime NULLS FIRST) = line_type
      AND DATE_DIFF(
        'HOUR',
        LAG(charttime) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime NULLS FIRST),
        charttime
      ) < 16
      THEN 0
      ELSE 1
    END AS rn_part
  FROM stg1
), stg3 AS (
  SELECT
    icustay_id,
    charttime,
    line_number,
    line_type,
    line_site,
    line_dc,
    SUM(rn_part) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime NULLS FIRST) AS line_event
  FROM stg2
), stg4 AS (
  SELECT
    icustay_id,
    line_number,
    line_event,
    line_type,
    line_site,
    MIN(charttime) AS starttime,
    MAX(charttime) AS endtime
  FROM stg3
  WHERE
    line_dc = 0
  GROUP BY
    icustay_id,
    line_number,
    line_event,
    line_type,
    line_site
), mv AS (
  SELECT
    icustay_id,
    mv.itemid AS line_number,
    di.label AS line_type,
    mv.location AS line_site,
    starttime,
    endtime
  FROM mimiciii.procedureevents_mv AS mv
  INNER JOIN mimiciii.d_items AS di
    ON mv.itemid = di.itemid
  WHERE
    mv.itemid IN (
      227719,
      225752,
      224269,
      224267,
      224270,
      224272,
      226124,
      228169,
      225202,
      228286,
      225204,
      224263,
      224560,
      224264,
      225203,
      224273,
      225789,
      225761,
      228201,
      228202,
      224268,
      225199,
      225315,
      225205
    )
    AND NOT icustay_id IS NULL
    AND statusdescription <> 'Rewritten'
), combined AS (
  SELECT
    icustay_id,
    line_type,
    line_site,
    starttime,
    endtime
  FROM stg4
  UNION
  SELECT
    icustay_id,
    line_type,
    line_site,
    starttime,
    endtime
  FROM mv
)
SELECT
  icustay_id,
  CASE
    WHEN line_type IN ('Arterial Line', 'A-Line')
    THEN 'Arterial'
    WHEN line_type IN ('CCO PA Line', 'CCO PAC')
    THEN 'Continuous Cardiac Output PA'
    WHEN line_type IN ('Dialysis Catheter', 'Dialysis Line')
    THEN 'Dialysis'
    WHEN line_type IN ('Hickman', 'Tunneled (Hickman) Line')
    THEN 'Hickman'
    WHEN line_type IN ('IABP', 'IABP line')
    THEN 'IABP'
    WHEN line_type IN ('Multi Lumen', 'Multi-lumen')
    THEN 'Multi Lumen'
    WHEN line_type IN ('PA Catheter', 'PA line')
    THEN 'PA'
    WHEN line_type IN ('PICC Line', 'PICC line')
    THEN 'PICC'
    WHEN line_type IN ('Pre-Sep Catheter', 'Presep Catheter')
    THEN 'Pre-Sep'
    WHEN line_type IN ('Trauma Line', 'Trauma line')
    THEN 'Trauma'
    WHEN line_type IN ('Triple Introducer', 'TripleIntroducer')
    THEN 'Triple Introducer'
    WHEN line_type IN ('Portacath', 'Indwelling Port (PortaCath)')
    THEN 'Portacath'
    ELSE line_type
  END AS line_type,
  CASE
    WHEN line_site IN ('Left Antecub', 'Left Antecube')
    THEN 'Left Antecube'
    WHEN line_site IN ('Left Axilla', 'Left Axilla.')
    THEN 'Left Axilla'
    WHEN line_site IN ('Left Brachial', 'Left Brachial.')
    THEN 'Left Brachial'
    WHEN line_site IN ('Left Femoral', 'Left Femoral.')
    THEN 'Left Femoral'
    WHEN line_site IN ('Right Antecub', 'Right Antecube')
    THEN 'Right Antecube'
    WHEN line_site IN ('Right Axilla', 'Right Axilla.')
    THEN 'Right Axilla'
    WHEN line_site IN ('Right Brachial', 'Right Brachial.')
    THEN 'Right Brachial'
    WHEN line_site IN ('Right Femoral', 'Right Femoral.')
    THEN 'Right Femoral'
    ELSE line_site
  END AS line_site,
  starttime,
  endtime
FROM combined
ORDER BY
  icustay_id NULLS FIRST,
  starttime NULLS FIRST,
  line_type NULLS FIRST,
  line_site NULLS FIRST