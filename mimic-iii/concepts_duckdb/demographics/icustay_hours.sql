-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.icustay_hours; CREATE TABLE mimiciii_derived.icustay_hours AS
WITH all_hours AS (
  SELECT
    it.icustay_id,
    STRPTIME(STRFTIME(CAST(it.intime_hr + INTERVAL '59' MINUTE AS TIMESTAMP), '%Y-%m-%d %H:00:00'), '%Y-%m-%d %H:00:00') AS endtime,
    GENERATE_SERIES(-24, CAST(CEIL(DATE_DIFF('HOUR', it.intime_hr, it.outtime_hr)) AS BIGINT)) AS hrs
  FROM mimiciii_derived.icustay_times AS it
)
SELECT
  icustay_id,
  CAST(hr AS BIGINT) AS hr,
  endtime + INTERVAL (CAST(hr AS BIGINT)) HOUR AS endtime
FROM all_hours
CROSS JOIN UNNEST(all_hours.hrs) AS _t0(hr)