-- ------------------------------------------------------------------
-- Title: Extract height and weight for ICUSTAY_IDs
-- Description: This query gets the first, minimum, and maximum weight and height
--        for a single ICUSTAY_ID. It extracts data from the CHARTEVENTS table.
-- MIMIC version: MIMIC-III v1.4
-- ------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS heightweight CASCADE;
CREATE MATERIALIZED VIEW heightweight AS
-- prep height
WITH ht_stg0 AS
(
  SELECT 
    c.subject_id, c.icustay_id, c.charttime,
    -- Ensure that all heights are in centimeters
    CASE
      WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
        THEN c.valuenum * 2.54
      ELSE c.valuenum
    END AS height
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
, ht_stg1 AS
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
  FROM ht_stg0 h
  INNER JOIN patients pt
    ON h.subject_id = pt.subject_id
)
SELECT 
  ie.icustay_id,
  ROUND(CAST(wt.weight_first AS NUMERIC), 2) AS weight_first,
  ROUND(CAST(wt.weight_min AS NUMERIC), 2) AS weight_min,
  ROUND(CAST(wt.weight_max AS NUMERIC), 2) AS weight_max,
  ROUND(CAST(ht.height_first AS NUMERIC), 2) AS height_first,
  ROUND(CAST(ht.height_min AS NUMERIC), 2) AS height_min,
  ROUND(CAST(ht.height_max AS NUMERIC), 2) AS height_max
FROM icustays ie
-- get weight from weightdurations table
LEFT JOIN
(
  SELECT icustay_id,
    MIN(CASE WHEN rn = 1 THEN weight ELSE NULL END) as weight_first,
    MIN(weight) AS weight_min,
    MAX(weight) AS weight_max
  FROM
  (
    SELECT
      icustay_id,
      weight,
      ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime) as rn
    FROM weightdurations
  ) wt_stg
  GROUP BY icustay_id
) wt
  ON ie.icustay_id = wt.icustay_id
-- get first/min/max height from above, after filtering bad data
LEFT JOIN
(
  SELECT icustay_id,
    MIN(CASE WHEN rn = 1 THEN height ELSE NULL END) as height_first,
    MIN(height) AS height_min,
    MAX(height) AS height_max
  FROM
  (
    SELECT
      icustay_id,
      height,
      ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY charttime) as rn
    FROM ht_stg1
  ) ht_stg2
  GROUP BY icustay_id
) ht
  ON ie.icustay_id = ht.icustay_id
ORDER BY icustay_id;