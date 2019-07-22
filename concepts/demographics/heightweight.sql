-- ------------------------------------------------------------------
-- Title: Extract height and weight for ICUSTAY_IDs
-- Description: This query gets the first, minimum, and maximum weight and height
--        for a single ICUSTAY_ID. It extracts data from the CHARTEVENTS table.
-- MIMIC version: MIMIC-III v1.4
-- ------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS heightweight CASCADE;
CREATE MATERIALIZED VIEW heightweight AS
-- prep height
WITH ht_stg AS
(
  SELECT 
    c.subject_id, c.icustay_id, c.charttime,
    -- Ensure that all heights are in centimeters
    CASE
      WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
        THEN c.valuenum * 2.54
      ELSE c.valuenum
    END AS valuenum as height
  FROM chartevents c
  WHERE c.valuenum IS NOT NULL
  AND c.valuenum != 0
  -- exclude rows marked as error
  AND COALESCE(c.error, 0) = 0
  AND c.itemid IN
  (
    -- CareVue
    920, 1394, 4187, 3486,                    -- Height inches
    3485, 4188                                -- Height cm
    -- Metavision
    , 226707 -- Height (measured in inches)
    -- note we intentionally ignore the below ITEMID in metavision
    -- these are duplicate data in a different unit
    -- , 226730 -- Height (cm)
  )
)
-- filter out bad heights
, ht_fix AS
(
  SELECT
    icustay_id
    , charttime
    , CASE
        -- rule for neonates
        WHEN charttime <= (pt.dob + interval '1' year) AND height < 80 THEN height
        -- rule for adults
        WHEN charttime >  (pt.dob + interval '1' year) AND height > 120 AND height < 230 THEN height
      ELSE NULL END as height
  FROM ht_stg h
  INNER JOIN patients pt
    ON h.subject_id = pt.subject_id
)
-- get first/min/max height from above, after filtering bad data
, ht AS
(
  SELECT
    icustay_id,
    FIRST_VALUE(valuenum) over W AS height_first,
    MIN(valuenum) over W AS height_min,
    MAX(valuenum) over W AS height_max
    FROM ht_fix
    WINDOW W AS
    (
      PARTITION BY icustay_id
      ORDER BY charttime
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
)
-- get weight from weightdurations table
, wt AS
(
  SELECT
    icustay_id,
    FIRST_VALUE(valuenum) over W AS weight_first,
    MIN(valuenum) over W AS weight_min,
    MAX(valuenum) over W AS weight_max
    FROM weightdurations
    WINDOW W AS
    (
      PARTITION BY icustay_id
      ORDER BY charttime
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
)
SELECT 
  ie.icustay_id,
  ROUND(CAST(wt.weight_first AS NUMERIC), 2) AS weight_first,
  ROUND(CAST(wt.weight_min AS NUMERIC), 2) AS weight_min,
  ROUND(CAST(wt.weight_max AS NUMERIC), 2) AS weight_max
  ROUND(CAST(h.height_first AS NUMERIC), 2) AS height_first,
  ROUND(CAST(h.height_min AS NUMERIC), 2) AS height_min,
  ROUND(CAST(h.height_max AS NUMERIC), 2) AS height_max
FROM icustays ie
LEFT JOIN wt
  ON ie.icustay_id = wt.icustay_id
LEFT JOIN ht
  ON ie.icustay_id = ht.icustay_id
ORDER BY icustay_id;