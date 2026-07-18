-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.apsiii; CREATE TABLE mimiciii_derived.apsiii AS
WITH pa AS (
  SELECT
    bg.icustay_id,
    bg.charttime,
    po2 AS PaO2,
    ROW_NUMBER() OVER (PARTITION BY bg.icustay_id ORDER BY bg.po2 DESC) AS rn
  FROM mimiciii_derived.blood_gas_first_day_arterial AS bg
  LEFT JOIN mimiciii_derived.ventilation_durations AS vd
    ON bg.icustay_id = vd.icustay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
  WHERE
    vd.icustay_id IS NULL
    AND COALESCE(fio2, fio2_chartevents, 21) < 50
    AND NOT bg.po2 IS NULL
), aa AS (
  SELECT
    bg.icustay_id,
    bg.charttime,
    bg.aado2,
    ROW_NUMBER() OVER (PARTITION BY bg.icustay_id ORDER BY bg.aado2 DESC) AS rn
  FROM mimiciii_derived.blood_gas_first_day_arterial AS bg
  INNER JOIN mimiciii_derived.ventilation_durations AS vd
    ON bg.icustay_id = vd.icustay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
  WHERE
    NOT vd.icustay_id IS NULL
    AND COALESCE(fio2, fio2_chartevents) >= 50
    AND NOT bg.aado2 IS NULL
), acidbase AS (
  SELECT
    bg.icustay_id,
    ph,
    pco2 AS paco2,
    CASE
      WHEN ph IS NULL OR pco2 IS NULL
      THEN NULL
      WHEN ph < 7.20
      THEN CASE WHEN pco2 < 50 THEN 12 ELSE 4 END
      WHEN ph < 7.30
      THEN CASE WHEN pco2 < 30 THEN 9 WHEN pco2 < 40 THEN 6 WHEN pco2 < 50 THEN 3 ELSE 2 END
      WHEN ph < 7.35
      THEN CASE WHEN pco2 < 30 THEN 9 WHEN pco2 < 45 THEN 0 ELSE 1 END
      WHEN ph < 7.45
      THEN CASE WHEN pco2 < 30 THEN 5 WHEN pco2 < 45 THEN 0 ELSE 1 END
      WHEN ph < 7.50
      THEN CASE WHEN pco2 < 30 THEN 5 WHEN pco2 < 35 THEN 0 WHEN pco2 < 45 THEN 2 ELSE 12 END
      WHEN ph < 7.60
      THEN CASE WHEN pco2 < 40 THEN 3 ELSE 12 END
      ELSE CASE WHEN pco2 < 25 THEN 0 WHEN pco2 < 40 THEN 3 ELSE 12 END
    END AS acidbase_score
  FROM mimiciii_derived.blood_gas_first_day_arterial AS bg
  WHERE
    NOT ph IS NULL AND NOT pco2 IS NULL
), acidbase_max AS (
  SELECT
    icustay_id,
    acidbase_score,
    ph,
    paco2,
    ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY acidbase_score DESC) AS acidbase_rn
  FROM acidbase
), arf AS (
  SELECT
    ie.icustay_id,
    CASE
      WHEN labs.creatinine_max >= 1.5 AND uo.urineoutput < 410 AND icd.ckd = 0
      THEN 1
      ELSE 0
    END AS arf
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii_derived.urine_output_first_day AS uo
    ON ie.icustay_id = uo.icustay_id
  LEFT JOIN mimiciii_derived.labs_first_day AS labs
    ON ie.icustay_id = labs.icustay_id
  LEFT JOIN (
    SELECT
      hadm_id,
      MAX(CASE WHEN icd9_code IN ('5854', '5855', '5856') THEN 1 ELSE 0 END) AS ckd
    FROM mimiciii.diagnoses_icd
    GROUP BY
      hadm_id
  ) AS icd
    ON ie.hadm_id = icd.hadm_id
), cohort AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
    ie.intime,
    ie.outtime,
    vital.heartrate_min,
    vital.heartrate_max,
    vital.meanbp_min,
    vital.meanbp_max,
    vital.tempc_min,
    vital.tempc_max,
    vital.resprate_min,
    vital.resprate_max,
    pa.pao2,
    aa.aado2,
    ab.ph,
    ab.paco2,
    ab.acidbase_score,
    labs.hematocrit_min,
    labs.hematocrit_max,
    labs.wbc_min,
    labs.wbc_max,
    labs.creatinine_min,
    labs.creatinine_max,
    labs.bun_min,
    labs.bun_max,
    labs.sodium_min,
    labs.sodium_max,
    labs.albumin_min,
    labs.albumin_max,
    labs.bilirubin_min,
    labs.bilirubin_max,
    CASE
      WHEN labs.glucose_max IS NULL AND vital.glucose_max IS NULL
      THEN NULL
      WHEN labs.glucose_max IS NULL OR vital.glucose_max > labs.glucose_max
      THEN vital.glucose_max
      WHEN vital.glucose_max IS NULL OR labs.glucose_max > vital.glucose_max
      THEN labs.glucose_max
      ELSE labs.glucose_max
    END AS glucose_max,
    CASE
      WHEN labs.glucose_min IS NULL AND vital.glucose_min IS NULL
      THEN NULL
      WHEN labs.glucose_min IS NULL OR vital.glucose_min < labs.glucose_min
      THEN vital.glucose_min
      WHEN vital.glucose_min IS NULL OR labs.glucose_min < vital.glucose_min
      THEN labs.glucose_min
      ELSE labs.glucose_min
    END AS glucose_min,
    vent.vent,
    uo.urineoutput,
    gcs.mingcs,
    gcs.gcsmotor,
    gcs.gcsverbal,
    gcs.gcseyes,
    gcs.endotrachflag,
    arf.arf AS arf
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.admissions AS adm
    ON ie.hadm_id = adm.hadm_id
  INNER JOIN mimiciii.patients AS pat
    ON ie.subject_id = pat.subject_id
  LEFT JOIN pa
    ON ie.icustay_id = pa.icustay_id AND pa.rn = 1
  LEFT JOIN aa
    ON ie.icustay_id = aa.icustay_id AND aa.rn = 1
  LEFT JOIN acidbase_max AS ab
    ON ie.icustay_id = ab.icustay_id AND ab.acidbase_rn = 1
  LEFT JOIN arf
    ON ie.icustay_id = arf.icustay_id
  LEFT JOIN mimiciii_derived.ventilation_first_day AS vent
    ON ie.icustay_id = vent.icustay_id
  LEFT JOIN mimiciii_derived.gcs_first_day AS gcs
    ON ie.icustay_id = gcs.icustay_id
  LEFT JOIN mimiciii_derived.vitals_first_day AS vital
    ON ie.icustay_id = vital.icustay_id
  LEFT JOIN mimiciii_derived.urine_output_first_day AS uo
    ON ie.icustay_id = uo.icustay_id
  LEFT JOIN mimiciii_derived.labs_first_day AS labs
    ON ie.icustay_id = labs.icustay_id
), score_min AS (
  SELECT
    cohort.subject_id,
    cohort.hadm_id,
    cohort.icustay_id,
    CASE
      WHEN heartrate_min IS NULL
      THEN NULL
      WHEN heartrate_min < 40
      THEN 8
      WHEN heartrate_min < 50
      THEN 5
      WHEN heartrate_min < 100
      THEN 0
      WHEN heartrate_min < 110
      THEN 1
      WHEN heartrate_min < 120
      THEN 5
      WHEN heartrate_min < 140
      THEN 7
      WHEN heartrate_min < 155
      THEN 13
      WHEN heartrate_min >= 155
      THEN 17
    END AS hr_score,
    CASE
      WHEN meanbp_min IS NULL
      THEN NULL
      WHEN meanbp_min < 40
      THEN 23
      WHEN meanbp_min < 60
      THEN 15
      WHEN meanbp_min < 70
      THEN 7
      WHEN meanbp_min < 80
      THEN 6
      WHEN meanbp_min < 100
      THEN 0
      WHEN meanbp_min < 120
      THEN 4
      WHEN meanbp_min < 130
      THEN 7
      WHEN meanbp_min < 140
      THEN 9
      WHEN meanbp_min >= 140
      THEN 10
    END AS meanbp_score,
    CASE
      WHEN tempc_min IS NULL
      THEN NULL
      WHEN tempc_min < 33.0
      THEN 20
      WHEN tempc_min < 33.5
      THEN 16
      WHEN tempc_min < 34.0
      THEN 13
      WHEN tempc_min < 35.0
      THEN 8
      WHEN tempc_min < 36.0
      THEN 2
      WHEN tempc_min < 40.0
      THEN 0
      WHEN tempc_min >= 40.0
      THEN 4
    END AS temp_score,
    CASE
      WHEN resprate_min IS NULL
      THEN NULL
      WHEN vent = 1 AND resprate_min < 14
      THEN 0
      WHEN resprate_min < 6
      THEN 17
      WHEN resprate_min < 12
      THEN 8
      WHEN resprate_min < 14
      THEN 7
      WHEN resprate_min < 25
      THEN 0
      WHEN resprate_min < 35
      THEN 6
      WHEN resprate_min < 40
      THEN 9
      WHEN resprate_min < 50
      THEN 11
      WHEN resprate_min >= 50
      THEN 18
    END AS resprate_score,
    CASE
      WHEN hematocrit_min IS NULL
      THEN NULL
      WHEN hematocrit_min < 41.0
      THEN 3
      WHEN hematocrit_min < 50.0
      THEN 0
      WHEN hematocrit_min >= 50.0
      THEN 3
    END AS hematocrit_score,
    CASE
      WHEN wbc_min IS NULL
      THEN NULL
      WHEN wbc_min < 1.0
      THEN 19
      WHEN wbc_min < 3.0
      THEN 5
      WHEN wbc_min < 20.0
      THEN 0
      WHEN wbc_min < 25.0
      THEN 1
      WHEN wbc_min >= 25.0
      THEN 5
    END AS wbc_score,
    CASE
      WHEN creatinine_min IS NULL
      THEN NULL
      WHEN arf = 1 AND creatinine_min < 1.5
      THEN 0
      WHEN arf = 1 AND creatinine_min >= 1.5
      THEN 10
      WHEN creatinine_min < 0.5
      THEN 3
      WHEN creatinine_min < 1.5
      THEN 0
      WHEN creatinine_min < 1.95
      THEN 4
      WHEN creatinine_min >= 1.95
      THEN 7
    END AS creatinine_score,
    CASE
      WHEN bun_min IS NULL
      THEN NULL
      WHEN bun_min < 17.0
      THEN 0
      WHEN bun_min < 20.0
      THEN 2
      WHEN bun_min < 40.0
      THEN 7
      WHEN bun_min < 80.0
      THEN 11
      WHEN bun_min >= 80.0
      THEN 12
    END AS bun_score,
    CASE
      WHEN sodium_min IS NULL
      THEN NULL
      WHEN sodium_min < 120
      THEN 3
      WHEN sodium_min < 135
      THEN 2
      WHEN sodium_min < 155
      THEN 0
      WHEN sodium_min >= 155
      THEN 4
    END AS sodium_score,
    CASE
      WHEN albumin_min IS NULL
      THEN NULL
      WHEN albumin_min < 2.0
      THEN 11
      WHEN albumin_min < 2.5
      THEN 6
      WHEN albumin_min < 4.5
      THEN 0
      WHEN albumin_min >= 4.5
      THEN 4
    END AS albumin_score,
    CASE
      WHEN bilirubin_min IS NULL
      THEN NULL
      WHEN bilirubin_min < 2.0
      THEN 0
      WHEN bilirubin_min < 3.0
      THEN 5
      WHEN bilirubin_min < 5.0
      THEN 6
      WHEN bilirubin_min < 8.0
      THEN 8
      WHEN bilirubin_min >= 8.0
      THEN 16
    END AS bilirubin_score,
    CASE
      WHEN glucose_min IS NULL
      THEN NULL
      WHEN glucose_min < 40
      THEN 8
      WHEN glucose_min < 60
      THEN 9
      WHEN glucose_min < 200
      THEN 0
      WHEN glucose_min < 350
      THEN 3
      WHEN glucose_min >= 350
      THEN 5
    END AS glucose_score
  FROM cohort
), score_max AS (
  SELECT
    cohort.subject_id,
    cohort.hadm_id,
    cohort.icustay_id,
    CASE
      WHEN heartrate_max IS NULL
      THEN NULL
      WHEN heartrate_max < 40
      THEN 8
      WHEN heartrate_max < 50
      THEN 5
      WHEN heartrate_max < 100
      THEN 0
      WHEN heartrate_max < 110
      THEN 1
      WHEN heartrate_max < 120
      THEN 5
      WHEN heartrate_max < 140
      THEN 7
      WHEN heartrate_max < 155
      THEN 13
      WHEN heartrate_max >= 155
      THEN 17
    END AS hr_score,
    CASE
      WHEN meanbp_max IS NULL
      THEN NULL
      WHEN meanbp_max < 40
      THEN 23
      WHEN meanbp_max < 60
      THEN 15
      WHEN meanbp_max < 70
      THEN 7
      WHEN meanbp_max < 80
      THEN 6
      WHEN meanbp_max < 100
      THEN 0
      WHEN meanbp_max < 120
      THEN 4
      WHEN meanbp_max < 130
      THEN 7
      WHEN meanbp_max < 140
      THEN 9
      WHEN meanbp_max >= 140
      THEN 10
    END AS meanbp_score,
    CASE
      WHEN tempc_max IS NULL
      THEN NULL
      WHEN tempc_max < 33.0
      THEN 20
      WHEN tempc_max < 33.5
      THEN 16
      WHEN tempc_max < 34.0
      THEN 13
      WHEN tempc_max < 35.0
      THEN 8
      WHEN tempc_max < 36.0
      THEN 2
      WHEN tempc_max < 40.0
      THEN 0
      WHEN tempc_max >= 40.0
      THEN 4
    END AS temp_score,
    CASE
      WHEN resprate_max IS NULL
      THEN NULL
      WHEN vent = 1 AND resprate_max < 14
      THEN 0
      WHEN resprate_max < 6
      THEN 17
      WHEN resprate_max < 12
      THEN 8
      WHEN resprate_max < 14
      THEN 7
      WHEN resprate_max < 25
      THEN 0
      WHEN resprate_max < 35
      THEN 6
      WHEN resprate_max < 40
      THEN 9
      WHEN resprate_max < 50
      THEN 11
      WHEN resprate_max >= 50
      THEN 18
    END AS resprate_score,
    CASE
      WHEN hematocrit_max IS NULL
      THEN NULL
      WHEN hematocrit_max < 41.0
      THEN 3
      WHEN hematocrit_max < 50.0
      THEN 0
      WHEN hematocrit_max >= 50.0
      THEN 3
    END AS hematocrit_score,
    CASE
      WHEN wbc_max IS NULL
      THEN NULL
      WHEN wbc_max < 1.0
      THEN 19
      WHEN wbc_max < 3.0
      THEN 5
      WHEN wbc_max < 20.0
      THEN 0
      WHEN wbc_max < 25.0
      THEN 1
      WHEN wbc_max >= 25.0
      THEN 5
    END AS wbc_score,
    CASE
      WHEN creatinine_max IS NULL
      THEN NULL
      WHEN arf = 1 AND creatinine_max < 1.5
      THEN 0
      WHEN arf = 1 AND creatinine_max >= 1.5
      THEN 10
      WHEN creatinine_max < 0.5
      THEN 3
      WHEN creatinine_max < 1.5
      THEN 0
      WHEN creatinine_max < 1.95
      THEN 4
      WHEN creatinine_max >= 1.95
      THEN 7
    END AS creatinine_score,
    CASE
      WHEN bun_max IS NULL
      THEN NULL
      WHEN bun_max < 17.0
      THEN 0
      WHEN bun_max < 20.0
      THEN 2
      WHEN bun_max < 40.0
      THEN 7
      WHEN bun_max < 80.0
      THEN 11
      WHEN bun_max >= 80.0
      THEN 12
    END AS bun_score,
    CASE
      WHEN sodium_max IS NULL
      THEN NULL
      WHEN sodium_max < 120
      THEN 3
      WHEN sodium_max < 135
      THEN 2
      WHEN sodium_max < 155
      THEN 0
      WHEN sodium_max >= 155
      THEN 4
    END AS sodium_score,
    CASE
      WHEN albumin_max IS NULL
      THEN NULL
      WHEN albumin_max < 2.0
      THEN 11
      WHEN albumin_max < 2.5
      THEN 6
      WHEN albumin_max < 4.5
      THEN 0
      WHEN albumin_max >= 4.5
      THEN 4
    END AS albumin_score,
    CASE
      WHEN bilirubin_max IS NULL
      THEN NULL
      WHEN bilirubin_max < 2.0
      THEN 0
      WHEN bilirubin_max < 3.0
      THEN 5
      WHEN bilirubin_max < 5.0
      THEN 6
      WHEN bilirubin_max < 8.0
      THEN 8
      WHEN bilirubin_max >= 8.0
      THEN 16
    END AS bilirubin_score,
    CASE
      WHEN glucose_max IS NULL
      THEN NULL
      WHEN glucose_max < 40
      THEN 8
      WHEN glucose_max < 60
      THEN 9
      WHEN glucose_max < 200
      THEN 0
      WHEN glucose_max < 350
      THEN 3
      WHEN glucose_max >= 350
      THEN 5
    END AS glucose_score
  FROM cohort
), scorecomp AS (
  SELECT
    co.*,
    CASE
      WHEN heartrate_max IS NULL
      THEN NULL
      WHEN ABS(heartrate_max - 75) > ABS(heartrate_min - 75)
      THEN smax.hr_score
      WHEN ABS(heartrate_max - 75) < ABS(heartrate_min - 75)
      THEN smin.hr_score
      WHEN ABS(heartrate_max - 75) = ABS(heartrate_min - 75)
      AND smax.hr_score >= smin.hr_score
      THEN smax.hr_score
      WHEN ABS(heartrate_max - 75) = ABS(heartrate_min - 75)
      AND smax.hr_score < smin.hr_score
      THEN smin.hr_score
    END AS hr_score,
    CASE
      WHEN meanbp_max IS NULL
      THEN NULL
      WHEN ABS(meanbp_max - 90) > ABS(meanbp_min - 90)
      THEN smax.meanbp_score
      WHEN ABS(meanbp_max - 90) < ABS(meanbp_min - 90)
      THEN smin.meanbp_score
      WHEN ABS(meanbp_max - 90) = ABS(meanbp_min - 90)
      AND smax.meanbp_score >= smin.meanbp_score
      THEN smax.meanbp_score
      WHEN ABS(meanbp_max - 90) = ABS(meanbp_min - 90)
      AND smax.meanbp_score < smin.meanbp_score
      THEN smin.meanbp_score
    END AS meanbp_score,
    CASE
      WHEN tempc_max IS NULL
      THEN NULL
      WHEN ABS(tempc_max - 38) > ABS(tempc_min - 38)
      THEN smax.temp_score
      WHEN ABS(tempc_max - 38) < ABS(tempc_min - 38)
      THEN smin.temp_score
      WHEN ABS(tempc_max - 38) = ABS(tempc_min - 38) AND smax.temp_score >= smin.temp_score
      THEN smax.temp_score
      WHEN ABS(tempc_max - 38) = ABS(tempc_min - 38) AND smax.temp_score < smin.temp_score
      THEN smin.temp_score
    END AS temp_score,
    CASE
      WHEN resprate_max IS NULL
      THEN NULL
      WHEN ABS(resprate_max - 19) > ABS(resprate_min - 19)
      THEN smax.resprate_score
      WHEN ABS(resprate_max - 19) < ABS(resprate_min - 19)
      THEN smin.resprate_score
      WHEN ABS(resprate_max - 19) = ABS(resprate_max - 19)
      AND smax.resprate_score >= smin.resprate_score
      THEN smax.resprate_score
      WHEN ABS(resprate_max - 19) = ABS(resprate_max - 19)
      AND smax.resprate_score < smin.resprate_score
      THEN smin.resprate_score
    END AS resprate_score,
    CASE
      WHEN hematocrit_max IS NULL
      THEN NULL
      WHEN ABS(hematocrit_max - 45.5) > ABS(hematocrit_min - 45.5)
      THEN smax.hematocrit_score
      WHEN ABS(hematocrit_max - 45.5) < ABS(hematocrit_min - 45.5)
      THEN smin.hematocrit_score
      WHEN ABS(hematocrit_max - 45.5) = ABS(hematocrit_max - 45.5)
      AND smax.hematocrit_score >= smin.hematocrit_score
      THEN smax.hematocrit_score
      WHEN ABS(hematocrit_max - 45.5) = ABS(hematocrit_max - 45.5)
      AND smax.hematocrit_score < smin.hematocrit_score
      THEN smin.hematocrit_score
    END AS hematocrit_score,
    CASE
      WHEN wbc_max IS NULL
      THEN NULL
      WHEN ABS(wbc_max - 11.5) > ABS(wbc_min - 11.5)
      THEN smax.wbc_score
      WHEN ABS(wbc_max - 11.5) < ABS(wbc_min - 11.5)
      THEN smin.wbc_score
      WHEN ABS(wbc_max - 11.5) = ABS(wbc_max - 11.5) AND smax.wbc_score >= smin.wbc_score
      THEN smax.wbc_score
      WHEN ABS(wbc_max - 11.5) = ABS(wbc_max - 11.5) AND smax.wbc_score < smin.wbc_score
      THEN smin.wbc_score
    END AS wbc_score,
    CASE
      WHEN creatinine_max IS NULL
      THEN NULL
      WHEN arf = 1
      THEN smax.creatinine_score
      WHEN ABS(creatinine_max - 1) > ABS(creatinine_min - 1)
      THEN smax.creatinine_score
      WHEN ABS(creatinine_max - 1) < ABS(creatinine_min - 1)
      THEN smin.creatinine_score
      WHEN smax.creatinine_score >= smin.creatinine_score
      THEN smax.creatinine_score
      WHEN smax.creatinine_score < smin.creatinine_score
      THEN smin.creatinine_score
    END AS creatinine_score,
    CASE WHEN bun_max IS NULL THEN NULL ELSE smax.bun_score END AS bun_score,
    CASE
      WHEN sodium_max IS NULL
      THEN NULL
      WHEN ABS(sodium_max - 145.5) > ABS(sodium_min - 145.5)
      THEN smax.sodium_score
      WHEN ABS(sodium_max - 145.5) < ABS(sodium_min - 145.5)
      THEN smin.sodium_score
      WHEN ABS(sodium_max - 145.5) = ABS(sodium_max - 145.5)
      AND smax.sodium_score >= smin.sodium_score
      THEN smax.sodium_score
      WHEN ABS(sodium_max - 145.5) = ABS(sodium_max - 145.5)
      AND smax.sodium_score < smin.sodium_score
      THEN smin.sodium_score
    END AS sodium_score,
    CASE
      WHEN albumin_max IS NULL
      THEN NULL
      WHEN ABS(albumin_max - 3.5) > ABS(albumin_min - 3.5)
      THEN smax.albumin_score
      WHEN ABS(albumin_max - 3.5) < ABS(albumin_min - 3.5)
      THEN smin.albumin_score
      WHEN ABS(albumin_max - 3.5) = ABS(albumin_max - 3.5)
      AND smax.albumin_score >= smin.albumin_score
      THEN smax.albumin_score
      WHEN ABS(albumin_max - 3.5) = ABS(albumin_max - 3.5)
      AND smax.albumin_score < smin.albumin_score
      THEN smin.albumin_score
    END AS albumin_score,
    CASE WHEN bilirubin_max IS NULL THEN NULL ELSE smax.bilirubin_score END AS bilirubin_score,
    CASE
      WHEN glucose_max IS NULL
      THEN NULL
      WHEN ABS(glucose_max - 130) > ABS(glucose_min - 130)
      THEN smax.glucose_score
      WHEN ABS(glucose_max - 130) < ABS(glucose_min - 130)
      THEN smin.glucose_score
      WHEN ABS(glucose_max - 130) = ABS(glucose_max - 130)
      AND smax.glucose_score >= smin.glucose_score
      THEN smax.glucose_score
      WHEN ABS(glucose_max - 130) = ABS(glucose_max - 130)
      AND smax.glucose_score < smin.glucose_score
      THEN smin.glucose_score
    END AS glucose_score,
    CASE
      WHEN urineoutput IS NULL
      THEN NULL
      WHEN urineoutput < 400
      THEN 15
      WHEN urineoutput < 600
      THEN 8
      WHEN urineoutput < 900
      THEN 7
      WHEN urineoutput < 1500
      THEN 5
      WHEN urineoutput < 2000
      THEN 4
      WHEN urineoutput < 4000
      THEN 0
      WHEN urineoutput >= 4000
      THEN 1
    END AS uo_score,
    CASE
      WHEN endotrachflag = 1
      THEN 0
      WHEN gcseyes = 1
      THEN CASE
        WHEN gcsverbal = 1 AND gcsmotor IN (1, 2)
        THEN 48
        WHEN gcsverbal = 1 AND gcsmotor IN (3, 4)
        THEN 33
        WHEN gcsverbal = 1 AND gcsmotor IN (5, 6)
        THEN 16
        WHEN gcsverbal IN (2, 3) AND gcsmotor IN (1, 2)
        THEN 29
        WHEN gcsverbal IN (2, 3) AND gcsmotor IN (3, 4)
        THEN 24
        WHEN gcsverbal IN (2, 3) AND gcsmotor >= 5
        THEN NULL
        WHEN gcsverbal >= 4
        THEN NULL
      END
      WHEN gcseyes > 1
      THEN CASE
        WHEN gcsverbal = 1 AND gcsmotor IN (1, 2)
        THEN 29
        WHEN gcsverbal = 1 AND gcsmotor IN (3, 4)
        THEN 24
        WHEN gcsverbal = 1 AND gcsmotor IN (5, 6)
        THEN 15
        WHEN gcsverbal IN (2, 3) AND gcsmotor IN (1, 2)
        THEN 29
        WHEN gcsverbal IN (2, 3) AND gcsmotor IN (3, 4)
        THEN 24
        WHEN gcsverbal IN (2, 3) AND gcsmotor = 5
        THEN 13
        WHEN gcsverbal IN (2, 3) AND gcsmotor = 6
        THEN 10
        WHEN gcsverbal = 4 AND gcsmotor IN (1, 2, 3, 4)
        THEN 13
        WHEN gcsverbal = 4 AND gcsmotor = 5
        THEN 8
        WHEN gcsverbal = 4 AND gcsmotor = 6
        THEN 3
        WHEN gcsverbal = 5 AND gcsmotor IN (1, 2, 3, 4, 5)
        THEN 3
        WHEN gcsverbal = 5 AND gcsmotor = 6
        THEN 0
      END
      ELSE NULL
    END AS gcs_score,
    CASE
      WHEN pao2 IS NULL AND aado2 IS NULL
      THEN NULL
      WHEN NOT pao2 IS NULL
      THEN CASE WHEN pao2 < 50 THEN 15 WHEN pao2 < 70 THEN 5 WHEN pao2 < 80 THEN 2 ELSE 0 END
      WHEN NOT aado2 IS NULL
      THEN CASE
        WHEN aado2 < 100
        THEN 0
        WHEN aado2 < 250
        THEN 7
        WHEN aado2 < 350
        THEN 9
        WHEN aado2 < 500
        THEN 11
        WHEN aado2 >= 500
        THEN 14
        ELSE 0
      END
    END AS pao2_aado2_score
  FROM cohort AS co
  LEFT JOIN score_min AS smin
    ON co.icustay_id = smin.icustay_id
  LEFT JOIN score_max AS smax
    ON co.icustay_id = smax.icustay_id
), score AS (
  SELECT
    s.*,
    COALESCE(hr_score, 0) + COALESCE(meanbp_score, 0) + COALESCE(temp_score, 0) + COALESCE(resprate_score, 0) + COALESCE(pao2_aado2_score, 0) + COALESCE(hematocrit_score, 0) + COALESCE(wbc_score, 0) + COALESCE(creatinine_score, 0) + COALESCE(uo_score, 0) + COALESCE(bun_score, 0) + COALESCE(sodium_score, 0) + COALESCE(albumin_score, 0) + COALESCE(bilirubin_score, 0) + COALESCE(glucose_score, 0) + COALESCE(acidbase_score, 0) + COALESCE(gcs_score, 0) AS apsiii
  FROM scorecomp AS s
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  apsiii,
  1 / (
    1 + EXP(-(
      -4.4360 + 0.04726 * (
        apsiii
      )
    ))
  ) AS apsiii_prob,
  hr_score,
  meanbp_score,
  temp_score,
  resprate_score,
  pao2_aado2_score,
  hematocrit_score,
  wbc_score,
  creatinine_score,
  uo_score,
  bun_score,
  sodium_score,
  albumin_score,
  bilirubin_score,
  glucose_score,
  acidbase_score,
  gcs_score
FROM mimiciii.icustays AS ie
LEFT JOIN score AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST