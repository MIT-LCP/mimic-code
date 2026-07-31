-- Count hospital transfers whose intime falls after admissions.deathtime.
-- Illustrates the #1945 ADT-lag pattern (not a stay_id join failure).

SELECT
  COUNT(*) AS transfer_rows_after_deathtime,
  COUNT(DISTINCT t.hadm_id) AS admissions_affected
FROM hosp.transfers AS t
INNER JOIN hosp.admissions AS a
  ON t.hadm_id = a.hadm_id
WHERE a.deathtime IS NOT NULL
  AND t.intime > a.deathtime;
