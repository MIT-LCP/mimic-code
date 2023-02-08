-- ------------------------------------------------------------------
-- Title: Systemic inflammatory response syndrome (SIRS) criteria
-- This query extracts the Systemic inflammatory response syndrome
-- (SIRS) criteria. The criteria quantify the level of inflammatory
-- response of the body. The score is calculated on the first day
-- of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for SIRS:
--    American College of Chest Physicians/Society of Critical Care
--    Medicine Consensus Conference: definitions for sepsis and organ
--    failure and guidelines for the use of innovative therapies in
--    sepsis". Crit. Care Med. 20 (6): 864–74. 1992.
--    doi:10.1097/00003246-199206000-00025. PMID 1597042.

-- Variables used in SIRS:
--  Body temperature (min and max)
--  Heart rate (max)
--  Respiratory rate (max)
--  PaCO2 (min)
--  White blood cell count (min and max)
--  the presence of greater than 10% immature neutrophils (band forms)

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption
--  that the user will subselect appropriate stay_ids.

-- Aggregate the components for the score
WITH scorecomp AS (
    SELECT ie.stay_id
        , v.temperature_min
        , v.temperature_max
        , v.heart_rate_max
        , v.resp_rate_max
        , bg.pco2_min AS paco2_min
        , l.wbc_min
        , l.wbc_max
        , l.bands_max
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.first_day_bg_art` bg
        ON ie.stay_id = bg.stay_id
    LEFT JOIN `physionet-data.mimiciv_derived.first_day_vitalsign` v
        ON ie.stay_id = v.stay_id
    LEFT JOIN `physionet-data.mimiciv_derived.first_day_lab` l
        ON ie.stay_id = l.stay_id
)

, scorecalc AS (
    -- Calculate the final score
    -- note that if the underlying data is missing, the component is null
    -- eventually these are treated as 0 (normal), but knowing when
    -- data is missing is useful for debugging
    SELECT stay_id

        , CASE
            WHEN temperature_min < 36.0 THEN 1
            WHEN temperature_max > 38.0 THEN 1
            WHEN temperature_min IS NULL THEN null
            ELSE 0
        END AS temp_score


        , CASE
            WHEN heart_rate_max > 90.0 THEN 1
            WHEN heart_rate_max IS NULL THEN null
            ELSE 0
        END AS heart_rate_score

        , CASE
            WHEN resp_rate_max > 20.0 THEN 1
            WHEN paco2_min < 32.0 THEN 1
            WHEN COALESCE(resp_rate_max, paco2_min) IS NULL THEN null
            ELSE 0
        END AS resp_score

        , CASE
            WHEN wbc_min < 4.0 THEN 1
            WHEN wbc_max > 12.0 THEN 1
            WHEN bands_max > 10 THEN 1-- > 10% immature neurophils (band forms)
            WHEN COALESCE(wbc_min, bands_max) IS NULL THEN null
            ELSE 0
        END AS wbc_score

    FROM scorecomp
)

SELECT
    ie.subject_id, ie.hadm_id, ie.stay_id
    -- Combine all the scores to get SOFA
    -- Impute 0 if the score is missing
    , COALESCE(temp_score, 0)
    + COALESCE(heart_rate_score, 0)
    + COALESCE(resp_score, 0)
    + COALESCE(wbc_score, 0)
    AS sirs
    , temp_score, heart_rate_score, resp_score, wbc_score
FROM `physionet-data.mimiciv_icu.icustays` ie
LEFT JOIN scorecalc s
          ON ie.stay_id = s.stay_id
;
