-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.dobutamine; CREATE TABLE mimiciv_derived.dobutamine AS
/* This query extracts dose+durations of dobutamine administration */ /* Local hospital dosage guidance: 2 mcg/kg/min (low) - 40 mcg/kg/min (max) */
SELECT
  stay_id,
  linkorderid, /* all rows in mcg/kg/min */
  rate AS vaso_rate,
  amount AS vaso_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid = 221653 /* dobutamine */