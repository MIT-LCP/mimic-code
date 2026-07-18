-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.urine_output_first_day; CREATE TABLE mimiciii_derived.urine_output_first_day AS
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  SUM(
    CASE WHEN oe.itemid = 227488 AND oe.value > 0 THEN -1 * oe.value ELSE oe.value END
  ) AS urineoutput
FROM mimiciii.icustays AS ie
LEFT JOIN mimiciii.outputevents AS oe
  ON ie.subject_id = oe.subject_id
  AND ie.hadm_id = oe.hadm_id
  AND ie.icustay_id = oe.icustay_id
  AND oe.charttime BETWEEN ie.intime AND (
    ie.intime + INTERVAL '1' DAY
  )
WHERE
  itemid IN (
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
GROUP BY
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id
ORDER BY
  ie.subject_id NULLS FIRST,
  ie.hadm_id NULLS FIRST,
  ie.icustay_id NULLS FIRST