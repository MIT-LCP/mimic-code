-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.coagulation; CREATE TABLE mimiciv_derived.coagulation AS
SELECT
  MAX(subject_id) AS subject_id,
  MAX(hadm_id) AS hadm_id,
  MAX(charttime) AS charttime,
  le.specimen_id,
  MAX(CASE WHEN itemid = 51196 THEN valuenum ELSE NULL END) AS d_dimer,
  MAX(CASE WHEN itemid = 51214 THEN valuenum ELSE NULL END) AS fibrinogen,
  MAX(CASE WHEN itemid = 51297 THEN valuenum ELSE NULL END) AS thrombin,
  MAX(CASE WHEN itemid = 51237 THEN valuenum ELSE NULL END) AS inr,
  MAX(CASE WHEN itemid = 51274 THEN valuenum ELSE NULL END) AS pt,
  MAX(CASE WHEN itemid = 51275 THEN valuenum ELSE NULL END) AS ptt
FROM mimiciv_hosp.labevents AS le
WHERE
  le.itemid IN (51196, 51214, 51297, 51237, 51274, 51275) AND NOT valuenum IS NULL
GROUP BY
  le.specimen_id