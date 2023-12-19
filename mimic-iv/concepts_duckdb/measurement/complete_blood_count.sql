-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.complete_blood_count; CREATE TABLE mimiciv_derived.complete_blood_count AS
SELECT
  MAX(subject_id) AS subject_id,
  MAX(hadm_id) AS hadm_id,
  MAX(charttime) AS charttime,
  le.specimen_id,
  MAX(CASE WHEN itemid = 51221 THEN valuenum ELSE NULL END) AS hematocrit,
  MAX(CASE WHEN itemid = 51222 THEN valuenum ELSE NULL END) AS hemoglobin,
  MAX(CASE WHEN itemid = 51248 THEN valuenum ELSE NULL END) AS mch,
  MAX(CASE WHEN itemid = 51249 THEN valuenum ELSE NULL END) AS mchc,
  MAX(CASE WHEN itemid = 51250 THEN valuenum ELSE NULL END) AS mcv,
  MAX(CASE WHEN itemid = 51265 THEN valuenum ELSE NULL END) AS platelet,
  MAX(CASE WHEN itemid = 51279 THEN valuenum ELSE NULL END) AS rbc,
  MAX(CASE WHEN itemid = 51277 THEN valuenum ELSE NULL END) AS rdw,
  MAX(CASE WHEN itemid = 52159 THEN valuenum ELSE NULL END) AS rdwsd,
  MAX(CASE WHEN itemid = 51301 THEN valuenum ELSE NULL END) AS wbc
FROM mimiciv_hosp.labevents AS le
WHERE
  le.itemid IN (51221, 51222, 51248, 51249, 51250, 51265, 51279, 51277, 52159, 51301)
  AND NOT valuenum IS NULL
  AND valuenum > 0
GROUP BY
  le.specimen_id