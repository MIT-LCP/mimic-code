-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_uo; CREATE TABLE mimiciii_derived.pivoted_uo AS
SELECT
  icustay_id,
  charttime,
  SUM(urineoutput) AS urineoutput
FROM (
  SELECT
    oe.icustay_id,
    oe.charttime,
    CASE WHEN oe.itemid = 227488 AND oe.value > 0 THEN -1 * oe.value ELSE oe.value END AS urineoutput
  FROM mimiciii.outputevents AS oe
  WHERE
    (
      oe.iserror IS NULL OR oe.iserror <> '1'
    )
    AND itemid IN (
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
) AS uo
GROUP BY
  icustay_id,
  charttime
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST