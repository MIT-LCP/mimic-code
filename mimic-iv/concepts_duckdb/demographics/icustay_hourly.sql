-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.icustay_hourly; CREATE TABLE mimiciv_derived.icustay_hourly AS
WITH all_hours AS (
  SELECT
    it.stay_id,
    CASE
      WHEN DATE_TRUNC('HOUR', it.intime_hr) = it.intime_hr
      THEN it.intime_hr
      ELSE DATE_TRUNC('HOUR', it.intime_hr) + INTERVAL '1' HOUR
    END AS endtime,
    GENERATE_SERIES(
      -24,
      TRY_CAST(CEIL(DATE_DIFF('microseconds', it.intime_hr, it.outtime_hr)/3600000000.0) AS INT)
    ) AS hrs
  FROM mimiciv_derived.icustay_times AS it
)
SELECT
  stay_id,
  TRY_CAST(hr_unnested AS BIGINT) AS hr,
  endtime + TRY_CAST(hr_unnested AS BIGINT) * INTERVAL '1' HOUR AS endtime
FROM all_hours
CROSS JOIN UNNEST(all_hours.hrs) AS _t0(hr_unnested)