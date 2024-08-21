-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.inflammation; CREATE TABLE mimiciv_derived.inflammation AS
SELECT
  MAX(subject_id) AS subject_id,
  MAX(hadm_id) AS hadm_id,
  MAX(charttime) AS charttime,
  le.specimen_id, /* convert from itemid into a meaningful column */
  MAX(CASE WHEN itemid = 50889 THEN valuenum ELSE NULL END) AS crp
FROM mimiciv_hosp.labevents AS le
WHERE
  le.itemid IN (50889 /* 51652 -- high sensitivity CRP */ /* crp */)
  AND NOT valuenum IS NULL
  AND /* lab values cannot be 0 and cannot be negative */ valuenum > 0
GROUP BY
  le.specimen_id