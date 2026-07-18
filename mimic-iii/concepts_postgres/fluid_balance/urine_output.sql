-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.urine_output; CREATE TABLE mimiciii_derived.urine_output AS
/* First we drop the table if it exists */
SELECT
  oe.icustay_id,
  oe.charttime,
  SUM(
    CASE WHEN oe.itemid = 227488 THEN -1 * value ELSE value END /* we consider input of GU irrigant as a negative volume */
  ) AS value
FROM mimiciii.outputevents AS oe
WHERE
  oe.itemid IN (
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
  AND oe.value < 5000 /* sanity check on urine value */
  AND NOT oe.icustay_id IS NULL
GROUP BY
  icustay_id,
  charttime