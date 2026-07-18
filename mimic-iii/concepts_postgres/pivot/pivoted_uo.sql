-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_uo; CREATE TABLE mimiciii_derived.pivoted_uo AS
SELECT
  icustay_id,
  charttime,
  SUM(urineoutput) AS urineoutput
FROM (
  SELECT
    oe.icustay_id, /* patient identifiers */
    oe.charttime, /* volumes associated with urine output ITEMIDs */ /* note we consider input of GU irrigant as a negative volume */
    CASE WHEN oe.itemid = 227488 AND oe.value > 0 THEN -1 * oe.value ELSE oe.value END AS urineoutput
  FROM mimiciii.outputevents AS oe
  /* exclude rows marked as error */
  WHERE
    (
      oe.iserror IS NULL OR oe.iserror <> '1'
    )
    AND itemid IN (
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
      226559, /* these are the most frequently occurring urine output observations in CareVue */ /* "Foley" */
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
) AS uo
GROUP BY
  icustay_id,
  charttime
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST