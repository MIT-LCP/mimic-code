-- --------------------------------------------------------
-- Title: Retrieves bicarbonate levels for adult patients  
--        only for patients recorded with carevue  
-- MIMIC version: ?
-- --------------------------------------------------------

SELECT bucket, count(*) 
FROM (SELECT width_bucket(valuenum, 0, 231, 231) AS bucket 
      FROM mimiciii.labevents 
      WHERE itemid IN (50803, 50804, 50882)
      ) AS hco
GROUP BY bucket 
ORDER BY bucket; 

