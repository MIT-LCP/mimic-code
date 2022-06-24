-- Extract all creatinine values from labevents around patient's ICU stay
WITH cr AS
(
    SELECT
        ie.hadm_id
        , ie.stay_id
        , le.charttime
        , AVG(le.valuenum) AS creat
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_hosp.labevents` le
    ON ie.subject_id = le.subject_id
    AND le.ITEMID = 50912
    AND le.VALUENUM IS NOT NULL
    AND le.VALUENUM <= 150
    AND le.CHARTTIME BETWEEN DATETIME_SUB(ie.intime, INTERVAL '7' DAY) AND ie.outtime
    GROUP BY ie.hadm_id, ie.stay_id, le.charttime
)
, cr48 AS
(
    -- add in the lowest value in the previous 48 hours
    SELECT 
        cr.stay_id
        , cr.charttime
        , MIN(cr48.creat) AS creat_low_past_48hr
    FROM cr
    -- add in all creatinine values in the last 48 hours
    LEFT JOIN cr cr48
        ON cr.stay_id = cr48.stay_id
        AND cr48.charttime <  cr.charttime
        AND cr48.charttime >= DATETIME_SUB(cr.charttime, INTERVAL '48' HOUR)
    GROUP BY cr.stay_id, cr.charttime
)
, cr7 AS
(
    -- add in the lowest value in the previous 7 days
    SELECT
        cr.stay_id
        , cr.charttime
        , MIN(cr7.creat) AS creat_low_past_7day
    FROM cr
    -- add in all creatinine values in the last 7 days
    LEFT JOIN cr cr7
      ON cr.stay_id = cr7.stay_id
      AND cr7.charttime <  cr.charttime
      AND cr7.charttime >= DATETIME_SUB(cr.charttime, INTERVAL '7' DAY)
    GROUP BY cr.stay_id, cr.charttime
)
SELECT 
    cr.hadm_id
    , cr.stay_id
    , cr.charttime
    , cr.creat
    , cr48.creat_low_past_48hr
    , cr7.creat_low_past_7day
FROM cr
LEFT JOIN cr48
    ON cr.stay_id = cr48.stay_id
    AND cr.charttime = cr48.charttime
LEFT JOIN cr7
    ON cr.stay_id = cr7.stay_id
    AND cr.charttime = cr7.charttime
;
