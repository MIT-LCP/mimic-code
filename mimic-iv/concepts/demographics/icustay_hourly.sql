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
            WHEN DATETIME_TRUNC(it.intime_hr, HOUR) = it.intime_hr
                THEN it.intime_hr
            ELSE
                DATETIME_ADD(
                    DATETIME_TRUNC(it.intime_hr, HOUR), INTERVAL 1 HOUR
                )
        END AS endtime

        -- create integers for each charttime in hours from admission
        -- so 0 is admission time, 1 is one hour after admission, etc,
        -- up to ICU disch
        --  we allow 24 hours before ICU admission (to grab labs before admit)
        , GENERATE_ARRAY(-24, CAST(CEIL(DATETIME_DIFF(it.outtime_hr, it.intime_hr, HOUR)) AS INTEGER)) AS hrs -- noqa: L016
    FROM `physionet-data.mimiciv_derived.icustay_times` it
)

SELECT stay_id
    , CAST(hr_unnested AS INT64) AS hr
    , DATETIME_ADD(endtime, INTERVAL CAST(hr_unnested AS INT64) HOUR) AS endtime
FROM all_hours
CROSS JOIN UNNEST(all_hours.hrs) AS hr_unnested;
