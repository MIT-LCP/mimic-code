WITH t0 AS
(
SELECT icustay_id
, charttime
, MAX(mechvent) AS mechvent
, MAX(niv) AS niv
, MAX(choiceventilation) AS choiceventilation
, MAX(oxygentherapy) AS oxygentherapy
, MAX(tracheostomy) AS tracheostomy
, MAX(extubated) AS extubated
FROM `physionet-data.mimic_derived.ventilation_classification`
GROUP BY icustay_id, charttime
)
-- remove conflict rows
, t0_clean AS
(
SELECT icustay_id
, charttime
, mechvent
, niv
, choiceventilation
, oxygentherapy
-- remove conflicting NIV/trach rows
-- e.g. 234725, 234373
, CASE WHEN tracheostomy = 1 AND niv = 1 THEN 0 ELSE tracheostomy END AS tracheostomy
, extubated
FROM t0
)
-- merge together consecutive rows which have the same vent config
-- i.e. two consecutive mechvent rows will be merged into one
, t1 AS
(
SELECT icustay_id
, charttime
, CASE
    WHEN LAG(mechvent, 1) OVER w != mechvent THEN 1
    WHEN LAG(niv, 1) OVER w != niv THEN 1
    WHEN LAG(choiceventilation, 1) OVER w != choiceventilation THEN 1
    WHEN LAG(oxygentherapy, 1) OVER w != oxygentherapy THEN 1
    WHEN LAG(tracheostomy, 1) OVER w != tracheostomy THEN 1
    WHEN LAG(extubated, 1) OVER w != extubated THEN 1
    WHEN DATETIME_DIFF(charttime, LAG(charttime, 1) OVER w, HOUR) >= 14 THEN 1 
ELSE 0 END AS row_changed
, mechvent, niv, choiceventilation, oxygentherapy, tracheostomy, extubated
FROM t0_clean
WINDOW w AS (PARTITION BY icustay_id ORDER BY charttime)
)
, t2 AS
(
SELECT icustay_id, charttime
, SUM(row_changed) OVER (PARTITION BY icustay_id ORDER BY charttime) AS row_partition
, mechvent, niv, choiceventilation, oxygentherapy, tracheostomy, extubated
FROM t1
)
, t3 AS
(
SELECT
  icustay_id
, row_partition
, MIN(charttime) AS charttime_min
, MAX(charttime) AS charttime_max
, MAX(mechvent) AS mechvent
, MAX(niv) AS niv
, MAX(choiceventilation) AS choiceventilation
, MAX(oxygentherapy) AS oxygentherapy
, MAX(tracheostomy) AS tracheostomy
, MAX(extubated) AS extubated
from t2
GROUP BY icustay_id, row_partition
)
, ventflags AS
(
    SELECT icustay_id
    , max(niv) as has_niv
    , max(mechvent) as has_mechvent
    FROM t3
    GROUP BY icustay_id
)
-- infer mechvent/niv if surrounded by the mode using following rules:
--   if a set of choice ventilation rows immediately follow mechvent/niv, carry it forward
--   if a set of choice ventilation rows are followed immediately by mechvent/niv (at start of stay), carry it backward
, t4 AS
(
    SELECT t3.icustay_id
    , row_partition
    , charttime_min
    , charttime_max
    , CASE
        WHEN choiceventilation = 0 THEN mechvent
        -- follows mechvent -> mechvent
        WHEN LAG(mechvent, 1) OVER w = 1
            THEN 1
        -- before mechvent, but not after NIV -> mechvent
        -- the coalesce allows setting the first row for an icustay_id to 1
        WHEN LEAD(mechvent, 1) OVER w = 1
        AND COALESCE(LAG(niv, 1) OVER w, 0) = 0
            THEN 1
        -- if they have a trach in the past -> must be mechvent
        WHEN MAX(tracheostomy) OVER w = 1
            THEN 1
        -- if they only ever have mechvent, and never NIV, -> NIV
        -- this rule applies to ~800 icustay_id
        WHEN vf.has_mechvent = 1 AND vf.has_niv = 0
            THEN 1
    ELSE mechvent END AS mechvent
    , CASE
        -- if they have a trach in the past -> cannot be NIV
        WHEN MAX(tracheostomy) OVER w = 1
            THEN 0
        WHEN choiceventilation = 0 THEN niv
        -- follows NIV, then NIV
        WHEN LAG(niv, 1) OVER w = 1
            THEN 1
        -- before NIV, but not after mechvent -> NIV
        WHEN LEAD(niv, 1) OVER w = 1
        AND COALESCE(LAG(mechvent, 1) OVER w, 0) = 0
            THEN 1
        -- if they only ever have NIV, and never mechvent, -> NIV
        WHEN vf.has_mechvent = 0 AND vf.has_niv = 1
            THEN 1
    ELSE niv END AS niv
    , choiceventilation, oxygentherapy, tracheostomy, extubated
    FROM t3
    LEFT JOIN ventflags vf
      ON t3.icustay_id = vf.icustay_id
    WINDOW w AS (PARTITION BY t3.icustay_id ORDER BY row_partition)
)
-- update choice ventilation column to reflect above updates in mechvent/niv
, t5 AS
( 
    SELECT icustay_id
    , row_partition
    , charttime_min
    , charttime_max
    , mechvent, niv
    , CASE
        WHEN mechvent = 1 THEN 0
        WHEN niv = 1 THEN 0
    ELSE choiceventilation END AS choiceventilation
    , oxygentherapy, tracheostomy, extubated
    FROM t4
)
-- merge together consecutive identical rows, as we did above in t1-t3
, t6 AS
(
    SELECT tmp.*
    , SUM(row_changed) OVER (PARTITION BY icustay_id ORDER BY charttime_min) AS row_partition
    FROM (
        SELECT t5.icustay_id
        , charttime_min, charttime_max
        , mechvent, niv, choiceventilation
        , oxygentherapy, tracheostomy, extubated
        , CASE
            WHEN LAG(mechvent, 1) OVER w != mechvent THEN 1
            WHEN LAG(niv, 1) OVER w != niv THEN 1
            WHEN LAG(choiceventilation, 1) OVER w != choiceventilation THEN 1
            WHEN LAG(oxygentherapy, 1) OVER w != oxygentherapy THEN 1
            WHEN LAG(tracheostomy, 1) OVER w != tracheostomy THEN 1
            WHEN LAG(extubated, 1) OVER w != extubated THEN 1
        ELSE 0 END AS row_changed
        FROM t5
        WINDOW w AS (PARTITION BY icustay_id ORDER BY charttime_min)
    ) tmp
)
, t7 AS
(
    SELECT
    icustay_id
    , row_partition
    , MIN(charttime_min) AS charttime_min
    , MAX(charttime_max) AS charttime_max
    , MAX(mechvent) AS mechvent
    , MAX(niv) AS niv
    , MAX(choiceventilation) AS choiceventilation
    , MAX(oxygentherapy) AS oxygentherapy
    , MAX(tracheostomy) AS tracheostomy
    , MAX(extubated) AS extubated
    from t6
    GROUP BY icustay_id, row_partition
)
SELECT
  icustay_id
  , row_partition
  , charttime_min
  , charttime_max
  , mechvent, niv
  , choiceventilation
  , oxygentherapy, tracheostomy, extubated
FROM t7
WINDOW w AS (PARTITION BY icustay_id ORDER BY row_partition)
ORDER BY icustay_id, row_partition