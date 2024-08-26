-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.milrinone; CREATE TABLE mimiciv_derived.milrinone AS
/* This query extracts dose+durations of milrinone administration */ /* Local hospital dosage guidance: 0.5 mcg/kg/min (usual) */
SELECT
  stay_id,
  linkorderid, /* all rows in mcg/kg/min */
  rate AS vaso_rate,
  amount AS vaso_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid = 221986 /* milrinone */