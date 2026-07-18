-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.icustay_hours; CREATE TABLE mimiciii_derived.icustay_hours AS
/* This query generates a row for every hour the patient is in the ICU. */ /* The hours are based on clock-hours (i.e. 02:00, 03:00). */ /* The hour clock starts 24 hours before the first heart rate measurement. */ /* Note that the time of the first heart rate measurement is ceilinged to the hour. */ /* this query extracts the cohort and every possible hour they were in the ICU */ /* this table can be to other tables on ICUSTAY_ID and (ENDTIME - 1 hour,ENDTIME] */ /* get first/last measurement time */
WITH all_hours AS (
  SELECT
    it.icustay_id, /* ceiling the intime to the nearest hour by adding 59 minutes then truncating */ /* note thart we truncate by parsing as string, rather than using DATETIME_TRUNC */ /* this is done to enable compatibility with psql */
    CAST(TO_TIMESTAMP(TO_CHAR(CAST(it.intime_hr + INTERVAL '59' MINUTE AS TIMESTAMP), 'YYYY-MM-DD HH24:00:00'), 'YYYY-MM-DD HH24:00:00') AS TIMESTAMP) AS endtime, /* create integers for each charttime in hours from admission */ /* so 0 is admission time, 1 is one hour after admission, etc, up to ICU disch */ /*  we allow 24 hours before ICU admission (to grab labs before admit) */
    ARRAY(SELECT * FROM GENERATE_SERIES(-24, CAST(CEIL(
      CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', it.outtime_hr) - DATE_TRUNC('hour', it.intime_hr)) / 3600 AS BIGINT)
    ) AS BIGINT))) AS hrs
  FROM mimiciii_derived.icustay_times AS it
)
SELECT
  icustay_id,
  CAST(hr AS BIGINT) AS hr,
  endtime + CAST(hr AS BIGINT) * INTERVAL '1' HOUR AS endtime
FROM all_hours
CROSS JOIN UNNEST(all_hours.hrs) AS _t0(hr)