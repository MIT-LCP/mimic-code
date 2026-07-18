-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.code_status; CREATE TABLE mimiciii_derived.code_status AS
/* This query extracts: */ /*    i) a patient's first code status */ /*    ii) a patient's last code status */ /*    iii) the time of the first entry of DNR or CMO */
WITH t1 AS (
  SELECT
    icustay_id,
    charttime,
    value, /* use row number to identify first and last code status */
    ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS rnfirst,
    ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY charttime DESC NULLS LAST) AS rnlast, /* coalesce the values */
    CASE WHEN value IN ('Full Code', 'Full code') THEN 1 ELSE 0 END AS fullcode,
    CASE WHEN value IN ('Comfort Measures', 'Comfort measures only') THEN 1 ELSE 0 END AS cmo,
    CASE WHEN value = 'CPR Not Indicate' THEN 1 ELSE 0 END AS dncpr, /* only in CareVue, i.e. only possible for ~60-70% of patients */
    CASE
      WHEN value IN ('Do Not Intubate', 'DNI (do not intubate)', 'DNR / DNI')
      THEN 1
      ELSE 0
    END AS dni,
    CASE
      WHEN value IN ('Do Not Resuscita', 'DNR (do not resuscitate)', 'DNR / DNI')
      THEN 1
      ELSE 0
    END AS dnr
  FROM mimiciii.chartevents
  WHERE
    itemid IN (128, 223758)
    AND NOT value IS NULL
    AND value <> 'Other/Remarks'
    AND /* exclude rows marked as error */ (
      error IS NULL OR error = 0
    )
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id, /* first recorded code status */
  MAX(CASE WHEN rnfirst = 1 THEN t1.fullcode ELSE NULL END) AS fullcode_first,
  MAX(CASE WHEN rnfirst = 1 THEN t1.cmo ELSE NULL END) AS cmo_first,
  MAX(CASE WHEN rnfirst = 1 THEN t1.dnr ELSE NULL END) AS dnr_first,
  MAX(CASE WHEN rnfirst = 1 THEN t1.dni ELSE NULL END) AS dni_first,
  MAX(CASE WHEN rnfirst = 1 THEN t1.dncpr ELSE NULL END) AS dncpr_first, /* last recorded code status */
  MAX(CASE WHEN rnlast = 1 THEN t1.fullcode ELSE NULL END) AS fullcode_last,
  MAX(CASE WHEN rnlast = 1 THEN t1.cmo ELSE NULL END) AS cmo_last,
  MAX(CASE WHEN rnlast = 1 THEN t1.dnr ELSE NULL END) AS dnr_last,
  MAX(CASE WHEN rnlast = 1 THEN t1.dni ELSE NULL END) AS dni_last,
  MAX(CASE WHEN rnlast = 1 THEN t1.dncpr ELSE NULL END) AS DNCPR_last, /* were they *at any time* given a certain code status */
  MAX(t1.fullcode) AS fullcode,
  MAX(t1.cmo) AS cmo,
  MAX(t1.dnr) AS dnr,
  MAX(t1.dni) AS dni,
  MAX(t1.dncpr) AS dncpr, /* time until their first DNR */
  MIN(CASE WHEN t1.dnr = 1 THEN t1.charttime ELSE NULL END) AS dnr_first_charttime,
  MIN(CASE WHEN t1.dni = 1 THEN t1.charttime ELSE NULL END) AS dni_first_charttime,
  MIN(CASE WHEN t1.dncpr = 1 THEN t1.charttime ELSE NULL END) AS dncpr_first_charttime, /* first code status of CMO */
  MIN(CASE WHEN t1.cmo = 1 THEN t1.charttime ELSE NULL END) AS timecmo_chart
FROM mimiciii.icustays AS ie
LEFT JOIN t1
  ON ie.icustay_id = t1.icustay_id
GROUP BY
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  ie.intime