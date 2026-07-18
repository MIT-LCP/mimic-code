-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.saps; CREATE TABLE mimiciii_derived.saps AS
WITH cpap AS (
  SELECT
    ie.icustay_id,
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
), cohort AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
    ie.intime,
    ie.outtime,
    DATE_DIFF('YEAR', pat.dob, ie.intime) AS age,
    gcs.mingcs,
    vital.heartrate_max,
    vital.heartrate_min,
    vital.sysbp_max,
    vital.sysbp_min,
    vital.resprate_max,
    vital.resprate_min,
    vital.tempc_max,
    vital.tempc_min,
    COALESCE(vital.glucose_max, labs.glucose_max) AS glucose_max,
    COALESCE(vital.glucose_min, labs.glucose_min) AS glucose_min,
    labs.bun_max,
    labs.bun_min,
    labs.hematocrit_max,
    labs.hematocrit_min,
    labs.wbc_max,
    labs.wbc_min,
    labs.sodium_max,
    labs.sodium_min,
    labs.potassium_max,
    labs.potassium_min,
    labs.bicarbonate_max,
    labs.bicarbonate_min,
    vent.vent AS mechvent,
    uo.urineoutput,
    cp.cpap
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.admissions AS adm
    ON ie.hadm_id = adm.hadm_id
  INNER JOIN mimiciii.patients AS pat
    ON ie.subject_id = pat.subject_id
  LEFT JOIN cpap AS cp
    ON ie.icustay_id = cp.icustay_id
  LEFT JOIN mimiciii_derived.gcs_first_day AS gcs
    ON ie.icustay_id = gcs.icustay_id
  LEFT JOIN mimiciii_derived.vitals_first_day AS vital
    ON ie.icustay_id = vital.icustay_id
  LEFT JOIN mimiciii_derived.urine_output_first_day AS uo
    ON ie.icustay_id = uo.icustay_id
  LEFT JOIN mimiciii_derived.ventilation_first_day AS vent
    ON ie.icustay_id = vent.icustay_id
  LEFT JOIN mimiciii_derived.labs_first_day AS labs
    ON ie.icustay_id = labs.icustay_id
), scorecomp AS (
  SELECT
    cohort.*,
    CASE
      WHEN age IS NULL
      THEN NULL
      WHEN age <= 45
      THEN 0
      WHEN age <= 55
      THEN 1
      WHEN age <= 65
      THEN 2
      WHEN age <= 75
      THEN 3
      WHEN age > 75
      THEN 4
    END AS age_score,
    CASE
      WHEN heartrate_max IS NULL
      THEN NULL
      WHEN heartrate_max >= 180
      THEN 4
      WHEN heartrate_min < 40
      THEN 4
      WHEN heartrate_max >= 140
      THEN 3
      WHEN heartrate_min <= 54
      THEN 3
      WHEN heartrate_max >= 110
      THEN 2
      WHEN heartrate_min <= 69
      THEN 2
      WHEN heartrate_max >= 70
      AND heartrate_max <= 109
      AND heartrate_min >= 70
      AND heartrate_min <= 109
      THEN 0
    END AS hr_score,
    CASE
      WHEN sysbp_min IS NULL
      THEN NULL
      WHEN sysbp_max >= 190
      THEN 4
      WHEN sysbp_min < 55
      THEN 4
      WHEN sysbp_max >= 150
      THEN 2
      WHEN sysbp_min <= 79
      THEN 2
      WHEN sysbp_max >= 80 AND sysbp_max <= 149 AND sysbp_min >= 80 AND sysbp_min <= 149
      THEN 0
    END AS sysbp_score,
    CASE
      WHEN tempc_max IS NULL
      THEN NULL
      WHEN tempc_max >= 41.0
      THEN 4
      WHEN tempc_min < 30.0
      THEN 4
      WHEN tempc_max >= 39.0
      THEN 3
      WHEN tempc_min <= 31.9
      THEN 3
      WHEN tempc_min <= 33.9
      THEN 2
      WHEN tempc_max > 38.4
      THEN 1
      WHEN tempc_min < 36.0
      THEN 1
      WHEN tempc_max >= 36.0 AND tempc_max <= 38.4 AND tempc_min >= 36.0 AND tempc_min <= 38.4
      THEN 0
    END AS temp_score,
    CASE
      WHEN resprate_min IS NULL
      THEN NULL
      WHEN resprate_max >= 50
      THEN 4
      WHEN resprate_min < 6
      THEN 4
      WHEN resprate_max >= 35
      THEN 3
      WHEN resprate_min <= 9
      THEN 2
      WHEN resprate_max >= 25
      THEN 1
      WHEN resprate_min <= 11
      THEN 1
      WHEN resprate_max >= 12
      AND resprate_max <= 24
      AND resprate_min >= 12
      AND resprate_min <= 24
      THEN 0
    END AS resp_score,
    CASE
      WHEN COALESCE(mechvent, cpap) IS NULL
      THEN NULL
      WHEN cpap = 1
      THEN 3
      WHEN mechvent = 1
      THEN 3
      ELSE 0
    END AS vent_score,
    CASE
      WHEN UrineOutput IS NULL
      THEN NULL
      WHEN UrineOutput > 5000.0
      THEN 2
      WHEN UrineOutput >= 3500.0
      THEN 1
      WHEN UrineOutput >= 700.0
      THEN 0
      WHEN UrineOutput >= 500.0
      THEN 2
      WHEN UrineOutput >= 200.0
      THEN 3
      WHEN UrineOutput < 200.0
      THEN 4
    END AS uo_score,
    CASE
      WHEN bun_max IS NULL
      THEN NULL
      WHEN bun_max >= 55.0
      THEN 4
      WHEN bun_max >= 36.0
      THEN 3
      WHEN bun_max >= 29.0
      THEN 2
      WHEN bun_max >= 7.50
      THEN 1
      WHEN bun_min < 3.5
      THEN 1
      WHEN bun_max >= 3.5 AND bun_max < 7.5 AND bun_min >= 3.5 AND bun_min < 7.5
      THEN 0
    END AS bun_score,
    CASE
      WHEN hematocrit_max IS NULL
      THEN NULL
      WHEN hematocrit_max >= 60.0
      THEN 4
      WHEN hematocrit_min < 20.0
      THEN 4
      WHEN hematocrit_max >= 50.0
      THEN 2
      WHEN hematocrit_min < 30.0
      THEN 2
      WHEN hematocrit_max >= 46.0
      THEN 1
      WHEN hematocrit_max >= 30.0
      AND hematocrit_max < 46.0
      AND hematocrit_min >= 30.0
      AND hematocrit_min < 46.0
      THEN 0
    END AS hematocrit_score,
    CASE
      WHEN wbc_max IS NULL
      THEN NULL
      WHEN wbc_max >= 40.0
      THEN 4
      WHEN wbc_min < 1.0
      THEN 4
      WHEN wbc_max >= 20.0
      THEN 2
      WHEN wbc_min < 3.0
      THEN 2
      WHEN wbc_max >= 15.0
      THEN 1
      WHEN wbc_max >= 3.0 AND wbc_max < 15.0 AND wbc_min >= 3.0 AND wbc_min < 15.0
      THEN 0
    END AS wbc_score,
    CASE
      WHEN glucose_max IS NULL
      THEN NULL
      WHEN glucose_max >= 44.5
      THEN 4
      WHEN glucose_min < 1.6
      THEN 4
      WHEN glucose_max >= 27.8
      THEN 3
      WHEN glucose_min < 2.8
      THEN 3
      WHEN glucose_min < 3.9
      THEN 2
      WHEN glucose_max >= 14.0
      THEN 1
      WHEN glucose_max >= 3.9
      AND glucose_max < 14.0
      AND glucose_min >= 3.9
      AND glucose_min < 14.0
      THEN 0
    END AS glucose_score,
    CASE
      WHEN potassium_max IS NULL
      THEN NULL
      WHEN potassium_max >= 7.0
      THEN 4
      WHEN potassium_min < 2.5
      THEN 4
      WHEN potassium_max >= 6.0
      THEN 3
      WHEN potassium_min < 3.0
      THEN 2
      WHEN potassium_max >= 5.5
      THEN 1
      WHEN potassium_min < 3.5
      THEN 1
      WHEN potassium_max >= 3.5
      AND potassium_max < 5.5
      AND potassium_min >= 3.5
      AND potassium_min < 5.5
      THEN 0
    END AS potassium_score,
    CASE
      WHEN sodium_max IS NULL
      THEN NULL
      WHEN sodium_max >= 180
      THEN 4
      WHEN sodium_min < 110
      THEN 4
      WHEN sodium_max >= 161
      THEN 3
      WHEN sodium_min < 120
      THEN 3
      WHEN sodium_max >= 156
      THEN 2
      WHEN sodium_min < 130
      THEN 2
      WHEN sodium_max >= 151
      THEN 1
      WHEN sodium_max >= 130 AND sodium_max < 151 AND sodium_min >= 130 AND sodium_min < 151
      THEN 0
    END AS sodium_score,
    CASE
      WHEN bicarbonate_max IS NULL
      THEN NULL
      WHEN bicarbonate_min < 5.0
      THEN 4
      WHEN bicarbonate_max >= 40.0
      THEN 3
      WHEN bicarbonate_min < 10.0
      THEN 3
      WHEN bicarbonate_max >= 30.0
      THEN 1
      WHEN bicarbonate_min < 20.0
      THEN 1
      WHEN bicarbonate_max >= 20.0
      AND bicarbonate_max < 30.0
      AND bicarbonate_min >= 20.0
      AND bicarbonate_min < 30.0
      THEN 0
    END AS bicarbonate_score,
    CASE
      WHEN mingcs IS NULL
      THEN NULL
      WHEN mingcs < 3
      THEN NULL
      WHEN mingcs = 3
      THEN 4
      WHEN mingcs < 7
      THEN 3
      WHEN mingcs < 10
      THEN 2
      WHEN mingcs < 13
      THEN 1
      WHEN mingcs >= 13 AND mingcs <= 15
      THEN 0
    END AS gcs_score
  FROM cohort
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  COALESCE(age_score, 0) + COALESCE(hr_score, 0) + COALESCE(sysbp_score, 0) + COALESCE(resp_score, 0) + COALESCE(temp_score, 0) + COALESCE(uo_score, 0) + COALESCE(vent_score, 0) + COALESCE(bun_score, 0) + COALESCE(hematocrit_score, 0) + COALESCE(wbc_score, 0) + COALESCE(glucose_score, 0) + COALESCE(potassium_score, 0) + COALESCE(sodium_score, 0) + COALESCE(bicarbonate_score, 0) + COALESCE(gcs_score, 0) AS SAPS,
  age_score,
  hr_score,
  sysbp_score,
  resp_score,
  temp_score,
  uo_score,
  vent_score,
  bun_score,
  hematocrit_score,
  wbc_score,
  glucose_score,
  potassium_score,
  sodium_score,
  bicarbonate_score,
  gcs_score
FROM mimiciii.icustays AS ie
LEFT JOIN scorecomp AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST