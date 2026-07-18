-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.kdigo_stages_48hr; CREATE TABLE mimiciii_derived.kdigo_stages_48hr AS
WITH cr_aki AS (
  SELECT
    k.icustay_id,
    k.charttime,
    k.creat,
    k.aki_stage_creat,
    ROW_NUMBER() OVER (
      PARTITION BY k.icustay_id
      ORDER BY k.aki_stage_creat DESC, k.creat DESC, k.charttime NULLS FIRST
    ) AS rn
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii_derived.kdigo_stages AS k
    ON ie.icustay_id = k.icustay_id
  WHERE
    DATE_DIFF('HOUR', ie.intime, k.charttime) > -6
    AND DATE_DIFF('HOUR', ie.intime, k.charttime) <= 48
    AND NOT k.aki_stage_creat IS NULL
), uo_aki AS (
  SELECT
    k.icustay_id,
    k.charttime,
    k.uo_rt_6hr,
    k.uo_rt_12hr,
    k.uo_rt_24hr,
    k.aki_stage_uo,
    ROW_NUMBER() OVER (
      PARTITION BY k.icustay_id
      ORDER BY k.aki_stage_uo DESC, k.uo_rt_24hr DESC, k.uo_rt_12hr DESC, k.uo_rt_6hr DESC
    ) AS rn
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii_derived.kdigo_stages AS k
    ON ie.icustay_id = k.icustay_id
  WHERE
    DATE_DIFF('HOUR', ie.intime, k.charttime) > -6
    AND DATE_DIFF('HOUR', ie.intime, k.charttime) <= 48
    AND NOT k.aki_stage_uo IS NULL
)
SELECT
  ie.icustay_id,
  cr.charttime AS charttime_creat,
  cr.creat,
  cr.aki_stage_creat,
  uo.charttime AS charttime_uo,
  uo.uo_rt_6hr,
  uo.uo_rt_12hr,
  uo.uo_rt_24hr,
  uo.aki_stage_uo,
  CASE
    WHEN COALESCE(cr.aki_stage_creat, 0) IS NULL OR COALESCE(uo.aki_stage_uo, 0) IS NULL
    THEN NULL
    ELSE GREATEST(COALESCE(cr.aki_stage_creat, 0), COALESCE(uo.aki_stage_uo, 0))
  END AS aki_stage_48hr,
  CASE WHEN cr.aki_stage_creat > 0 OR uo.aki_stage_uo > 0 THEN 1 ELSE 0 END AS aki_48hr
FROM mimiciii.icustays AS ie
LEFT JOIN cr_aki AS cr
  ON ie.icustay_id = cr.icustay_id AND cr.rn = 1
LEFT JOIN uo_aki AS uo
  ON ie.icustay_id = uo.icustay_id AND uo.rn = 1
ORDER BY
  ie.icustay_id NULLS FIRST