-- Count Pyxis rows whose charttime falls before the linked ED stay intime.
-- Useful as a sensitivity check when building ED medication cohorts (#1910).
-- Dialect: PostgreSQL / BigQuery-compatible with minor cast tweaks.

SELECT
  COUNT(*) AS pyxis_rows,
  COUNT(*) FILTER (WHERE p.charttime < e.intime) AS before_intime,
  COUNT(*) FILTER (
    WHERE p.charttime < e.intime
      AND p.charttime >= e.intime - INTERVAL '2 hours'
  ) AS before_intime_within_2h
FROM ed.pyxis AS p
INNER JOIN ed.edstays AS e
  ON p.stay_id = e.stay_id;
