-- Sample d_labitems labels for cohorts that need a manual LOINC review (#1972).
-- There is no LOINC column in MIMIC-IV dictionaries.

SELECT itemid, label, fluid, category
FROM hosp.d_labitems
WHERE LOWER(label) LIKE '%creatinine%'
ORDER BY itemid
LIMIT 50;
