-- Candidate Vitamin C administrations in emar (#1962).

SELECT medication, COUNT(*) AS n
FROM hosp.emar
WHERE LOWER(medication) LIKE '%ascorbic%'
   OR LOWER(medication) LIKE '%vitamin c%'
   OR LOWER(medication) LIKE '%vit c%'
GROUP BY medication
ORDER BY n DESC
LIMIT 50;
