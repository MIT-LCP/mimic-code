-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.phenylephrine; CREATE TABLE mimiciv_derived.phenylephrine AS
SELECT
  stay_id,
  linkorderid,
  CASE WHEN rateuom = 'mcg/min' THEN rate / patientweight ELSE rate END AS vaso_rate,
  amount AS vaso_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid = 221749