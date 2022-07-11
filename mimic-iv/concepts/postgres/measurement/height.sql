-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS height; CREATE TABLE height AS 
-- prep height
WITH ht_in AS
(
  SELECT 
    c.subject_id, c.stay_id, c.charttime
    -- Ensure that all heights are in centimeters
    , ROUND( CAST( c.valuenum * 2.54 as numeric),2) AS height
    , c.valuenum as height_orig
  FROM mimiciv_icu.chartevents c
  WHERE c.valuenum IS NOT NULL
  -- Height (measured in inches)
  AND c.itemid = 226707
)
, ht_cm AS
(
  SELECT 
    c.subject_id, c.stay_id, c.charttime
    -- Ensure that all heights are in centimeters
    , ROUND( CAST( c.valuenum as numeric),2) AS height
  FROM mimiciv_icu.chartevents c
  WHERE c.valuenum IS NOT NULL
  -- Height cm
  AND c.itemid = 226730
)
-- merge cm/height, only take 1 value per charted row
, ht_stg0 AS
(
  SELECT
  COALESCE(h1.subject_id, h1.subject_id) as subject_id
  , COALESCE(h1.stay_id, h1.stay_id) AS stay_id
  , COALESCE(h1.charttime, h1.charttime) AS charttime
  , COALESCE(h1.height, h2.height) as height
  FROM ht_cm h1
  FULL OUTER JOIN ht_in h2
    ON h1.subject_id = h2.subject_id
    AND h1.charttime = h2.charttime
)
SELECT subject_id, stay_id, charttime, height
FROM ht_stg0
WHERE height IS NOT NULL
-- filter out bad heights
AND height > 120 AND height < 230;