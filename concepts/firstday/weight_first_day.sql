  -- This query extracts weights for adult ICU patients on their first ICU day.
  -- It does *not* use any information after the first ICU day, as weight is
  -- sometimes used to monitor fluid balance.
  -- The MIMIC-III version used echodata but this isn't available in MIMIC-IV
WITH admission_weights AS (
    SELECT
        c.stay_id
        -- we take the avg value from roughly first day
        -- TODO: eliminate obvious outliers if there is a reasonable weight
        -- (e.g. weight of 180kg and 90kg would remove 180kg instead of taking the mean)
        , AVG(VALUENUM) AS Weight_Admit
    FROM `physionet-data.mimic_icu.chartevents` c
    INNER JOIN `physionet-data.mimic_icu.icustays` ie ON
        c.stay_id = ie.stay_id
        AND c.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
        AND c.charttime > DATETIME_SUB(ie.intime, INTERVAL '1' DAY) -- some fuzziness for admit time
    WHERE
        c.valuenum IS NOT NULL
        AND c.itemid IN (226512) -- Admit Wt
        AND c.valuenum != 0
    GROUP BY c.stay_id 
) , dwt AS (
    SELECT
        c.stay_id
        , AVG(VALUENUM) AS Weight_Daily
    FROM `physionet-data.mimic_icu.chartevents` c
    INNER JOIN `physionet-data.mimic_icu.icustays` ie ON
        c.stay_id = ie.stay_id
        AND c.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
        AND c.charttime > DATETIME_SUB(ie.intime, INTERVAL '1' DAY) -- some fuzziness for admit time
    WHERE
        c.valuenum IS NOT NULL
        AND c.itemid IN (224639) -- Daily Weight
        AND c.valuenum != 0
    GROUP BY c.stay_id 
)
SELECT
  ie.stay_id
  , CASE
        WHEN ce.stay_id IS NOT NULL THEN ce.Weight_Admit
        WHEN dwt.stay_id IS NOT NULL THEN dwt.Weight_Daily
    END AS weight
  -- components
  , ce.weight_admit
  , dwt.weight_daily
FROM `physionet-data.mimic_icu.icustays` ie
  -- admission weight
LEFT JOIN admission_weights ON
  ie.stay_id = ce.stay_id
  -- daily weights
LEFT JOIN dwt ON
  ie.stay_id = dwt.stay_id
ORDER BY
  ie.stay_id;