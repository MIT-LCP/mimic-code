DROP TABLE IF EXISTS mimiciv_derived.daily_fluid_out;
CREATE TABLE mimiciv_derived.daily_fluid_out AS
SELECT
    stay_id,
    DATE(charttime) as day,
    SUM(value) as total_output
FROM
    mimiciv_icu.outputevents
GROUP BY 
    stay_id, 
    day
ORDER BY 
    stay_id, 
    day;