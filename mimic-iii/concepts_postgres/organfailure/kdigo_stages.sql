-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.kdigo_stages; CREATE TABLE mimiciii_derived.kdigo_stages AS
/* This query checks if the patient had AKI according to KDIGO. */ /* AKI is calculated every time a creatinine or urine output measurement occurs. */ /* Baseline creatinine is defined as the lowest creatinine in the past 7 days. */ /* get creatinine stages */
WITH cr_stg AS (
  SELECT
    cr.icustay_id,
    cr.charttime,
    cr.creat,
    CASE
      WHEN cr.creat >= (
        cr.creat_low_past_7day * 3.0
      )
      THEN 3
      WHEN cr.creat >= 4
      AND /* For patients reaching Stage 3 by SCr >4.0 mg/dl */ /* require that the patient first achieve ... acute increase >= 0.3 within 48 hr */ /* *or* an increase of >= 1.5 times baseline */ (
        cr.creat >= (
          cr.creat_low_past_48hr + 0.3
        )
        OR cr.creat >= (
          1.5 * cr.creat_low_past_7day
        )
      )
      THEN 3
      WHEN cr.creat >= (
        cr.creat_low_past_7day * 2.0
      )
      THEN 2
      WHEN cr.creat >= (
        cr.creat_low_past_48hr + 0.3
      )
      THEN 1
      WHEN cr.creat >= (
        cr.creat_low_past_7day * 1.5
      )
      THEN 1
      ELSE 0
    END AS aki_stage_creat
  FROM mimiciii_derived.kdigo_creatinine AS cr
), uo_stg /* stages for UO / creat */ AS (
  SELECT
    uo.icustay_id,
    uo.charttime,
    uo.weight,
    uo.uo_rt_6hr,
    uo.uo_rt_12hr,
    uo.uo_rt_24hr, /* AKI stages according to urine output */
    CASE
      WHEN uo.uo_rt_6hr IS NULL
      THEN NULL
      WHEN uo.charttime <= ie.intime + INTERVAL '6' HOUR
      THEN 0
      WHEN uo.uo_tm_24hr >= 11 AND uo.uo_rt_24hr < 0.3
      THEN 3
      WHEN uo.uo_tm_12hr >= 5 AND uo.uo_rt_12hr = 0
      THEN 3
      WHEN uo.uo_tm_12hr >= 5 AND uo.uo_rt_12hr < 0.5
      THEN 2
      WHEN uo.uo_tm_6hr >= 2 AND uo.uo_rt_6hr < 0.5
      THEN 1
      ELSE 0
    END AS aki_stage_uo
  FROM mimiciii_derived.kdigo_uo AS uo
  INNER JOIN mimiciii.icustays AS ie
    ON uo.icustay_id = ie.icustay_id
), tm_stg /* get all charttimes documented */ AS (
  SELECT
    icustay_id,
    charttime
  FROM cr_stg
  UNION
  SELECT
    icustay_id,
    charttime
  FROM uo_stg
)
SELECT
  ie.icustay_id,
  tm.charttime,
  cr.creat,
  cr.aki_stage_creat,
  uo.uo_rt_6hr,
  uo.uo_rt_12hr,
  uo.uo_rt_24hr,
  uo.aki_stage_uo, /* Classify AKI using both creatinine/urine output criteria */
  GREATEST(COALESCE(cr.aki_stage_creat, 0), COALESCE(uo.aki_stage_uo, 0)) AS aki_stage
FROM mimiciii.icustays AS ie
/* get all possible charttimes as listed in tm_stg */
LEFT JOIN tm_stg AS tm
  ON ie.icustay_id = tm.icustay_id
LEFT JOIN cr_stg AS cr
  ON ie.icustay_id = cr.icustay_id AND tm.charttime = cr.charttime
LEFT JOIN uo_stg AS uo
  ON ie.icustay_id = uo.icustay_id AND tm.charttime = uo.charttime
ORDER BY
  ie.icustay_id NULLS FIRST,
  tm.charttime NULLS FIRST