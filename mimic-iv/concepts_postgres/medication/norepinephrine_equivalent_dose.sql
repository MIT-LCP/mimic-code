-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.norepinephrine_equivalent_dose; CREATE TABLE mimiciv_derived.norepinephrine_equivalent_dose AS
/* This query calculates norepinephrine equivalent dose for vasopressors. */ /* Based on "Vasopressor dose equivalence: A scoping review and */ /* suggested formula" by Goradia et al. 2020. */ /* The relevant table makes the following equivalences: */ /* Norepinephrine   - 1:1 - comparison dose of 0.1 ug/kg/min */ /* Epinephrine      - 1:1 [0.7, 1.4] - 0.1 ug/kg/min */ /* Dopamine         - 1:100 [75.2, 144.4] - 10 ug/kg/min */ /* Metaraminol      - 1:8 [8.3] - 0.8 ug/kg/min */ /* Phenylephrine    - 1:10 [1.1, 16.3] - 1 ug/kg/min */ /* Vasopressin      - 1:0.4 [0.3, 0.4] - 0.04 units/min */ /* Angiotensin II   - 1:0.1 [0.07, 0.13] - 0.01 ug/kg/min */
SELECT
  stay_id,
  starttime,
  endtime, /* calculate the dose */ /* all sources are in mcg/kg/min, */ /* except vasopressin which is in units/hour */
  ROUND(
    CAST(COALESCE(norepinephrine, 0) + COALESCE(epinephrine, 0) + COALESCE(CAST(phenylephrine AS DOUBLE PRECISION) / 10, 0) + COALESCE(CAST(dopamine AS DOUBLE PRECISION) / 100, 0) + /* + metaraminol/8 -- metaraminol not used in BIDMC */ COALESCE(CAST(vasopressin * 2.5 AS DOUBLE PRECISION) / 60, 0) AS DECIMAL),
    4
  ) AS norepinephrine_equivalent_dose
FROM mimiciv_derived.vasoactive_agent
WHERE
  NOT norepinephrine IS NULL
  OR NOT epinephrine IS NULL
  OR NOT phenylephrine IS NULL
  OR NOT dopamine IS NULL
  OR NOT vasopressin IS NULL