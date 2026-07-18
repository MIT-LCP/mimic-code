-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_oasis; CREATE TABLE mimiciii_derived.pivoted_oasis AS
WITH co_hours AS (
  SELECT
    ih.icustay_id,
    ie.hadm_id,
    hr,
    ih.endtime - INTERVAL '1' HOUR AS starttime,
    ih.endtime
  FROM mimiciii_derived.icustay_hours AS ih
  INNER JOIN mimiciii.icustays AS ie
    ON ih.icustay_id = ie.icustay_id
), mini_agg AS (
  SELECT
    co.icustay_id,
    co.hr,
    MIN(v.HeartRate) AS HeartRate_min,
    MAX(v.HeartRate) AS HeartRate_max,
    MIN(v.TempC) AS TempC_min,
    MAX(v.TempC) AS TempC_max,
    MIN(v.MeanBP) AS MeanBP_min,
    MAX(v.MeanBP) AS MeanBP_max,
    MIN(v.RespRate) AS RespRate_min,
    MAX(v.RespRate) AS RespRate_max,
    MIN(gcs.GCS) AS GCS_min,
    MAX(
      CASE
        WHEN NOT vd1.icustay_id IS NULL
        THEN 1
        WHEN NOT vd2.icustay_id IS NULL
        THEN 1
        ELSE 0
      END
    ) AS mechvent
  FROM co_hours AS co
  LEFT JOIN mimiciii_derived.pivoted_vital AS v
    ON co.icustay_id = v.icustay_id
    AND co.starttime < v.charttime
    AND co.endtime >= v.charttime
  LEFT JOIN mimiciii_derived.pivoted_gcs AS gcs
    ON co.icustay_id = gcs.icustay_id
    AND co.starttime < gcs.charttime
    AND co.endtime >= gcs.charttime
  LEFT JOIN mimiciii_derived.ventilation_durations AS vd1
    ON co.icustay_id = vd1.icustay_id
    AND co.starttime >= vd1.starttime
    AND co.starttime <= vd1.endtime
  LEFT JOIN mimiciii_derived.ventilation_durations AS vd2
    ON co.icustay_id = vd2.icustay_id
    AND co.endtime >= vd2.starttime
    AND co.endtime <= vd2.endtime
  GROUP BY
    co.icustay_id,
    co.hr
), uo AS (
  SELECT
    co.icustay_id,
    co.hr,
    SUM(uo.urineoutput) AS urineoutput
  FROM co_hours AS co
  LEFT JOIN mimiciii_derived.pivoted_uo AS uo
    ON co.icustay_id = uo.icustay_id
    AND co.starttime < uo.charttime
    AND co.endtime >= uo.charttime
  GROUP BY
    co.icustay_id,
    co.hr
), surgflag AS (
  SELECT
    ie.icustay_id,
    MAX(
      CASE
        WHEN LOWER(curr_service) LIKE '%surg%'
        THEN 1
        WHEN curr_service = 'ORTHO'
        THEN 1
        ELSE 0
      END
    ) AS surgical
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii.services AS se
    ON ie.hadm_id = se.hadm_id AND se.transfertime < ie.intime + INTERVAL '1' DAY
  GROUP BY
    ie.icustay_id
), scorecomp AS (
  SELECT
    co.icustay_id,
    co.hr,
    co.starttime,
    co.endtime,
    ma.meanbp_min,
    ma.meanbp_max,
    ma.heartrate_min,
    ma.heartrate_max,
    ma.tempc_min,
    ma.tempc_max,
    ma.resprate_min,
    ma.resprate_max,
    ma.gcs_min,
    ma.mechvent,
    uo.urineoutput,
    DATE_DIFF('YEAR', pt.dob, ie.intime) AS age,
    DATE_DIFF('SECOND', adm.admittime, ie.intime) AS preiculos,
    CASE
      WHEN adm.ADMISSION_TYPE = 'ELECTIVE' AND sf.surgical = 1
      THEN 1
      WHEN adm.ADMISSION_TYPE IS NULL OR sf.surgical IS NULL
      THEN NULL
      ELSE 0
    END AS electivesurgery
  FROM co_hours AS co
  INNER JOIN mimiciii.admissions AS adm
    ON co.hadm_id = adm.hadm_id
  INNER JOIN mimiciii.icustays AS ie
    ON co.icustay_id = ie.icustay_id
  INNER JOIN mimiciii.patients AS pt
    ON adm.subject_id = pt.subject_id
  LEFT JOIN surgflag AS sf
    ON co.icustay_id = sf.icustay_id
  LEFT JOIN mini_agg AS ma
    ON co.icustay_id = ma.icustay_id AND co.hr = ma.hr
  LEFT JOIN uo
    ON co.icustay_id = uo.icustay_id AND co.hr = uo.hr
), scorecalc AS (
  SELECT
    scorecomp.*,
    CASE
      WHEN preiculos IS NULL
      THEN NULL
      WHEN preiculos < 612
      THEN 5
      WHEN preiculos < 17820
      THEN 3
      WHEN preiculos < 86400
      THEN 0
      WHEN preiculos < 1123680
      THEN 1
      ELSE 2
    END AS preiculos_score,
    CASE
      WHEN age IS NULL
      THEN NULL
      WHEN age < 24
      THEN 0
      WHEN age <= 53
      THEN 3
      WHEN age <= 77
      THEN 6
      WHEN age <= 89
      THEN 9
      WHEN age >= 90
      THEN 7
      ELSE 0
    END AS age_score,
    CASE
      WHEN gcs_min IS NULL
      THEN NULL
      WHEN gcs_min <= 7
      THEN 10
      WHEN gcs_min < 14
      THEN 4
      WHEN gcs_min = 14
      THEN 3
      ELSE 0
    END AS gcs_score,
    CASE
      WHEN heartrate_max IS NULL
      THEN NULL
      WHEN heartrate_max > 125
      THEN 6
      WHEN heartrate_min < 33
      THEN 4
      WHEN heartrate_max >= 107 AND heartrate_max <= 125
      THEN 3
      WHEN heartrate_max >= 89 AND heartrate_max <= 106
      THEN 1
      ELSE 0
    END AS heartrate_score,
    CASE
      WHEN meanbp_min IS NULL
      THEN NULL
      WHEN meanbp_min < 20.65
      THEN 4
      WHEN meanbp_min < 51
      THEN 3
      WHEN meanbp_max > 143.44
      THEN 3
      WHEN meanbp_min >= 51 AND meanbp_min < 61.33
      THEN 2
      ELSE 0
    END AS meanbp_score,
    CASE
      WHEN resprate_min IS NULL
      THEN NULL
      WHEN resprate_min < 6
      THEN 10
      WHEN resprate_max > 44
      THEN 9
      WHEN resprate_max > 30
      THEN 6
      WHEN resprate_max > 22
      THEN 1
      WHEN resprate_min < 13
      THEN 1
      ELSE 0
    END AS resprate_score,
    CASE
      WHEN tempc_max IS NULL
      THEN NULL
      WHEN tempc_max > 39.88
      THEN 6
      WHEN tempc_min >= 33.22 AND tempc_min <= 35.93
      THEN 4
      WHEN tempc_max >= 33.22 AND tempc_max <= 35.93
      THEN 4
      WHEN tempc_min < 33.22
      THEN 3
      WHEN tempc_min > 35.93 AND tempc_min <= 36.39
      THEN 2
      WHEN tempc_max >= 36.89 AND tempc_max <= 39.88
      THEN 2
      ELSE 0
    END AS temp_score,
    CASE
      WHEN SUM(urineoutput) OVER W IS NULL
      THEN NULL
      WHEN SUM(urineoutput) OVER W < 671.09
      THEN 10
      WHEN SUM(urineoutput) OVER W > 6896.80
      THEN 8
      WHEN SUM(urineoutput) OVER W >= 671.09 AND SUM(urineoutput) OVER W <= 1426.99
      THEN 5
      WHEN SUM(urineoutput) OVER W >= 1427.00 AND SUM(urineoutput) OVER W <= 2544.14
      THEN 1
      ELSE 0
    END AS urineoutput_score,
    CASE WHEN mechvent IS NULL THEN NULL WHEN mechvent = 1 THEN 9 ELSE 0 END AS mechvent_score,
    CASE WHEN electivesurgery IS NULL THEN NULL WHEN electivesurgery = 1 THEN 0 ELSE 6 END AS electivesurgery_score
  FROM scorecomp
  WINDOW W AS (
    PARTITION BY icustay_id
    ORDER BY hr NULLS FIRST
    ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING
  )
), score_final AS (
  SELECT
    s.*,
    preiculos_score AS preiculos_score_24hours,
    electivesurgery_score AS electivesurgery_score_24hours,
    CAST(COALESCE(MAX(age_score) OVER W, 0) AS SMALLINT) AS age_score_24hours,
    CAST(COALESCE(MAX(gcs_score) OVER W, 0) AS SMALLINT) AS gcs_score_24hours,
    CAST(COALESCE(MAX(heartrate_score) OVER W, 0) AS SMALLINT) AS heartrate_score_24hours,
    CAST(COALESCE(MAX(meanbp_score) OVER W, 0) AS SMALLINT) AS meanbp_score_24hours,
    CAST(COALESCE(MAX(resprate_score) OVER W, 0) AS SMALLINT) AS resprate_score_24hours,
    CAST(COALESCE(MAX(temp_score) OVER W, 0) AS SMALLINT) AS temp_score_24hours,
    CAST(COALESCE(MAX(urineoutput_score) OVER W, 0) AS SMALLINT) AS urineoutput_score_24hours,
    CAST(COALESCE(MAX(mechvent_score) OVER W, 0) AS SMALLINT) AS mechvent_score_24hours,
    CAST((
      preiculos_score + electivesurgery_score + COALESCE(MAX(age_score) OVER W, 0) + COALESCE(MAX(gcs_score) OVER W, 0) + COALESCE(MAX(heartrate_score) OVER W, 0) + COALESCE(MAX(meanbp_score) OVER W, 0) + COALESCE(MAX(resprate_score) OVER W, 0) + COALESCE(MAX(temp_score) OVER W, 0) + COALESCE(MAX(urineoutput_score) OVER W, 0) + COALESCE(MAX(mechvent_score) OVER W, 0)
    ) AS SMALLINT) AS OASIS_24hours
  FROM scorecalc AS s
  WINDOW W AS (
    PARTITION BY icustay_id
    ORDER BY hr NULLS FIRST
    ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING
  )
)
SELECT
  *
FROM score_final
WHERE
  hr >= 0