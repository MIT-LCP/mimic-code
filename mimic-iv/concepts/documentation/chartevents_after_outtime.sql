-- Count chartevents whose charttime falls after the linked ICU stay outtime.
-- Useful as a sensitivity check when building in-ICU only cohorts (#1961).

SELECT
  COUNT(*) AS chartevents_rows,
  COUNT(*) FILTER (WHERE ce.charttime > ie.outtime) AS after_outtime,
  COUNT(*) FILTER (
    WHERE ce.charttime > ie.outtime
      AND ce.charttime <= ie.outtime + INTERVAL '6 hours'
  ) AS after_outtime_within_6h
FROM icu.chartevents AS ce
INNER JOIN icu.icustays AS ie
  ON ce.stay_id = ie.stay_id;
