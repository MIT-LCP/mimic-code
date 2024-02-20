-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.enzyme; CREATE TABLE mimiciv_derived.enzyme AS
SELECT
  MAX(subject_id) AS subject_id,
  MAX(hadm_id) AS hadm_id,
  MAX(charttime) AS charttime,
  le.specimen_id,
  MAX(CASE WHEN itemid = 50861 THEN valuenum ELSE NULL END) AS alt,
  MAX(CASE WHEN itemid = 50863 THEN valuenum ELSE NULL END) AS alp,
  MAX(CASE WHEN itemid = 50878 THEN valuenum ELSE NULL END) AS ast,
  MAX(CASE WHEN itemid = 50867 THEN valuenum ELSE NULL END) AS amylase,
  MAX(CASE WHEN itemid = 50885 THEN valuenum ELSE NULL END) AS bilirubin_total,
  MAX(CASE WHEN itemid = 50883 THEN valuenum ELSE NULL END) AS bilirubin_direct,
  MAX(CASE WHEN itemid = 50884 THEN valuenum ELSE NULL END) AS bilirubin_indirect,
  MAX(CASE WHEN itemid = 50910 THEN valuenum ELSE NULL END) AS ck_cpk,
  MAX(CASE WHEN itemid = 50911 THEN valuenum ELSE NULL END) AS ck_mb,
  MAX(CASE WHEN itemid = 50927 THEN valuenum ELSE NULL END) AS ggt,
  MAX(CASE WHEN itemid = 50954 THEN valuenum ELSE NULL END) AS ld_ldh
FROM mimiciv_hosp.labevents AS le
WHERE
  le.itemid IN (50861, 50863, 50878, 50867, 50885, 50884, 50883, 50910, 50911, 50927, 50954)
  AND NOT valuenum IS NULL
  AND valuenum > 0
GROUP BY
  le.specimen_id