-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.icustay_hourly; CREATE TABLE mimiciv_derived.icustay_hourly AS
WITH all_hours AS (
  SELECT
    it.stay_id,
    CASE
      WHEN DATE_TRUNC('HOUR', CAST(it.intime_hr AS TIMESTAMP)) = it.intime_hr
      THEN it.intime_hr
      ELSE DATE_TRUNC('HOUR', CAST(it.intime_hr AS TIMESTAMP)) + INTERVAL '1' HOUR
    END AS endtime,
    GENERATE_SERIES(-24, CAST(CEIL(DATE_DIFF('HOUR', it.intime_hr, it.outtime_hr)) AS INT)) AS hrs
  FROM mimiciv_derived.icustay_times AS it
)
SELECT
  stay_id,
  CAST(hr_unnested AS BIGINT) AS hr,
  endtime + INTERVAL (CAST(hr_unnested AS BIGINT)) HOUR AS endtime
FROM all_hours
CROSS JOIN UNNEST(all_hours.hrs) AS _t0(hr_unnested)