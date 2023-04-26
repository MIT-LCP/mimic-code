WITH all_hours AS (
  SELECT
    it.icustay_id, /* ceiling the intime to the nearest hour by adding 59 minutes then truncating */
    DATE_TRUNC('hour', it.intime_hr + INTERVAL '59' minute) AS endtime, /* create integers for each charttime in hours from admission */
    /* so 0 is admission time, 1 is one hour after admission, etc, up to ICU disch */
    GENERATE_SERIES(
      -24,
      CAST(CEIL(EXTRACT(EPOCH FROM it.outtime_hr - it.intime_hr) / 60.0 / 60.0) AS INT)
    ) AS hr
  FROM icustay_times AS it
)
SELECT
  ah.icustay_id,
  unnest(ah.hr) as hr, 
  /* endtime now indexes the end time of every hour for each patient */
  unnest(list_transform(hr, ahr -> ah.endtime + ahr*INTERVAL 1 hour)) AS endtime
  --ah.endtime+ hr*INTERVAL 1 hour as endtime
FROM all_hours AS ah
ORDER BY
  ah.icustay_id NULLS LAST
limit 20