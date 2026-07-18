-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_icp; CREATE TABLE mimiciii_derived.pivoted_icp AS
WITH ce AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    CASE WHEN valuenum > 0 AND valuenum < 100 THEN valuenum ELSE NULL END AS icp
  FROM mimiciii.chartevents AS ce
  WHERE
    (
      ce.error IS NULL OR ce.error = 0
    )
    AND NOT ce.icustay_id IS NULL
    AND ce.itemid IN (
      226,
      1374,
      2045,
      2635,
      2660,
      2733,
      2745,
      2870,
      2956,
      2985,
      5856,
      7116,
      8218,
      8298,
      8299,
      8305,
      220765,
      227989
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