-- begin query that extracts the data
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 50861 THEN valuenum ELSE NULL END) AS alt
  , MAX(CASE WHEN itemid = 50863 THEN valuenum ELSE NULL END) AS alp
  , MAX(CASE WHEN itemid = 50878 THEN valuenum ELSE NULL END) AS ast
  , MAX(CASE WHEN itemid = 50867 THEN valuenum ELSE NULL END) AS amylase
  , MAX(CASE WHEN itemid = 50885 THEN valuenum ELSE NULL END) AS bilirubin_total
  , MAX(CASE WHEN itemid = 50883 THEN valuenum ELSE NULL END) AS bilirubin_direct
  , MAX(CASE WHEN itemid = 50884 THEN valuenum ELSE NULL END) AS bilirubin_indirect
  , MAX(CASE WHEN itemid = 50910 THEN valuenum ELSE NULL END) AS ck_cpk
  , MAX(CASE WHEN itemid = 50911 THEN valuenum ELSE NULL END) AS ck_mb
  , MAX(CASE WHEN itemid = 50927 THEN valuenum ELSE NULL END) AS ggt
  , MAX(CASE WHEN itemid = 50954 THEN valuenum ELSE NULL END) AS ld_ldh
FROM `physionet-data.mimiciv_hosp.labevents` le
WHERE le.itemid IN
(
    50861, -- Alanine transaminase (ALT)
    50863, -- Alkaline phosphatase (ALP)
    50878, -- Aspartate transaminase (AST)
    50867, -- Amylase
    50885, -- total bili
    50884, -- indirect bili
    50883, -- direct bili
    50910, -- ck_cpk
    50911, -- CK-MB
    50927, -- Gamma Glutamyltransferase (GGT)
    50954 -- ld_ldh
)
AND valuenum IS NOT NULL
-- lab values cannot be 0 and cannot be negative
AND valuenum > 0
GROUP BY le.specimen_id
;
