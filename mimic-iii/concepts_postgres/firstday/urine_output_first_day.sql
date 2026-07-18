-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.urine_output_first_day; CREATE TABLE mimiciii_derived.urine_output_first_day AS
/* ------------------------------------------------------------------ */ /* Purpose: Create a view of the urine output for each ICUSTAY_ID over the first 24 hours. */ /* ------------------------------------------------------------------ */
SELECT
  ie.subject_id, /* patient identifiers */
  ie.hadm_id,
  ie.icustay_id, /* volumes associated with urine output ITEMIDs */
  SUM(
    CASE WHEN oe.itemid = 227488 AND oe.value > 0 THEN -1 * oe.value ELSE oe.value END /* we consider input of GU irrigant as a negative volume */
  ) AS urineoutput
FROM mimiciii.icustays AS ie
/* Join to the outputevents table to get urine output */
LEFT JOIN mimiciii.outputevents AS oe
  ON ie.subject_id = oe.subject_id
  AND ie.hadm_id = oe.hadm_id
  AND ie.icustay_id = oe.icustay_id
  AND /* and ensure the data occurs during the first day */ oe.charttime BETWEEN ie.intime AND (
    ie.intime + INTERVAL '1' DAY
  ) /* first ICU day */
WHERE
  itemid IN (
    40055, /* these are the most frequently occurring urine output observations in CareVue */ /* "Urine Out Foley" */
    43175, /* "Urine ." */
    40069, /* "Urine Out Void" */
    40094, /* "Urine Out Condom Cath" */
    40715, /* "Urine Out Suprapubic" */
    40473, /* "Urine Out IleoConduit" */
    40085, /* "Urine Out Incontinent" */
    40057, /* "Urine Out Rt Nephrostomy" */
    40056, /* "Urine Out Lt Nephrostomy" */
    40405, /* "Urine Out Other" */
    40428, /* "Urine Out Straight Cath" */
    40086, /*	Urine Out Incontinent */
    40096, /* "Urine Out Ureteral Stent #1" */
    40651, /* "Urine Out Ureteral Stent #2" */
    226559, /* these are the most frequently occurring urine output observations in MetaVision */ /* "Foley" */
    226560, /* "Void" */
    226561, /* "Condom Cath" */
    226584, /* "Ileoconduit" */
    226563, /* "Suprapubic" */
    226564, /* "R Nephrostomy" */
    226565, /* "L Nephrostomy" */
    226567, /*	Straight Cath */
    226557, /* R Ureteral Stent */
    226558, /* L Ureteral Stent */
    227488, /* GU Irrigant Volume In */
    227489 /* GU Irrigant/Urine Volume Out */
  )
GROUP BY
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id
ORDER BY
  ie.subject_id NULLS FIRST,
  ie.hadm_id NULLS FIRST,
  ie.icustay_id NULLS FIRST