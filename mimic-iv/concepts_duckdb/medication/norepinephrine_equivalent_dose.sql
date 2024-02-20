-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.norepinephrine_equivalent_dose; CREATE TABLE mimiciv_derived.norepinephrine_equivalent_dose AS
SELECT
  stay_id,
  starttime,
  endtime,
  ROUND(
    TRY_CAST(COALESCE(norepinephrine, 0) + COALESCE(epinephrine, 0) + COALESCE(phenylephrine / 10, 0) + COALESCE(dopamine / 100, 0) + COALESCE(vasopressin * 2.5 / 60, 0) AS DECIMAL),
    4
  ) AS norepinephrine_equivalent_dose
FROM mimiciv_derived.vasoactive_agent
WHERE
  NOT norepinephrine IS NULL
  OR NOT epinephrine IS NULL
  OR NOT phenylephrine IS NULL
  OR NOT dopamine IS NULL
  OR NOT vasopressin IS NULL