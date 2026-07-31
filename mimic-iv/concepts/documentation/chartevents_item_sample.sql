-- Sample ICU d_items labels (vitals/scores) for manual terminology review (#1972).

SELECT itemid, label, abbreviation, linksto, category
FROM icu.d_items
WHERE LOWER(label) LIKE '%spo2%'
   OR LOWER(label) LIKE '%o2 saturation%'
ORDER BY itemid
LIMIT 50;
