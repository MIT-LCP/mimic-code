-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.phenylephrine; CREATE TABLE mimiciv_derived.phenylephrine AS
/* This query extracts dose+durations of phenylephrine administration */ /* Local hospital dosage guidance: 0.5 mcg/kg/min (low) - 5 mcg/kg/min (high) */
SELECT
  stay_id,
  linkorderid, /* one row in mcg/min, the rest in mcg/kg/min */
  CASE
    WHEN rateuom = 'mcg/min'
    THEN CAST(rate AS DOUBLE PRECISION) / patientweight
    ELSE rate
  END AS vaso_rate,
  amount AS vaso_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid = 221749 /* phenylephrine */