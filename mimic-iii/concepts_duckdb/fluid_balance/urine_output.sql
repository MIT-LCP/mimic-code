-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.urine_output; CREATE TABLE mimiciii_derived.urine_output AS
SELECT
  oe.icustay_id,
  oe.charttime,
  SUM(CASE WHEN oe.itemid = 227488 THEN -1 * value ELSE value END) AS value
FROM mimiciii.outputevents AS oe
WHERE
  oe.itemid IN (
    40055,
    43175,
    40069,
    40094,
    40715,
    40473,
    40085,
    40057,
    40056,
    40405,
    40428,
    40086,
    40096,
    40651,
    226559,
    226560,
    226561,
    226584,
    226563,
    226564,
    226565,
    226567,
    226557,
    226558,
    227488,
    227489
  )
  AND oe.value < 5000
  AND NOT oe.icustay_id IS NULL
GROUP BY
  icustay_id,
  charttime