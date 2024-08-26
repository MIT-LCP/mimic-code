-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.chemistry; CREATE TABLE mimiciv_derived.chemistry AS
SELECT
  MAX(subject_id) AS subject_id,
  MAX(hadm_id) AS hadm_id,
  MAX(charttime) AS charttime,
  le.specimen_id,
  MAX(CASE WHEN itemid = 50862 AND valuenum <= 10 THEN valuenum ELSE NULL END) AS albumin,
  MAX(CASE WHEN itemid = 50930 AND valuenum <= 10 THEN valuenum ELSE NULL END) AS globulin,
  MAX(CASE WHEN itemid = 50976 AND valuenum <= 20 THEN valuenum ELSE NULL END) AS total_protein,
  MAX(CASE WHEN itemid = 50868 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS aniongap,
  MAX(CASE WHEN itemid = 50882 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS bicarbonate,
  MAX(CASE WHEN itemid = 51006 AND valuenum <= 300 THEN valuenum ELSE NULL END) AS bun,
  MAX(CASE WHEN itemid = 50893 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS calcium,
  MAX(CASE WHEN itemid = 50902 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS chloride,
  MAX(CASE WHEN itemid = 50912 AND valuenum <= 150 THEN valuenum ELSE NULL END) AS creatinine,
  MAX(CASE WHEN itemid = 50931 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS glucose,
  MAX(CASE WHEN itemid = 50983 AND valuenum <= 200 THEN valuenum ELSE NULL END) AS sodium,
  MAX(CASE WHEN itemid = 50971 AND valuenum <= 30 THEN valuenum ELSE NULL END) AS potassium
FROM mimiciv_hosp.labevents AS le
WHERE
  le.itemid IN (50862, 50930, 50976, 50868, 50882, 50893, 50912, 50902, 50931, 50971, 50983, 51006)
  AND NOT valuenum IS NULL
  AND (
    valuenum > 0 OR itemid = 50868
  )
GROUP BY
  le.specimen_id