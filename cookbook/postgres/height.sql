-- --------------------------------------------------------
-- Title: Retrieves a height histogram of patients  
-- MIMIC version: ?
-- --------------------------------------------------------

SELECT bucket, count(*) 
FROM (
    SELECT valuenum, width_bucket(valuenum, 1, 200, 200) AS bucket 
    FROM mimiciii.chartevents 
    WHERE itemid = 920 
    AND valuenum IS NOT NULL 
    AND valuenum > 0 
    AND valuenum < 500
    ) AS height 
GROUP BY bucket 
ORDER BY bucket;
