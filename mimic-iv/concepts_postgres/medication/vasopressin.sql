-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.vasopressin; CREATE TABLE mimiciv_derived.vasopressin AS
/* This query extracts dose+durations of vasopressin administration */ /* Local hospital dosage guidance: 1.2 units/hour (low) - 2.4 units/hour (high) */
SELECT
  stay_id,
  linkorderid, /* three rows in units/min, rest in units/hour */ /* the three rows in units/min look reasonable and */ /* fit with the patient course */ /* convert all rows to units/hour */
  CASE WHEN rateuom = 'units/min' THEN rate * 60.0 ELSE rate END AS vaso_rate,
  amount AS vaso_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid = 222315 /* vasopressin */