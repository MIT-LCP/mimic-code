-- Candidate Vitamin C / ascorbic acid orders in hosp.prescriptions (#1962).
-- Review hits manually — multivitamins and abbreviations create false positives.

SELECT drug, COUNT(*) AS n
FROM hosp.prescriptions
WHERE LOWER(drug) LIKE '%ascorbic%'
   OR LOWER(drug) LIKE '%vitamin c%'
   OR LOWER(drug) LIKE '%vit c%'
GROUP BY drug
ORDER BY n DESC
LIMIT 50;
