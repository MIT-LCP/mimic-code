-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.neuroblock; CREATE TABLE mimiciv_derived.neuroblock AS
SELECT
  stay_id,
  orderid,
  rate AS drug_rate,
  amount AS drug_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid IN (222062, 221555) AND NOT rate IS NULL