-- This query calculates norepinephrine equivalent dose for vasopressors.
-- Based on "Vasopressor dose equivalence: A scoping review and
-- suggested formula" by Goradia et al. 2020.
SELECT stay_id, starttime, endtime
    -- calculate the dose
    , ROUND(CAST(
        COALESCE(norepinephrine, 0)
        + COALESCE(epinephrine, 0)
        + COALESCE(phenylephrine / 10, 0)
        + COALESCE(dopamine / 100, 0)
        -- + metaraminol/8 -- metaraminol not used in BIDMC
        + COALESCE(vasopressin * 2.5/60, 0)
        -- angiotensin_ii*10 -- angiotensin ii rarely used, though
        -- it could be included due to norepinephrine sparing effects
        AS NUMERIC), 4) AS norepinephrine_equivalent_dose
FROM `physionet-data.mimiciv_derived.vasoactive_agent`
WHERE norepinephrine IS NOT NULL
    OR epinephrine IS NOT NULL
    OR phenylephrine IS NOT NULL
    OR dopamine IS NOT NULL
    OR vasopressin IS NOT NULL;
