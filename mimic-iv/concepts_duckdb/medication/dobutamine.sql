-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.dobutamine; CREATE TABLE mimiciv_derived.dobutamine AS
SELECT
  stay_id,
  linkorderid,
  rate AS vaso_rate,
  amount AS vaso_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid = 221653