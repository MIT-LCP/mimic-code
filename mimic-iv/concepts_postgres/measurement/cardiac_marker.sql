-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.cardiac_marker; CREATE TABLE mimiciv_derived.cardiac_marker AS
/* begin query that extracts the data */
SELECT
  MAX(subject_id) AS subject_id,
  MAX(hadm_id) AS hadm_id,
  MAX(charttime) AS charttime,
  le.specimen_id, /* convert from itemid into a meaningful column */
  MAX(CASE WHEN itemid = 51003 THEN valuenum ELSE NULL END) AS troponin_t,
  MAX(CASE WHEN itemid = 50911 THEN valuenum ELSE NULL END) AS ck_mb,
  MAX(CASE WHEN itemid = 50963 THEN valuenum ELSE NULL END) AS ntprobnp
FROM mimiciv_hosp.labevents AS le
WHERE
  le.itemid IN (51003 /* 51002, -- Troponin I (troponin-I is not measured in MIMIC-IV) */ /* 52598, -- Troponin I, point of care, rare/poor quality */ /* Troponin T */, 50911 /* Creatinine Kinase, MB isoenzyme */, 50963 /* N-terminal (NT)-pro hormone BNP (NT-proBNP) */)
  AND NOT valuenum IS NULL
GROUP BY
  le.specimen_id