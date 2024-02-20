-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.height; CREATE TABLE mimiciv_derived.height AS
WITH ht_in AS (
  SELECT
    c.subject_id,
    c.stay_id,
    c.charttime,
    ROUND(TRY_CAST(c.valuenum * 2.54 AS DECIMAL), 2) AS height,
    c.valuenum AS height_orig
  FROM mimiciv_icu.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL AND c.itemid = 226707
), ht_cm AS (
  SELECT
    c.subject_id,
    c.stay_id,
    c.charttime,
    ROUND(TRY_CAST(c.valuenum AS DECIMAL), 2) AS height
  FROM mimiciv_icu.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL AND c.itemid = 226730
), ht_stg0 AS (
  SELECT
    COALESCE(h1.subject_id, h1.subject_id) AS subject_id,
    COALESCE(h1.stay_id, h1.stay_id) AS stay_id,
    COALESCE(h1.charttime, h1.charttime) AS charttime,
    COALESCE(h1.height, h2.height) AS height
  FROM ht_cm AS h1
  FULL OUTER JOIN ht_in AS h2
    ON h1.subject_id = h2.subject_id AND h1.charttime = h2.charttime
)
SELECT
  subject_id,
  stay_id,
  charttime,
  height
FROM ht_stg0
WHERE
  NOT height IS NULL AND height > 120 AND height < 230