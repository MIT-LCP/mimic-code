WITH uo_stg1 AS (
    SELECT ie.stay_id, uo.charttime
        , CAST(
            DATETIME_DIFF(charttime, intime, SECOND) AS INTEGER
        ) AS seconds_since_admit
        , COALESCE(
            DATETIME_DIFF(charttime, LAG(charttime) OVER (PARTITION BY ie.stay_id ORDER BY charttime), SECOND) / 3600.0 -- noqa: L016
            , 1
        ) AS hours_since_previous_row
        , urineoutput
    FROM `physionet-data.mimiciv_icu.icustays` ie
    INNER JOIN `physionet-data.mimiciv_derived.urine_output` uo
        ON ie.stay_id = uo.stay_id
)

, uo_stg2 AS (
    SELECT stay_id, charttime
        , hours_since_previous_row
        , urineoutput
        -- Use the RANGE partition to limit the summation to the last X hours.
        -- RANGE operates using numeric, so we convert the charttime into
        -- seconds since admission, and then filter to X seconds prior to the
        -- current row, where X can be 21600 (6 hours), 43200 (12 hours),
        -- or 86400 (24 hours).
        , SUM(urineoutput) OVER
        (
            PARTITION BY stay_id
            ORDER BY seconds_since_admit
            RANGE BETWEEN 21600 PRECEDING AND CURRENT ROW
        ) AS urineoutput_6hr

        , SUM(urineoutput) OVER
        (
            PARTITION BY stay_id
            ORDER BY seconds_since_admit
            RANGE BETWEEN 43200 PRECEDING AND CURRENT ROW
        ) AS urineoutput_12hr

        , SUM(urineoutput) OVER
        (
            PARTITION BY stay_id
            ORDER BY seconds_since_admit
            RANGE BETWEEN 86400 PRECEDING AND CURRENT ROW
        ) AS urineoutput_24hr

        -- repeat the summations using the hours_since_previous_row column
        -- this gives us the amount of time the UO was calculated over
        , SUM(hours_since_previous_row) OVER
        (
            PARTITION BY stay_id
            ORDER BY seconds_since_admit
            RANGE BETWEEN 21600 PRECEDING AND CURRENT ROW
        ) AS uo_tm_6hr

        , SUM(hours_since_previous_row) OVER
        (
            PARTITION BY stay_id
            ORDER BY seconds_since_admit
            RANGE BETWEEN 43200 PRECEDING AND CURRENT ROW
        ) AS uo_tm_12hr

        , SUM(hours_since_previous_row) OVER
        (
            PARTITION BY stay_id
            ORDER BY seconds_since_admit
            RANGE BETWEEN 86400 PRECEDING AND CURRENT ROW
        ) AS uo_tm_24hr
    FROM uo_stg1
)

SELECT
    ur.stay_id
    , ur.charttime
    , wd.weight
    , ur.urineoutput_6hr
    , ur.urineoutput_12hr
    , ur.urineoutput_24hr

    -- calculate rates while requiring UO documentation over at least N hours
    -- as specified in KDIGO guidelines 2012 pg19
    , CASE
        WHEN uo_tm_6hr >= 6 AND uo_tm_6hr < 12
            THEN ROUND(
                CAST((ur.urineoutput_6hr / wd.weight / uo_tm_6hr) AS NUMERIC), 4
            )
        ELSE NULL END AS uo_rt_6hr
    , CASE
        WHEN uo_tm_12hr >= 12
            THEN ROUND(
                CAST((ur.urineoutput_12hr / wd.weight / uo_tm_12hr) AS NUMERIC)
                , 4
            )
        ELSE NULL END AS uo_rt_12hr
    , CASE
        WHEN uo_tm_24hr >= 24
            THEN ROUND(
                CAST((ur.urineoutput_24hr / wd.weight / uo_tm_24hr) AS NUMERIC)
                , 4
            )
        ELSE NULL END AS uo_rt_24hr

    -- number of hours between current UO time and earliest charted UO
    -- within the X hour window
    , uo_tm_6hr
    , uo_tm_12hr
    , uo_tm_24hr
FROM uo_stg2 ur
LEFT JOIN `physionet-data.mimiciv_derived.weight_durations` wd
    ON ur.stay_id = wd.stay_id
        AND ur.charttime >= wd.starttime
        AND ur.charttime < wd.endtime
;
