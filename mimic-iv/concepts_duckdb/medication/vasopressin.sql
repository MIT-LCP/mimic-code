-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.vasopressin; CREATE TABLE mimiciv_derived.vasopressin AS
SELECT
  stay_id,
  linkorderid,
  CASE WHEN rateuom = 'units/min' THEN rate * 60.0 ELSE rate END AS vaso_rate,
  amount AS vaso_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid = 222315