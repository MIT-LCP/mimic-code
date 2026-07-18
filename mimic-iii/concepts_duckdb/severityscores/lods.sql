-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.lods; CREATE TABLE mimiciii_derived.lods AS
WITH cpap AS (
  SELECT
    ie.icustay_id,
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
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.chartevents AS ce
    ON ie.icustay_id = ce.icustay_id
    AND ce.charttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
  WHERE
    itemid IN (467, 469, 226732)
    AND (
      LOWER(ce.value) LIKE '%cpap%' OR LOWER(ce.value) LIKE '%bipap mask%'
    )
    AND (
      ce.error IS NULL OR ce.error = 0
    )
  GROUP BY
    ie.icustay_id
), pafi1 AS (
  SELECT
    bg.icustay_id,
    bg.charttime,
    pao2fio2,
    CASE WHEN NOT vd.icustay_id IS NULL THEN 1 ELSE 0 END AS vent,
    CASE WHEN NOT cp.icustay_id IS NULL THEN 1 ELSE 0 END AS cpap
  FROM mimiciii_derived.blood_gas_first_day_arterial AS bg
  LEFT JOIN mimiciii_derived.ventilation_durations AS vd
    ON bg.icustay_id = vd.icustay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
  LEFT JOIN cpap AS cp
    ON bg.icustay_id = cp.icustay_id
    AND bg.charttime >= cp.starttime
    AND bg.charttime <= cp.endtime
), pafi2 AS (
  SELECT
    icustay_id,
    MIN(pao2fio2) AS pao2fio2_vent_min
  FROM pafi1
  WHERE
    vent = 1 OR cpap = 1
  GROUP BY
    icustay_id
), cohort AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
    ie.intime,
    ie.outtime,
    gcs.mingcs,
    vital.heartrate_max,
    vital.heartrate_min,
    vital.sysbp_max,
    vital.sysbp_min,
    pf.pao2fio2_vent_min,
    labs.bun_max,
    labs.bun_min,
    labs.wbc_max,
    labs.wbc_min,
    labs.bilirubin_max,
    labs.creatinine_max,
    labs.pt_min,
    labs.pt_max,
    labs.platelet_min,
    uo.urineoutput
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.admissions AS adm
    ON ie.hadm_id = adm.hadm_id
  INNER JOIN mimiciii.patients AS pat
    ON ie.subject_id = pat.subject_id
  LEFT JOIN pafi2 AS pf
    ON ie.icustay_id = pf.icustay_id
  LEFT JOIN mimiciii_derived.gcs_first_day AS gcs
    ON ie.icustay_id = gcs.icustay_id
  LEFT JOIN mimiciii_derived.vitals_first_day AS vital
    ON ie.icustay_id = vital.icustay_id
  LEFT JOIN mimiciii_derived.urine_output_first_day AS uo
    ON ie.icustay_id = uo.icustay_id
  LEFT JOIN mimiciii_derived.labs_first_day AS labs
    ON ie.icustay_id = labs.icustay_id
), scorecomp AS (
  SELECT
    cohort.*,
    CASE
      WHEN mingcs IS NULL
      THEN NULL
      WHEN mingcs < 3
      THEN NULL
      WHEN mingcs <= 5
      THEN 5
      WHEN mingcs <= 8
      THEN 3
      WHEN mingcs <= 13
      THEN 1
      ELSE 0
    END AS neurologic,
    CASE
      WHEN heartrate_max IS NULL AND sysbp_min IS NULL
      THEN NULL
      WHEN heartrate_min < 30
      THEN 5
      WHEN sysbp_min < 40
      THEN 5
      WHEN sysbp_min < 70
      THEN 3
      WHEN sysbp_max >= 270
      THEN 3
      WHEN heartrate_max >= 140
      THEN 1
      WHEN sysbp_max >= 240
      THEN 1
      WHEN sysbp_min < 90
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
  ie.icustay_id,
  COALESCE(neurologic, 0) + COALESCE(cardiovascular, 0) + COALESCE(renal, 0) + COALESCE(pulmonary, 0) + COALESCE(hematologic, 0) + COALESCE(hepatic, 0) AS LODS,
  neurologic,
  cardiovascular,
  renal,
  pulmonary,
  hematologic,
  hepatic
FROM mimiciii.icustays AS ie
LEFT JOIN scorecomp AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST