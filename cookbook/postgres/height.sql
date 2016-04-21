-- --------------------------------------------------------
-- Title: Create a histogram of heights for all patients
--  note: some height ITEMIDs were not included, which may implicitly exclude
--  some neonates from this calculation
-- MIMIC version: MIMIC-III v1.3
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------

SELECT bucket, count(*)
FROM (
    SELECT valuenum, width_bucket(valuenum, 1, 200, 200) AS bucket
    FROM chartevents
    WHERE itemid in (920,226730)
    AND valuenum IS NOT NULL
    AND valuenum > 0
    AND valuenum < 500
    ) AS height
GROUP BY bucket
ORDER BY bucket;
