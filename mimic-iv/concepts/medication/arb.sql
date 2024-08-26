WITH arb_drug AS (  
  SELECT DISTINCT
    drug
    , CASE
        WHEN UPPER(drug) LIKE '%AZILSARTAN%' THEN 1
        WHEN UPPER(drug) LIKE '%CANDESARTAN%' THEN 1
        WHEN UPPER(drug) LIKE '%IRBESARTAN%' THEN 1
        WHEN UPPER(drug) LIKE '%LOSARTAN%' THEN 1
        WHEN UPPER(drug) LIKE '%OLMESARTAN%' THEN 1
        WHEN UPPER(drug) LIKE '%TELMISARTAN%' THEN 1
        WHEN UPPER(drug) LIKE '%VALSARTAN%' THEN 1
        ELSE 0
      END AS arb
  FROM `physionet-data.mimiciv_hosp.prescriptions`
)

SELECT
  pr.subject_id
  , pr.hadm_id
  , pr.drug AS arb
  , pr.starttime
  , pr.stoptime
FROM
  `physionet-data.mimiciv_hosp.prescriptions` pr
  INNER JOIN arb_drug
  ON 
    pr.drug = arb_drug.drug
WHERE
  arb_drug.arb = 1
;
