-- This query extracts heights for adult ICU patients.
-- It uses all information from the patient's first ICU day.
-- This is done for consistency with other queries - it's not necessarily needed.
-- Height is unlikely to change throughout a patient's stay.

-- The MIMIC-III version used echo data, this is not available in MIMIC-IV v0.4
WITH ce AS
(
    SELECT
      c.stay_id
      , AVG(valuenum) as Height_chart
    FROM `physionet-data.mimic_icu.chartevents` c
    INNER JOIN`physionet-data.mimic_icu.icustays` ie ON
        c.stay_id = ie.stay_id
        AND c.charttime BETWEEN DATETIME_SUB(ie.intime, INTERVAL '1' DAY) AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    WHERE c.valuenum IS NOT NULL
    AND c.itemid in (226730) -- height
    AND c.valuenum != 0
    GROUP BY c.stay_id
)
SELECT
    ie.stay_id
    , COALESCE(ce.Height_chart) AS height
    -- components
    , ce.height_chart
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN ce USING(stay_id)