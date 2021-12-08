-- This query calculates norepinephrine equivalent dose for vasopressors.
-- Based on "Vasopressor dose equivalence: A scoping review and suggested formula"
-- by Goradia et al. 2020.
SELECT t.stay_id, t.starttime, t.endtime
-- calculate the dose
, norepinephrine
  + epinephrine
  + phenylephrine/10
  + dopamine/100
  -- + metaraminol/8 -- metaraminol not used in BIDMC
  + vasopressin*2.5
  -- angotensin_ii*10 -- angitensin ii rarely used, currently not incorporated
  -- (it could be included due to norepinephrine sparing effects)
  AS norepinephrine_equivalent_dose
FROM mimic_derived.vasoactive_agent
WHERE norepinephrine IS NOT NULL
OR epinephrine IS NOT NULL
OR phenylephrine IS NOT NULL
OR dopamine IS NOT NULL
OR vasopressin IS NOT NULL;