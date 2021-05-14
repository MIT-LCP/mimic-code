-- begin query that extracts the data
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 51002 THEN value ELSE NULL END) AS troponin_i
  , MAX(CASE WHEN itemid = 51003 THEN value ELSE NULL END) AS troponin_t
  , MAX(CASE WHEN itemid = 50911 THEN valuenum ELSE NULL END) AS ck_mb
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    -- 51002, -- Troponin I (troponin-I is not measured in MIMIC-IV)
    -- 52598, -- Troponin I, point of care, rare/poor quality
    51003, -- Troponin T
    50911  -- Creatinine Kinase, MB isoenzyme
)
GROUP BY le.specimen_id
;
