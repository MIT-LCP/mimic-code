-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.arb; CREATE TABLE mimiciv_derived.arb AS
WITH arb_drug AS (
  SELECT DISTINCT
    drug,
    CASE
      WHEN UPPER(drug) LIKE '%AZILSARTAN%' OR UPPER(drug) LIKE '%EDARBI%'
      THEN 1
      WHEN UPPER(drug) LIKE '%CANDESARTAN%' OR UPPER(drug) LIKE '%ATACAND%'
      THEN 1
      WHEN UPPER(drug) LIKE '%IRBESARTAN%' OR UPPER(drug) LIKE '%AVAPRO%'
      THEN 1
      WHEN UPPER(drug) LIKE '%LOSARTAN%' OR UPPER(drug) LIKE '%COZAAR%'
      THEN 1
      WHEN UPPER(drug) LIKE '%OLMESARTAN%' OR UPPER(drug) LIKE '%BENICAR%'
      THEN 1
      WHEN UPPER(drug) LIKE '%TELMISARTAN%' OR UPPER(drug) LIKE '%MICARDIS%'
      THEN 1
      WHEN UPPER(drug) LIKE '%VALSARTAN%' OR UPPER(drug) LIKE '%DIOVAN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%SACUBITRIL%' OR UPPER(drug) LIKE '%ENTRESTO%'
      THEN 1
      ELSE 0
    END AS arb
  FROM mimiciv_hosp.prescriptions
)
SELECT
  pr.subject_id,
  pr.hadm_id,
  pr.drug AS arb,
  pr.starttime,
  pr.stoptime
FROM mimiciv_hosp.prescriptions AS pr
INNER JOIN arb_drug
  ON pr.drug = arb_drug.drug
WHERE
  arb_drug.arb = 1