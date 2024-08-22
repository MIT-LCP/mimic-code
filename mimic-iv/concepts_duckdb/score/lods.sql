-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.lods; CREATE TABLE mimiciv_derived.lods AS
WITH cpap AS (
  SELECT
    ie.stay_id,
    MIN(charttime - INTERVAL '1' HOUR) AS starttime,
    MAX(charttime + INTERVAL '4' HOUR) AS endtime,
    MAX(
      CASE
        WHEN LOWER(ce.value) LIKE '%cpap%'
        THEN 1
        WHEN LOWER(ce.value) LIKE '%bipap mask%'
        THEN 1
        ELSE 0
      END
    ) AS cpap
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_icu.chartevents AS ce
    ON ie.stay_id = ce.stay_id
    AND ce.charttime >= ie.intime
    AND ce.charttime <= ie.intime + INTERVAL '1' DAY
  WHERE
    itemid = 226732
    AND (
      LOWER(ce.value) LIKE '%cpap%' OR LOWER(ce.value) LIKE '%bipap mask%'
    )
  GROUP BY
    ie.stay_id
), pafi1 AS (
  SELECT
    ie.stay_id,
    bg.charttime,
    pao2fio2ratio,
    CASE WHEN NOT vd.stay_id IS NULL THEN 1 ELSE 0 END AS vent,
    CASE WHEN NOT cp.stay_id IS NULL THEN 1 ELSE 0 END AS cpap
  FROM mimiciv_derived.bg AS bg
  INNER JOIN mimiciv_icu.icustays AS ie
    ON bg.hadm_id = ie.hadm_id
    AND bg.charttime >= ie.intime
    AND bg.charttime < ie.outtime
  LEFT JOIN mimiciv_derived.ventilation AS vd
    ON ie.stay_id = vd.stay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
    AND vd.ventilation_status = 'InvasiveVent'
  LEFT JOIN cpap AS cp
    ON ie.stay_id = cp.stay_id
    AND bg.charttime >= cp.starttime
    AND bg.charttime <= cp.endtime
), pafi2 AS (
  SELECT
    stay_id,
    MIN(pao2fio2ratio) AS pao2fio2_vent_min
  FROM pafi1
  WHERE
    vent = 1 OR cpap = 1
  GROUP BY
    stay_id
), cohort AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.stay_id,
    ie.intime,
    ie.outtime,
    gcs.gcs_min,
    vital.heart_rate_max,
    vital.heart_rate_min,
    vital.sbp_max,
    vital.sbp_min,
    pf.pao2fio2_vent_min,
    labs.bun_max,
    labs.bun_min,
    labs.wbc_max,
    labs.wbc_min,
    labs.bilirubin_total_max AS bilirubin_max,
    labs.creatinine_max,
    labs.pt_min,
    labs.pt_max,
    labs.platelets_min AS platelet_min,
    uo.urineoutput
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_hosp.admissions AS adm
    ON ie.hadm_id = adm.hadm_id
  INNER JOIN mimiciv_hosp.patients AS pat
    ON ie.subject_id = pat.subject_id
  LEFT JOIN pafi2 AS pf
    ON ie.stay_id = pf.stay_id
  LEFT JOIN mimiciv_derived.first_day_gcs AS gcs
    ON ie.stay_id = gcs.stay_id
  LEFT JOIN mimiciv_derived.first_day_vitalsign AS vital
    ON ie.stay_id = vital.stay_id
  LEFT JOIN mimiciv_derived.first_day_urine_output AS uo
    ON ie.stay_id = uo.stay_id
  LEFT JOIN mimiciv_derived.first_day_lab AS labs
    ON ie.stay_id = labs.stay_id
), scorecomp AS (
  SELECT
    cohort.*,
    CASE
      WHEN gcs_min IS NULL
      THEN NULL
      WHEN gcs_min < 3
      THEN NULL
      WHEN gcs_min <= 5
      THEN 5
      WHEN gcs_min <= 8
      THEN 3
      WHEN gcs_min <= 13
      THEN 1
      ELSE 0
    END AS neurologic,
    CASE
      WHEN heart_rate_max IS NULL AND sbp_min IS NULL
      THEN NULL
      WHEN heart_rate_min < 30
      THEN 5
      WHEN sbp_min < 40
      THEN 5
      WHEN sbp_min < 70
      THEN 3
      WHEN sbp_max >= 270
      THEN 3
      WHEN heart_rate_max >= 140
      THEN 1
      WHEN sbp_max >= 240
      THEN 1
      WHEN sbp_min < 90
      THEN 1
      ELSE 0
    END AS cardiovascular,
    CASE
      WHEN bun_max IS NULL OR urineoutput IS NULL OR creatinine_max IS NULL
      THEN NULL
      WHEN urineoutput < 500.0
      THEN 5
      WHEN bun_max >= 56.0
      THEN 5
      WHEN creatinine_max >= 1.60
      THEN 3
      WHEN urineoutput < 750.0
      THEN 3
      WHEN bun_max >= 28.0
      THEN 3
      WHEN urineoutput >= 10000.0
      THEN 3
      WHEN creatinine_max >= 1.20
      THEN 1
      WHEN bun_max >= 17.0
      THEN 1
      WHEN bun_max >= 7.50
      THEN 1
      ELSE 0
    END AS renal,
    CASE
      WHEN pao2fio2_vent_min IS NULL
      THEN 0
      WHEN pao2fio2_vent_min >= 150
      THEN 1
      WHEN pao2fio2_vent_min < 150
      THEN 3
      ELSE NULL
    END AS pulmonary,
    CASE
      WHEN wbc_max IS NULL AND platelet_min IS NULL
      THEN NULL
      WHEN wbc_min < 1.0
      THEN 3
      WHEN wbc_min < 2.5
      THEN 1
      WHEN platelet_min < 50.0
      THEN 1
      WHEN wbc_max >= 50.0
      THEN 1
      ELSE 0
    END AS hematologic,
    CASE
      WHEN pt_max IS NULL AND bilirubin_max IS NULL
      THEN NULL
      WHEN bilirubin_max >= 2.0
      THEN 1
      WHEN pt_max > (
        12 + 3
      )
      THEN 1
      WHEN pt_min < (
        12 * 0.25
      )
      THEN 1
      ELSE 0
    END AS hepatic
  FROM cohort
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.stay_id,
  COALESCE(neurologic, 0) + COALESCE(cardiovascular, 0) + COALESCE(renal, 0) + COALESCE(pulmonary, 0) + COALESCE(hematologic, 0) + COALESCE(hepatic, 0) AS lods,
  neurologic,
  cardiovascular,
  renal,
  pulmonary,
  hematologic,
  hepatic
FROM mimiciv_icu.icustays AS ie
LEFT JOIN scorecomp AS s
  ON ie.stay_id = s.stay_id