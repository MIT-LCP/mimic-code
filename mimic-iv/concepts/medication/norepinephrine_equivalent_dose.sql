-- This query calculates norepinephrine equivalent dose for vasopressors.
-- Based on "Vasopressor dose equivalence: A scoping review and
-- suggested formula" by Goradia et al. 2020.

-- The relevant table makes the following equivalences:
-- Norepinephrine   - 1:1 - comparison dose of 0.1 ug/kg/min
-- Epinephrine      - 1:1 [0.7, 1.4] - 0.1 ug/kg/min
-- Dopamine         - 1:100 [75.2, 144.4] - 10 ug/kg/min
-- Metaraminol      - 1:8 [8.3] - 0.8 ug/kg/min
-- Phenylephrine    - 1:10 [1.1, 16.3] - 1 ug/kg/min
-- Vasopressin      - 1:0.4 [0.3, 0.4] - 0.04 units/min
-- Angiotensin II   - 1:0.1 [0.07, 0.13] - 0.01 ug/kg/min

SELECT stay_id, starttime, endtime
    -- calculate the dose
    -- all sources are in mcg/kg/min,
    -- except vasopressin which is in units/hour
    , ROUND(CAST(
        COALESCE(norepinephrine, 0)
        + COALESCE(epinephrine, 0)
        + COALESCE(phenylephrine / 10, 0)
        + COALESCE(dopamine / 100, 0)
        -- + metaraminol/8 -- metaraminol not used in BIDMC
        + COALESCE(vasopressin * 2.5 / 60, 0)
        -- angiotensin_ii*10 -- angiotensin ii rarely used, though
        -- it could be included due to norepinephrine sparing effects
        AS NUMERIC), 4) AS norepinephrine_equivalent_dose
FROM `physionet-data.mimiciv_derived.vasoactive_agent`
WHERE norepinephrine IS NOT NULL
    OR epinephrine IS NOT NULL
    OR phenylephrine IS NOT NULL
    OR dopamine IS NOT NULL
    OR vasopressin IS NOT NULL;
