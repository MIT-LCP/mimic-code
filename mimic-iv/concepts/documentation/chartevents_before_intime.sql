-- Count chartevents charted before ICU intime (less common than after outtime).

SELECT
  COUNT(*) AS before_intime,
  COUNT(*) FILTER (
    WHERE ce.charttime < ie.intime
      AND ce.charttime >= ie.intime - INTERVAL '2 hours'
  ) AS before_intime_within_2h
FROM icu.chartevents AS ce
INNER JOIN icu.icustays AS ie
  ON ce.stay_id = ie.stay_id
WHERE ce.charttime < ie.intime;
