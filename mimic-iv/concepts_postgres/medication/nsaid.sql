-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.nsaid; CREATE TABLE mimiciv_derived.nsaid AS
WITH nsaid_drug AS (
  SELECT DISTINCT
    drug,
    CASE
      WHEN UPPER(drug) LIKE '%ASPIRIN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%BROMFENAC%'
      THEN 1
      WHEN UPPER(drug) LIKE '%CELECOXIB%'
      THEN 1
      WHEN UPPER(drug) LIKE '%DICLOFENAC%'
      THEN 1
      WHEN UPPER(drug) LIKE '%DIFLUNISAL%'
      THEN 1
      WHEN UPPER(drug) LIKE '%ETODOLAC%'
      THEN 1
      WHEN UPPER(drug) LIKE '%FENOPROFEN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%FLURBIPROFEN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%IBUPROFEN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%INDOMETHACIN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%KETOPROFEN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%MEFENAMIC ACID%'
      THEN 1
      WHEN UPPER(drug) LIKE '%MELOXICAM%'
      THEN 1
      WHEN UPPER(drug) LIKE '%NABUMETONE%'
      THEN 1
      WHEN UPPER(drug) LIKE '%NAPROXEN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%NEPAFENAC%'
      THEN 1
      WHEN UPPER(drug) LIKE '%OXAPROZIN%'
      THEN 1
      WHEN UPPER(drug) LIKE '%PIROXICAM%'
      THEN 1
      WHEN UPPER(drug) LIKE '%SULINDAC%'
      THEN 1
      WHEN UPPER(drug) LIKE '%TOLMETIN%'
      THEN 1
      ELSE 0
    END AS nsaid
  FROM mimiciv_hosp.prescriptions
)
SELECT
  pr.subject_id,
  pr.hadm_id,
  pr.drug AS nsaid,
  pr.starttime,
  pr.stoptime
FROM mimiciv_hosp.prescriptions AS pr
INNER JOIN nsaid_drug
  ON pr.drug = nsaid_drug.drug
WHERE
  nsaid_drug.nsaid = 1