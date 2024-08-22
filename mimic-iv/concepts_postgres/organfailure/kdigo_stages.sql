-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.kdigo_stages; CREATE TABLE mimiciv_derived.kdigo_stages AS
/* This query checks if the patient had AKI according to KDIGO. */ /* AKI is calculated every time a creatinine or urine output measurement occurs. */ /* Baseline creatinine is defined as the lowest creatinine in the past 7 days. */ /* get creatinine stages */
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
      AND /* For patients reaching Stage 3 by SCr >4.0 mg/dl */ /* require that the patient first achieve ... */ /*      an acute increase >= 0.3 within 48 hr */ /*      *or* an increase of >= 1.5 times baseline */ (
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
    uo.uo_rt_24hr, /* AKI stages according to urine output */
    CASE
      WHEN uo.uo_rt_6hr IS NULL
      THEN NULL
      WHEN uo.charttime <= ie.intime + INTERVAL '6 HOUR'
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
  crrt.aki_stage_crrt, /* Classify AKI using both creatinine/urine output criteria */
  GREATEST(
    COALESCE(cr.aki_stage_creat, 0),
    COALESCE(uo.aki_stage_uo, 0),
    COALESCE(crrt.aki_stage_crrt, 0)
  ) AS aki_stage, /* We intend to combine together the scores from creatinine/UO by left */ /* joining from the above temporary table which has all possible charttime. */ /* This will guarantee we include all creatinine/UO measurements. */ /* However, we have times where UO is measured, but not creatinine. */ /* Thus we end up with NULLs for the creatinine column(s). Calculating */ /* the highest stage across the columns will often only consider one stage. */ /* For example, consider the following rows: */ /*   stay_id=123, time=10:00, cr_low_7day=4.0,  uo_rt_6hr=NULL -> stage 3 */ /*   stay_id=123, time=10:30, cr_low_7day=NULL, uo_rt_6hr=0.3  -> stage 1 */ /* This results in the stage alternating from low/high across rows. */ /* To overcome this, we create a new column which carries forward the */ /* highest KDIGO stage from the last 6 hours. In most cases, this smooths */ /* out any discontinuity. */
  MAX(
    GREATEST(
      COALESCE(cr.aki_stage_creat, 0),
      COALESCE(uo.aki_stage_uo, 0),
      COALESCE(crrt.aki_stage_crrt, 0)
    )
  ) OVER (PARTITION BY ie.subject_id ORDER BY EXTRACT(EPOCH FROM tm.charttime - ie.intime) / 1.0 NULLS FIRST RANGE BETWEEN 21600 PRECEDING AND CURRENT ROW) AS aki_stage_smoothed
FROM mimiciv_icu.icustays AS ie
/* get all possible charttimes as listed in tm_stg */
LEFT JOIN tm_stg AS tm
  ON ie.stay_id = tm.stay_id
LEFT JOIN cr_stg AS cr
  ON ie.stay_id = cr.stay_id AND tm.charttime = cr.charttime
LEFT JOIN uo_stg AS uo
  ON ie.stay_id = uo.stay_id AND tm.charttime = uo.charttime
LEFT JOIN crrt_stg AS crrt
  ON ie.stay_id = crrt.stay_id AND tm.charttime = crrt.charttime