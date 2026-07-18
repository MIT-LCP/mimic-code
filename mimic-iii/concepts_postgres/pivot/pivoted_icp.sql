-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_icp; CREATE TABLE mimiciii_derived.pivoted_icp AS
WITH ce AS (
  SELECT
    ce.icustay_id,
    ce.charttime, /* TODO: handle high ICPs when monitoring two ICPs */
    CASE WHEN valuenum > 0 AND valuenum < 100 THEN valuenum ELSE NULL END AS icp
  FROM mimiciii.chartevents AS ce
  /* exclude rows marked as error */
  WHERE
    (
      ce.error IS NULL OR ce.error = 0
    )
    AND NOT ce.icustay_id IS NULL
    AND ce.itemid IN (
      226, /* ICP -- 99159 */
      1374, /* ICP Right -- 100 */
      2045, /* icp left -- 70 */
      2635, /* VENT ICP -- 195 */
      2660, /* ICP Camino -- 40 */
      2733, /* RIGHT VENT ICP -- 203 */
      2745, /* ICP LEFT -- 232 */
      2870, /* ICP-ventriculostomuy -- 114 */
      2956, /* ventriculostomy icp -- 64 */
      2985, /* ICP ventricle -- 85 */
      5856, /* icp -- 7 */
      7116, /* Rt ICP -- 80 */
      8218, /* left icp -- 6 */
      8298, /* L ICP -- 47 */
      8299, /* R ICP -- 16 */
      8305, /* ICP  Right -- 49 */
      220765, /* Intra Cranial Pressure -- 92306 */
      227989 /* Intra Cranial Pressure #2 -- 1052 */
    )
)
SELECT
  ce.icustay_id,
  ce.charttime,
  MAX(icp) AS icp
FROM ce
GROUP BY
  ce.icustay_id,
  ce.charttime
ORDER BY
  ce.icustay_id NULLS FIRST,
  ce.charttime NULLS FIRST