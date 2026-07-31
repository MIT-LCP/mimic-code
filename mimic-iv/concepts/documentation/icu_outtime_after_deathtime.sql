-- ICU stays whose outtime is after the admission deathtime.

SELECT
  COUNT(*) AS icustays_out_after_death,
  COUNT(*) FILTER (
    WHERE ie.outtime > a.deathtime
      AND ie.outtime <= a.deathtime + INTERVAL '48 hours'
  ) AS within_48h
FROM icu.icustays AS ie
INNER JOIN hosp.admissions AS a
  ON ie.hadm_id = a.hadm_id
WHERE a.deathtime IS NOT NULL
  AND ie.outtime > a.deathtime;
