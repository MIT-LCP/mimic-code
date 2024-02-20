-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.neuroblock; CREATE TABLE mimiciv_derived.neuroblock AS
/* This query extracts dose+durations of neuromuscular blocking agents */
SELECT
  stay_id,
  orderid,
  rate AS drug_rate,
  amount AS drug_amount,
  starttime,
  endtime
FROM mimiciv_icu.inputevents
WHERE
  itemid IN (222062 /* Vecuronium (664 rows, 154 infusion rows) */, 221555 /* Cisatracurium (9334 rows, 8970 infusion rows) */)
  AND NOT rate IS NULL /* only continuous infusions */