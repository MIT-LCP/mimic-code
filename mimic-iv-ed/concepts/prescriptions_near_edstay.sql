-- Flag hospital prescriptions near an ED stay whose starttime precedes intime.
-- Join is intentionally loose (subject_id + hadm_id) — same caveat as #1910.

SELECT
  e.stay_id,
  e.intime,
  e.outtime,
  pr.starttime,
  pr.stoptime,
  pr.drug
FROM ed.edstays AS e
INNER JOIN hosp.prescriptions AS pr
  ON e.subject_id = pr.subject_id
 AND e.hadm_id IS NOT DISTINCT FROM pr.hadm_id
WHERE pr.starttime < e.intime
  AND pr.starttime >= e.intime - INTERVAL '6 hours'
ORDER BY e.stay_id, pr.starttime
LIMIT 100;
