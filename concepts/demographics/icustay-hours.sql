-- This query generates a row for every hour the patient is in the ICU.
-- The hours are based on clock-hours (i.e. 02:00, 03:00).
-- The hour clock starts 24 hours before the first heart rate measurement.
-- Note that the time of the first heart rate measurement is ceilinged to the hour.

-- this query extracts the cohort and every possible hour they were in the ICU
-- this table can be to other tables on ICUSTAY_ID and (ENDTIME - 1 hour,ENDTIME]
CREATE TABLE `physionet-data.mimiciii_derived.icustay_hours` as
-- get first/last measurement time
with all_hours as
(
select
  it.icustay_id

  -- ceiling the intime to the nearest hour by adding 59 minutes then truncating
  , DATETIME_TRUNC(DATETIME_ADD(it.intime_hr, INTERVAL 59 MINUTE), HOUR) as endtime

  -- create integers for each charttime in hours from admission
  -- so 0 is admission time, 1 is one hour after admission, etc, up to ICU disch
  --  we allow 24 hours before ICU admission (to grab labs before admit)
  , GENERATE_ARRAY(-24, CEIL(DATETIME_DIFF(it.outtime_hr, it.intime_hr, HOUR))) as hrs

  from `physionet-data.mimiciii_clinical.icustay_times` it
)
SELECT icustay_id
, CAST(hr AS INT64) as hr
, DATETIME_ADD(endtime, INTERVAL CAST(hr AS INT64) HOUR) as endtime
FROM all_hours
CROSS JOIN UNNEST(all_hours.hrs) AS hr;
