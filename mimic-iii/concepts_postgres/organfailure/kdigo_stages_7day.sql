-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.kdigo_stages_7day; CREATE TABLE mimiciii_derived.kdigo_stages_7day AS
/* This query checks if the patient had AKI during the first 7 days of their ICU */ /* stay according to the KDIGO guideline. */ /* https://kdigo.org/wp-content/uploads/2016/10/KDIGO-2012-AKI-Guideline-English.pdf */ /* get the worst staging of creatinine in the first 48 hours */
WITH cr_aki AS (
  SELECT
    k.icustay_id,
    k.charttime,
    k.creat,
    k.aki_stage_creat,
    ROW_NUMBER() OVER (
      PARTITION BY k.icustay_id
      ORDER BY k.aki_stage_creat DESC NULLS LAST, k.creat DESC NULLS LAST, k.charttime NULLS FIRST
    ) AS rn
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii_derived.kdigo_stages AS k
    ON ie.icustay_id = k.icustay_id
  WHERE
    CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', k.charttime) - DATE_TRUNC('hour', ie.intime)) / 3600 AS BIGINT) > -6
    AND (CAST(k.charttime AS DATE) - CAST(ie.intime AS DATE)) <= 7
    AND NOT k.aki_stage_creat IS NULL
), uo_aki /* get the worst staging of urine output in the first 48 hours */ AS (
  SELECT
    k.icustay_id,
    k.charttime,
    k.uo_rt_6hr,
    k.uo_rt_12hr,
    k.uo_rt_24hr,
    k.aki_stage_uo,
    ROW_NUMBER() OVER (
      PARTITION BY k.icustay_id
      ORDER BY k.aki_stage_uo DESC NULLS LAST, k.uo_rt_24hr DESC NULLS LAST, k.uo_rt_12hr DESC NULLS LAST, k.uo_rt_6hr DESC NULLS LAST
    ) AS rn
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii_derived.kdigo_stages AS k
    ON ie.icustay_id = k.icustay_id
  WHERE
    CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', k.charttime) - DATE_TRUNC('hour', ie.intime)) / 3600 AS BIGINT) > -6
    AND (CAST(k.charttime AS DATE) - CAST(ie.intime AS DATE)) <= 7
    AND NOT k.aki_stage_uo IS NULL
)
/* final table is aki_stage, include worst cr/uo for convenience */
SELECT
  ie.icustay_id,
  cr.charttime AS charttime_creat,
  cr.creat,
  cr.aki_stage_creat,
  uo.charttime AS charttime_uo,
  uo.uo_rt_6hr,
  uo.uo_rt_12hr,
  uo.uo_rt_24hr,
  uo.aki_stage_uo, /* Classify AKI using both creatinine/urine output criteria */
  GREATEST(COALESCE(cr.aki_stage_creat, 0), COALESCE(uo.aki_stage_uo, 0)) AS aki_stage_7day,
  CASE WHEN cr.aki_stage_creat > 0 OR uo.aki_stage_uo > 0 THEN 1 ELSE 0 END AS aki_7day
FROM mimiciii.icustays AS ie
LEFT JOIN cr_aki AS cr
  ON ie.icustay_id = cr.icustay_id AND cr.rn = 1
LEFT JOIN uo_aki AS uo
  ON ie.icustay_id = uo.icustay_id AND uo.rn = 1
ORDER BY
  ie.icustay_id NULLS FIRST