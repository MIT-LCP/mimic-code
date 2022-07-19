-- This query calculates norepinephrine equivalent dose for vasopressors.
-- Based on "Vasopressor dose equivalence: A scoping review and suggested formula"
-- by Goradia et al. 2020.
SELECT stay_id, starttime, endtime
-- calculate the dose
, ROUND(COALESCE(norepinephrine, 0)
  + COALESCE(epinephrine, 0)
  + COALESCE(phenylephrine/10, 0)
  + COALESCE(dopamine/100, 0)
  -- + metaraminol/8 -- metaraminol not used in BIDMC
  + COALESCE(vasopressin*2.5, 0)
  -- angotensin_ii*10 -- angitensin ii rarely used, currently not incorporated
  -- (it could be included due to norepinephrine sparing effects)
  , 4) AS norepinephrine_equivalent_dose
  -- angotensin_ii*10 -- angitensin ii rarely used, currently not incorporated
  -- (it could be included due to norepinephrine sparing effects)
FROM `physionet-data.mimiciv_derived.vasoactive_agent`
WHERE norepinephrine IS NOT NULL
OR epinephrine IS NOT NULL
OR phenylephrine IS NOT NULL
OR dopamine IS NOT NULL
OR vasopressin IS NOT NULL;