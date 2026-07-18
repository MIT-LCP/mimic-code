-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.sapsii; CREATE TABLE mimiciii_derived.sapsii AS
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
), surgflag AS (
  SELECT
    adm.hadm_id,
    CASE WHEN LOWER(curr_service) LIKE '%surg%' THEN 1 ELSE 0 END AS surgical,
    ROW_NUMBER() OVER (PARTITION BY adm.HADM_ID ORDER BY TRANSFERTIME NULLS FIRST) AS serviceOrder
  FROM mimiciii.admissions AS adm
  LEFT JOIN mimiciii.services AS se
    ON adm.hadm_id = se.hadm_id
), comorb AS (
  SELECT
    hadm_id,
    MAX(CASE WHEN SUBSTRING(icd9_code, 1, 3) BETWEEN '042' AND '044' THEN 1 END) AS aids,
    MAX(
      CASE
        WHEN icd9_code BETWEEN '20000' AND '20238'
        THEN 1
        WHEN icd9_code BETWEEN '20240' AND '20248'
        THEN 1
        WHEN icd9_code BETWEEN '20250' AND '20302'
        THEN 1
        WHEN icd9_code BETWEEN '20310' AND '20312'
        THEN 1
        WHEN icd9_code BETWEEN '20302' AND '20382'
        THEN 1
        WHEN icd9_code BETWEEN '20400' AND '20522'
        THEN 1
        WHEN icd9_code BETWEEN '20580' AND '20702'
        THEN 1
        WHEN icd9_code BETWEEN '20720' AND '20892'
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 4) = '2386'
        THEN 1
        WHEN SUBSTRING(icd9_code, 1, 4) = '2733'
        THEN 1
      END
    ) AS hem,
    MAX(
      CASE
        WHEN SUBSTRING(icd9_code, 1, 4) BETWEEN '1960' AND '1991'
        THEN 1
        WHEN icd9_code BETWEEN '20970' AND '20975'
        THEN 1
        WHEN icd9_code = '20979'
        THEN 1
        WHEN icd9_code = '78951'
        THEN 1
      END
    ) AS mets
  FROM mimiciii.diagnoses_icd
  GROUP BY
    hadm_id
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
    DATE_DIFF('YEAR', pat.dob, ie.intime) AS age,
    vital.heartrate_max,
    vital.heartrate_min,
    vital.sysbp_max,
    vital.sysbp_min,
    vital.tempc_max,
    vital.tempc_min,
    pf.pao2fio2_vent_min,
    uo.urineoutput,
    labs.bun_min,
    labs.bun_max,
    labs.wbc_min,
    labs.wbc_max,
    labs.potassium_min,
    labs.potassium_max,
    labs.sodium_min,
    labs.sodium_max,
    labs.bicarbonate_min,
    labs.bicarbonate_max,
    labs.bilirubin_min,
    labs.bilirubin_max,
    gcs.mingcs,
    comorb.aids,
    comorb.hem,
    comorb.mets,
    CASE
      WHEN adm.ADMISSION_TYPE = 'ELECTIVE' AND sf.surgical = 1
      THEN 'ScheduledSurgical'
      WHEN adm.ADMISSION_TYPE <> 'ELECTIVE' AND sf.surgical = 1
      THEN 'UnscheduledSurgical'
      ELSE 'Medical'
    END AS admissiontype
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.admissions AS adm
    ON ie.hadm_id = adm.hadm_id
  INNER JOIN mimiciii.patients AS pat
    ON ie.subject_id = pat.subject_id
  LEFT JOIN pafi2 AS pf
    ON ie.icustay_id = pf.icustay_id
  LEFT JOIN surgflag AS sf
    ON adm.hadm_id = sf.hadm_id AND sf.serviceOrder = 1
  LEFT JOIN comorb
    ON ie.hadm_id = comorb.hadm_id
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
      WHEN age IS NULL
      THEN NULL
      WHEN age < 40
      THEN 0
      WHEN age < 60
      THEN 7
      WHEN age < 70
      THEN 12
      WHEN age < 75
      THEN 15
      WHEN age < 80
      THEN 16
      WHEN age >= 80
      THEN 18
    END AS age_score,
    CASE
      WHEN heartrate_max IS NULL
      THEN NULL
      WHEN heartrate_min < 40
      THEN 11
      WHEN heartrate_max >= 160
      THEN 7
      WHEN heartrate_max >= 120
      THEN 4
      WHEN heartrate_min < 70
      THEN 2
      WHEN heartrate_max >= 70
      AND heartrate_max < 120
      AND heartrate_min >= 70
      AND heartrate_min < 120
      THEN 0
    END AS hr_score,
    CASE
      WHEN sysbp_min IS NULL
      THEN NULL
      WHEN sysbp_min < 70
      THEN 13
      WHEN sysbp_min < 100
      THEN 5
      WHEN sysbp_max >= 200
      THEN 2
      WHEN sysbp_max >= 100 AND sysbp_max < 200 AND sysbp_min >= 100 AND sysbp_min < 200
      THEN 0
    END AS sysbp_score,
    CASE
      WHEN tempc_max IS NULL
      THEN NULL
      WHEN tempc_min < 39.0
      THEN 0
      WHEN tempc_max >= 39.0
      THEN 3
    END AS temp_score,
    CASE
      WHEN pao2fio2_vent_min IS NULL
      THEN NULL
      WHEN pao2fio2_vent_min < 100
      THEN 11
      WHEN pao2fio2_vent_min < 200
      THEN 9
      WHEN pao2fio2_vent_min >= 200
      THEN 6
    END AS pao2fio2_score,
    CASE
      WHEN urineoutput IS NULL
      THEN NULL
      WHEN urineoutput < 500.0
      THEN 11
      WHEN urineoutput < 1000.0
      THEN 4
      WHEN urineoutput >= 1000.0
      THEN 0
    END AS uo_score,
    CASE
      WHEN bun_max IS NULL
      THEN NULL
      WHEN bun_max < 28.0
      THEN 0
      WHEN bun_max < 84.0
      THEN 6
      WHEN bun_max >= 84.0
      THEN 10
    END AS bun_score,
    CASE
      WHEN wbc_max IS NULL
      THEN NULL
      WHEN wbc_min < 1.0
      THEN 12
      WHEN wbc_max >= 20.0
      THEN 3
      WHEN wbc_max >= 1.0 AND wbc_max < 20.0 AND wbc_min >= 1.0 AND wbc_min < 20.0
      THEN 0
    END AS wbc_score,
    CASE
      WHEN potassium_max IS NULL
      THEN NULL
      WHEN potassium_min < 3.0
      THEN 3
      WHEN potassium_max >= 5.0
      THEN 3
      WHEN potassium_max >= 3.0
      AND potassium_max < 5.0
      AND potassium_min >= 3.0
      AND potassium_min < 5.0
      THEN 0
    END AS potassium_score,
    CASE
      WHEN sodium_max IS NULL
      THEN NULL
      WHEN sodium_min < 125
      THEN 5
      WHEN sodium_max >= 145
      THEN 1
      WHEN sodium_max >= 125 AND sodium_max < 145 AND sodium_min >= 125 AND sodium_min < 145
      THEN 0
    END AS sodium_score,
    CASE
      WHEN bicarbonate_max IS NULL
      THEN NULL
      WHEN bicarbonate_min < 15.0
      THEN 6
      WHEN bicarbonate_min < 20.0
      THEN 3
      WHEN bicarbonate_max >= 20.0 AND bicarbonate_min >= 20.0
      THEN 0
    END AS bicarbonate_score,
    CASE
      WHEN bilirubin_max IS NULL
      THEN NULL
      WHEN bilirubin_max < 4.0
      THEN 0
      WHEN bilirubin_max < 6.0
      THEN 4
      WHEN bilirubin_max >= 6.0
      THEN 9
    END AS bilirubin_score,
    CASE
      WHEN mingcs IS NULL
      THEN NULL
      WHEN mingcs < 3
      THEN NULL
      WHEN mingcs < 6
      THEN 26
      WHEN mingcs < 9
      THEN 13
      WHEN mingcs < 11
      THEN 7
      WHEN mingcs < 14
      THEN 5
      WHEN mingcs >= 14 AND mingcs <= 15
      THEN 0
    END AS gcs_score,
    CASE WHEN aids = 1 THEN 17 WHEN hem = 1 THEN 10 WHEN mets = 1 THEN 9 ELSE 0 END AS comorbidity_score,
    CASE
      WHEN admissiontype = 'ScheduledSurgical'
      THEN 0
      WHEN admissiontype = 'Medical'
      THEN 6
      WHEN admissiontype = 'UnscheduledSurgical'
      THEN 8
      ELSE NULL
    END AS admissiontype_score
  FROM cohort
), score AS (
  SELECT
    s.*,
    COALESCE(age_score, 0) + COALESCE(hr_score, 0) + COALESCE(sysbp_score, 0) + COALESCE(temp_score, 0) + COALESCE(pao2fio2_score, 0) + COALESCE(uo_score, 0) + COALESCE(bun_score, 0) + COALESCE(wbc_score, 0) + COALESCE(potassium_score, 0) + COALESCE(sodium_score, 0) + COALESCE(bicarbonate_score, 0) + COALESCE(bilirubin_score, 0) + COALESCE(gcs_score, 0) + COALESCE(comorbidity_score, 0) + COALESCE(admissiontype_score, 0) AS sapsii
  FROM scorecomp AS s
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  sapsii,
  1 / (
    1 + EXP(-(
      -7.7631 + 0.0737 * (
        sapsii
      ) + 0.9971 * (
        LN(sapsii + 1)
      )
    ))
  ) AS sapsii_prob,
  age_score,
  hr_score,
  sysbp_score,
  temp_score,
  pao2fio2_score,
  uo_score,
  bun_score,
  wbc_score,
  potassium_score,
  sodium_score,
  bicarbonate_score,
  bilirubin_score,
  gcs_score,
  comorbidity_score,
  admissiontype_score
FROM mimiciii.icustays AS ie
LEFT JOIN score AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST