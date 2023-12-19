-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.code_status; CREATE TABLE mimiciv_derived.code_status AS
WITH t1 AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    charttime,
    CASE WHEN value IN ('Full code') THEN 1 ELSE 0 END AS fullcode,
    CASE WHEN value IN ('Comfort measures only') THEN 1 ELSE 0 END AS cmo,
    CASE WHEN value IN ('DNI (do not intubate)', 'DNR / DNI') THEN 1 ELSE 0 END AS dni,
    CASE WHEN value IN ('DNR (do not resuscitate)', 'DNR / DNI') THEN 1 ELSE 0 END AS dnr
  FROM mimiciv_icu.chartevents
  WHERE
    itemid IN (223758)
), poe AS (
  SELECT
    p.subject_id,
    p.hadm_id,
    ie.stay_id,
    p.ordertime,
    CASE
      WHEN pd.field_value = 'Resuscitate (Full code)'
      THEN 1
      WHEN pd.field_value = 'Full code  (attempt resuscitation)'
      THEN 1
      ELSE 0
    END AS fullcode,
    CASE
      WHEN pd.field_value = 'DNAR (DO NOT attempt resuscitation for cardiac arrest) '
      THEN 1
      WHEN pd.field_value = 'Do not resuscitate (DNR/DNI)'
      THEN 1
      ELSE 0
    END AS dnr,
    CASE WHEN pd.field_value = 'Do not resuscitate (DNR/DNI)' THEN 1 ELSE 0 END AS dni
  FROM mimiciv_hosp.poe AS p
  INNER JOIN mimiciv_hosp.poe_detail AS pd
    ON p.poe_id = pd.poe_id
  LEFT JOIN mimiciv_icu.icustays AS ie
    ON p.hadm_id = ie.hadm_id AND p.ordertime >= ie.intime AND p.ordertime <= ie.outtime
  WHERE
    p.order_type = 'General Care' AND order_subtype = 'Code status'
)
SELECT
  t1.subject_id,
  t1.hadm_id,
  t1.stay_id,
  t1.charttime,
  t1.fullcode,
  t1.cmo,
  t1.dni,
  t1.dnr
FROM t1
UNION ALL
SELECT
  poe.subject_id,
  poe.hadm_id,
  poe.stay_id,
  poe.ordertime AS charttime,
  poe.fullcode,
  0 AS cmo,
  poe.dni,
  poe.dnr
FROM poe