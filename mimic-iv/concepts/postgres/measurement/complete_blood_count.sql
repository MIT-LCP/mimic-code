-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS complete_blood_count; CREATE TABLE complete_blood_count AS 
-- begin query that extracts the data
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 51221 THEN valuenum ELSE NULL END) AS hematocrit
  , MAX(CASE WHEN itemid = 51222 THEN valuenum ELSE NULL END) AS hemoglobin
  , MAX(CASE WHEN itemid = 51248 THEN valuenum ELSE NULL END) AS mch
  , MAX(CASE WHEN itemid = 51249 THEN valuenum ELSE NULL END) AS mchc
  , MAX(CASE WHEN itemid = 51250 THEN valuenum ELSE NULL END) AS mcv
  , MAX(CASE WHEN itemid = 51265 THEN valuenum ELSE NULL END) AS platelet
  , MAX(CASE WHEN itemid = 51279 THEN valuenum ELSE NULL END) AS rbc
  , MAX(CASE WHEN itemid = 51277 THEN valuenum ELSE NULL END) AS rdw
  , MAX(CASE WHEN itemid = 52159 THEN valuenum ELSE NULL END) AS rdwsd
  , MAX(CASE WHEN itemid = 51301 THEN valuenum ELSE NULL END) AS wbc
FROM mimiciv_hosp.labevents le
WHERE le.itemid IN
(
    51221, -- hematocrit
    51222, -- hemoglobin
    51248, -- MCH
    51249, -- MCHC
    51250, -- MCV
    51265, -- platelets
    51279, -- RBC
    51277, -- RDW
    52159, -- RDW SD
    51301  -- WBC

)
AND valuenum IS NOT NULL
-- lab values cannot be 0 and cannot be negative
AND valuenum > 0
GROUP BY le.specimen_id
;
