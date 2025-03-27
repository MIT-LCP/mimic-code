-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS icustay_hourly; CREATE TABLE icustay_hourly AS
-- This query generates a row for every hour the patient is in the ICU.
-- The hours are based on clock-hours (i.e. 02:00, 03:00).
-- The hour clock starts 24 hours before the first heart rate measurement.
-- Note that the time of the first heart rate measurement is ceilinged to
-- the hour.

-- this query extracts the cohort and every possible hour they were in the ICU
-- this table can be to other tables on stay_id and (ENDTIME - 1 hour,ENDTIME]

-- get first/last measurement time
WITH all_hours AS (
    SELECT
        it.stay_id

        -- round the intime up to the nearest hour
        , CASE
            WHEN DATE_TRUNC('HOUR', it.intime_hr) = it.intime_hr
                THEN it.intime_hr
            ELSE
                DATETIME_ADD(
                    DATE_TRUNC('HOUR', it.intime_hr), INTERVAL '1' HOUR
                )
        END AS endtime
        , hrs 
        -- -- create integers for each charttime in hours from admission
        -- -- so 0 is admission time, 1 is one hour after admission, etc,
        -- -- up to ICU disch
        -- --  we allow 24 hours before ICU admission (to grab labs before admit)
        -- , GENERATE_ARRAY(-24, CAST(CEIL(DATETIME_DIFF(it.outtime_hr, it.intime_hr, 'HOUR')) AS INTEGER)) AS hrs -- noqa: L016
    FROM mimiciv_derived.icustay_times it
    CROSS JOIN GENERATE_ARRAY ( - 24, CAST ( CEIL ( DATETIME_DIFF ( it.outtime_hr, it.intime_hr, 'HOUR' ) ) AS INTEGER ) ) AS hrs 
)
SELECT stay_id
    , CAST ( hrs AS INTEGER ) AS hr
    , DATETIME_ADD(endtime, concat( CAST ( hrs AS INTEGER ) ,' HOUR')::interval) AS endtime
FROM all_hours
