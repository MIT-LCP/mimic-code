-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.sapsii; CREATE TABLE mimiciv_derived.sapsii AS
WITH co AS (
  SELECT
    subject_id,
    hadm_id,
    stay_id,
    intime AS starttime,
    intime + INTERVAL '24' HOUR AS endtime
  FROM mimiciv_icu.icustays
), cpap AS (
  SELECT
    co.subject_id,
    co.stay_id,
    GREATEST(MIN(charttime - INTERVAL '1' HOUR), co.starttime) AS starttime,
    LEAST(MAX(charttime + INTERVAL '4' HOUR), co.endtime) AS endtime,
    MAX(CASE WHEN REGEXP_MATCHES(LOWER(ce.value), '(cpap mask|bipap)') THEN 1 ELSE 0 END) AS cpap
  FROM co
  INNER JOIN mimiciv_icu.chartevents AS ce
    ON co.stay_id = ce.stay_id
    AND ce.charttime > co.starttime
    AND ce.charttime <= co.endtime
  WHERE
    ce.itemid = 226732 AND REGEXP_MATCHES(LOWER(ce.value), '(cpap mask|bipap)')
  GROUP BY
    co.subject_id,
    co.stay_id,
    co.starttime,
    co.endtime
), surgflag AS (
  SELECT
    adm.hadm_id,
    CASE WHEN LOWER(curr_service) LIKE '%surg%' THEN 1 ELSE 0 END AS surgical,
    ROW_NUMBER() OVER (PARTITION BY adm.hadm_id ORDER BY transfertime NULLS FIRST) AS serviceorder
  FROM mimiciv_hosp.admissions AS adm
  LEFT JOIN mimiciv_hosp.services AS se
    ON adm.hadm_id = se.hadm_id
), comorb AS (
  SELECT
    hadm_id,
    MAX(
      CASE
        WHEN icd_version = 9 AND SUBSTR(icd_code, 1, 3) BETWEEN '042' AND '044'
        THEN 1
        WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) BETWEEN 'B20' AND 'B22'
        THEN 1
        WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) = 'B24'
        THEN 1
        ELSE 0
      END
    ) AS aids,
    MAX(
      CASE
        WHEN icd_version = 9
        THEN CASE
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20000' AND '20238'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20240' AND '20248'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20250' AND '20302'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20310' AND '20312'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20302' AND '20382'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20400' AND '20522'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20580' AND '20702'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20720' AND '20892'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 4) IN ('2386', '2733')
          THEN 1
          ELSE 0
        END
        WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) BETWEEN 'C81' AND 'C96'
        THEN 1
        ELSE 0
      END
    ) AS hem,
    MAX(
      CASE
        WHEN icd_version = 9
        THEN CASE
          WHEN SUBSTR(icd_code, 1, 4) BETWEEN '1960' AND '1991'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) BETWEEN '20970' AND '20975'
          THEN 1
          WHEN SUBSTR(icd_code, 1, 5) IN ('20979', '78951')
          THEN 1
          ELSE 0
        END
        WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 3) BETWEEN 'C77' AND 'C79'
        THEN 1
        WHEN icd_version = 10 AND SUBSTR(icd_code, 1, 4) = 'C800'
        THEN 1
        ELSE 0
      END
    ) AS mets
  FROM mimiciv_hosp.diagnoses_icd
  GROUP BY
    hadm_id
), pafi1 AS (
  SELECT
    co.stay_id,
    bg.charttime,
    pao2fio2ratio AS pao2fio2,
    CASE WHEN NOT vd.stay_id IS NULL THEN 1 ELSE 0 END AS vent,
    CASE WHEN NOT cp.subject_id IS NULL THEN 1 ELSE 0 END AS cpap
  FROM co
  LEFT JOIN mimiciv_derived.bg AS bg
    ON co.subject_id = bg.subject_id
    AND bg.specimen = 'ART.'
    AND bg.charttime > co.starttime
    AND bg.charttime <= co.endtime
  LEFT JOIN mimiciv_derived.ventilation AS vd
    ON co.stay_id = vd.stay_id
    AND bg.charttime > vd.starttime
    AND bg.charttime <= vd.endtime
    AND vd.ventilation_status = 'InvasiveVent'
  LEFT JOIN cpap AS cp
    ON bg.subject_id = cp.subject_id
    AND bg.charttime > cp.starttime
    AND bg.charttime <= cp.endtime
), pafi2 AS (
  SELECT
    stay_id,
    MIN(pao2fio2) AS pao2fio2_vent_min
  FROM pafi1
  WHERE
    vent = 1 OR cpap = 1
  GROUP BY
    stay_id
), gcs AS (
  SELECT
    co.stay_id,
    MIN(gcs.gcs) AS mingcs
  FROM co
  LEFT JOIN mimiciv_derived.gcs AS gcs
    ON co.stay_id = gcs.stay_id
    AND co.starttime < gcs.charttime
    AND gcs.charttime <= co.endtime
  GROUP BY
    co.stay_id
), vital AS (
  SELECT
    co.stay_id,
    MIN(vital.heart_rate) AS heartrate_min,
    MAX(vital.heart_rate) AS heartrate_max,
    MIN(vital.sbp) AS sysbp_min,
    MAX(vital.sbp) AS sysbp_max,
    MIN(vital.temperature) AS tempc_min,
    MAX(vital.temperature) AS tempc_max
  FROM co
  LEFT JOIN mimiciv_derived.vitalsign AS vital
    ON co.subject_id = vital.subject_id
    AND co.starttime < vital.charttime
    AND co.endtime >= vital.charttime
  GROUP BY
    co.stay_id
), uo AS (
  SELECT
    co.stay_id,
    SUM(uo.urineoutput) AS urineoutput
  FROM co
  LEFT JOIN mimiciv_derived.urine_output AS uo
    ON co.stay_id = uo.stay_id
    AND co.starttime < uo.charttime
    AND co.endtime >= uo.charttime
  GROUP BY
    co.stay_id
), labs AS (
  SELECT
    co.stay_id,
    MIN(labs.bun) AS bun_min,
    MAX(labs.bun) AS bun_max,
    MIN(labs.potassium) AS potassium_min,
    MAX(labs.potassium) AS potassium_max,
    MIN(labs.sodium) AS sodium_min,
    MAX(labs.sodium) AS sodium_max,
    MIN(labs.bicarbonate) AS bicarbonate_min,
    MAX(labs.bicarbonate) AS bicarbonate_max
  FROM co
  LEFT JOIN mimiciv_derived.chemistry AS labs
    ON co.subject_id = labs.subject_id
    AND co.starttime < labs.charttime
    AND co.endtime >= labs.charttime
  GROUP BY
    co.stay_id
), cbc AS (
  SELECT
    co.stay_id,
    MIN(cbc.wbc) AS wbc_min,
    MAX(cbc.wbc) AS wbc_max
  FROM co
  LEFT JOIN mimiciv_derived.complete_blood_count AS cbc
    ON co.subject_id = cbc.subject_id
    AND co.starttime < cbc.charttime
    AND co.endtime >= cbc.charttime
  GROUP BY
    co.stay_id
), enz AS (
  SELECT
    co.stay_id,
    MIN(enz.bilirubin_total) AS bilirubin_min,
    MAX(enz.bilirubin_total) AS bilirubin_max
  FROM co
  LEFT JOIN mimiciv_derived.enzyme AS enz
    ON co.subject_id = enz.subject_id
    AND co.starttime < enz.charttime
    AND co.endtime >= enz.charttime
  GROUP BY
    co.stay_id
), cohort AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.stay_id,
    ie.intime,
    ie.outtime,
    va.age,
    co.starttime,
    co.endtime,
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
    cbc.wbc_min,
    cbc.wbc_max,
    labs.potassium_min,
    labs.potassium_max,
    labs.sodium_min,
    labs.sodium_max,
    labs.bicarbonate_min,
    labs.bicarbonate_max,
    enz.bilirubin_min,
    enz.bilirubin_max,
    gcs.mingcs,
    comorb.aids,
    comorb.hem,
    comorb.mets,
    CASE
      WHEN adm.admission_type = 'ELECTIVE' AND sf.surgical = 1
      THEN 'ScheduledSurgical'
      WHEN adm.admission_type <> 'ELECTIVE' AND sf.surgical = 1
      THEN 'UnscheduledSurgical'
      ELSE 'Medical'
    END AS admissiontype
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_hosp.admissions AS adm
    ON ie.hadm_id = adm.hadm_id
  LEFT JOIN mimiciv_derived.age AS va
    ON ie.hadm_id = va.hadm_id
  INNER JOIN co
    ON ie.stay_id = co.stay_id
  LEFT JOIN pafi2 AS pf
    ON ie.stay_id = pf.stay_id
  LEFT JOIN surgflag AS sf
    ON adm.hadm_id = sf.hadm_id AND sf.serviceorder = 1
  LEFT JOIN comorb
    ON ie.hadm_id = comorb.hadm_id
  LEFT JOIN gcs AS gcs
    ON ie.stay_id = gcs.stay_id
  LEFT JOIN vital
    ON ie.stay_id = vital.stay_id
  LEFT JOIN uo
    ON ie.stay_id = uo.stay_id
  LEFT JOIN labs
    ON ie.stay_id = labs.stay_id
  LEFT JOIN cbc
    ON ie.stay_id = cbc.stay_id
  LEFT JOIN enz
    ON ie.stay_id = enz.stay_id
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
      WHEN tempc_max >= 39.0
      THEN 3
      WHEN tempc_min < 39.0
      THEN 0
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
  s.subject_id,
  s.hadm_id,
  s.stay_id,
  s.starttime,
  s.endtime,
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
FROM score AS s