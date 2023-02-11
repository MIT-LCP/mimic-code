-- prep height
WITH ht_in AS (
    SELECT
        c.subject_id, c.stay_id, c.charttime
        -- Ensure that all heights are in centimeters
        , ROUND(CAST(c.valuenum * 2.54 AS NUMERIC), 2) AS height
        , c.valuenum AS height_orig
    FROM `physionet-data.mimiciv_icu.chartevents` c
    WHERE c.valuenum IS NOT NULL
        -- Height (measured in inches)
        AND c.itemid = 226707
)

, ht_cm AS (
    SELECT
        c.subject_id, c.stay_id, c.charttime
        -- Ensure that all heights are in centimeters
        , ROUND(CAST(c.valuenum AS NUMERIC), 2) AS height
    FROM `physionet-data.mimiciv_icu.chartevents` c
    WHERE c.valuenum IS NOT NULL
        -- Height cm
        AND c.itemid = 226730
)

-- merge cm/height, only take 1 value per charted row
, ht_stg0 AS (
    SELECT
        COALESCE(h1.subject_id, h1.subject_id) AS subject_id
        , COALESCE(h1.stay_id, h1.stay_id) AS stay_id
        , COALESCE(h1.charttime, h1.charttime) AS charttime
        , COALESCE(h1.height, h2.height) AS height
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
