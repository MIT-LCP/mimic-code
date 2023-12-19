-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.coagulation; CREATE TABLE mimiciv_derived.coagulation AS
SELECT
  MAX(subject_id) AS subject_id,
  MAX(hadm_id) AS hadm_id,
  MAX(charttime) AS charttime,
  le.specimen_id, /* convert from itemid into a meaningful column */
  MAX(CASE WHEN itemid = 51196 THEN valuenum ELSE NULL END) AS d_dimer,
  MAX(CASE WHEN itemid = 51214 THEN valuenum ELSE NULL END) AS fibrinogen,
  MAX(CASE WHEN itemid = 51297 THEN valuenum ELSE NULL END) AS thrombin,
  MAX(CASE WHEN itemid = 51237 THEN valuenum ELSE NULL END) AS inr,
  MAX(CASE WHEN itemid = 51274 THEN valuenum ELSE NULL END) AS pt,
  MAX(CASE WHEN itemid = 51275 THEN valuenum ELSE NULL END) AS ptt
FROM mimiciv_hosp.labevents AS le
WHERE
  le.itemid IN (51196 /* Bleeding Time, no data as of MIMIC-IV v0.4 */ /* 51149, 52750, 52072, 52073 */ /* D-Dimer */, 51214 /* Fibrinogen */ /* Reptilase Time, no data as of MIMIC-IV v0.4 */ /* 51280, 52893, */ /* Reptilase Time Control, no data as of MIMIC-IV v0.4 */ /* 51281, 52161, */, 51297 /* thrombin */, 51237 /* INR */, 51274 /* PT */, 51275 /* PTT */)
  AND NOT valuenum IS NULL
GROUP BY
  le.specimen_id