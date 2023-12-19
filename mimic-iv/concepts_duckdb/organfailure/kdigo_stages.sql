-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.kdigo_stages; CREATE TABLE mimiciv_derived.kdigo_stages AS
WITH cr_stg AS (
  SELECT
    cr.stay_id,
    cr.charttime,
    cr.creat_low_past_7day,
    cr.creat_low_past_48hr,
    cr.creat,
    CASE
      WHEN cr.creat >= (
        cr.creat_low_past_7day * 3.0
      )
      THEN 3
      WHEN cr.creat >= 4
      AND (
        cr.creat_low_past_48hr <= 3.7 OR cr.creat >= (
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
  FROM mimiciv_derived.kdigo_creatinine AS cr
), uo_stg AS (
  SELECT
    uo.stay_id,
    uo.charttime,
    uo.weight,
    uo.uo_rt_6hr,
    uo.uo_rt_12hr,
    uo.uo_rt_24hr,
    CASE
      WHEN uo.uo_rt_6hr IS NULL
      THEN NULL
      WHEN uo.charttime <= ie.intime + INTERVAL '6' HOUR
      THEN 0
      WHEN uo.uo_tm_24hr >= 24 AND uo.uo_rt_24hr < 0.3
      THEN 3
      WHEN uo.uo_tm_12hr >= 12 AND uo.uo_rt_12hr = 0
      THEN 3
      WHEN uo.uo_tm_12hr >= 12 AND uo.uo_rt_12hr < 0.5
      THEN 2
      WHEN uo.uo_tm_6hr >= 6 AND uo.uo_rt_6hr < 0.5
      THEN 1
      ELSE 0
    END AS aki_stage_uo
  FROM mimiciv_derived.kdigo_uo AS uo
  INNER JOIN mimiciv_icu.icustays AS ie
    ON uo.stay_id = ie.stay_id
), crrt_stg AS (
  SELECT
    stay_id,
    charttime,
    CASE WHEN NOT charttime IS NULL THEN 3 ELSE NULL END AS aki_stage_crrt
  FROM mimiciv_derived.crrt
  WHERE
    NOT crrt_mode IS NULL
), tm_stg AS (
  SELECT
    stay_id,
    charttime
  FROM cr_stg
  UNION
  SELECT
    stay_id,
    charttime
  FROM uo_stg
  UNION
  SELECT
    stay_id,
    charttime
  FROM crrt_stg
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.stay_id,
  tm.charttime,
  cr.creat_low_past_7day,
  cr.creat_low_past_48hr,
  cr.creat,
  cr.aki_stage_creat,
  uo.uo_rt_6hr,
  uo.uo_rt_12hr,
  uo.uo_rt_24hr,
  uo.aki_stage_uo,
  crrt.aki_stage_crrt,
  GREATEST(
    COALESCE(cr.aki_stage_creat, 0),
    COALESCE(uo.aki_stage_uo, 0),
    COALESCE(crrt.aki_stage_crrt, 0)
  ) AS aki_stage,
  MAX(
    GREATEST(
      COALESCE(cr.aki_stage_creat, 0),
      COALESCE(uo.aki_stage_uo, 0),
      COALESCE(crrt.aki_stage_crrt, 0)
    )
  ) OVER (PARTITION BY ie.subject_id ORDER BY DATE_DIFF('microseconds', ie.intime, tm.charttime)/1000000.0 NULLS FIRST RANGE BETWEEN 21600 PRECEDING AND CURRENT ROW) AS aki_stage_smoothed
FROM mimiciv_icu.icustays AS ie
LEFT JOIN tm_stg AS tm
  ON ie.stay_id = tm.stay_id
LEFT JOIN cr_stg AS cr
  ON ie.stay_id = cr.stay_id AND tm.charttime = cr.charttime
LEFT JOIN uo_stg AS uo
  ON ie.stay_id = uo.stay_id AND tm.charttime = uo.charttime
LEFT JOIN crrt_stg AS crrt
  ON ie.stay_id = crrt.stay_id AND tm.charttime = crrt.charttime