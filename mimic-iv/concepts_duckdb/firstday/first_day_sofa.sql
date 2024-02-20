-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_sofa; CREATE TABLE mimiciv_derived.first_day_sofa AS
WITH vaso_stg AS (
  SELECT
    ie.stay_id,
    'norepinephrine' AS treatment,
    vaso_rate AS rate
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_derived.norepinephrine AS mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= ie.intime - INTERVAL '6' HOUR
    AND mv.starttime <= ie.intime + INTERVAL '1' DAY
  UNION ALL
  SELECT
    ie.stay_id,
    'epinephrine' AS treatment,
    vaso_rate AS rate
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_derived.epinephrine AS mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= ie.intime - INTERVAL '6' HOUR
    AND mv.starttime <= ie.intime + INTERVAL '1' DAY
  UNION ALL
  SELECT
    ie.stay_id,
    'dobutamine' AS treatment,
    vaso_rate AS rate
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_derived.dobutamine AS mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= ie.intime - INTERVAL '6' HOUR
    AND mv.starttime <= ie.intime + INTERVAL '1' DAY
  UNION ALL
  SELECT
    ie.stay_id,
    'dopamine' AS treatment,
    vaso_rate AS rate
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_derived.dopamine AS mv
    ON ie.stay_id = mv.stay_id
    AND mv.starttime >= ie.intime - INTERVAL '6' HOUR
    AND mv.starttime <= ie.intime + INTERVAL '1' DAY
), vaso_mv AS (
  SELECT
    ie.stay_id,
    MAX(CASE WHEN treatment = 'norepinephrine' THEN rate ELSE NULL END) AS rate_norepinephrine,
    MAX(CASE WHEN treatment = 'epinephrine' THEN rate ELSE NULL END) AS rate_epinephrine,
    MAX(CASE WHEN treatment = 'dopamine' THEN rate ELSE NULL END) AS rate_dopamine,
    MAX(CASE WHEN treatment = 'dobutamine' THEN rate ELSE NULL END) AS rate_dobutamine
  FROM mimiciv_icu.icustays AS ie
  LEFT JOIN vaso_stg AS v
    ON ie.stay_id = v.stay_id
  GROUP BY
    ie.stay_id
), pafi1 AS (
  SELECT
    ie.stay_id,
    bg.charttime,
    bg.pao2fio2ratio,
    CASE WHEN NOT vd.stay_id IS NULL THEN 1 ELSE 0 END AS isvent
  FROM mimiciv_icu.icustays AS ie
  LEFT JOIN mimiciv_derived.bg AS bg
    ON ie.subject_id = bg.subject_id
    AND bg.charttime >= ie.intime - INTERVAL '6' HOUR
    AND bg.charttime <= ie.intime + INTERVAL '1' DAY
  LEFT JOIN mimiciv_derived.ventilation AS vd
    ON ie.stay_id = vd.stay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
    AND vd.ventilation_status = 'InvasiveVent'
), pafi2 AS (
  SELECT
    stay_id,
    MIN(CASE WHEN isvent = 0 THEN pao2fio2ratio ELSE NULL END) AS pao2fio2_novent_min,
    MIN(CASE WHEN isvent = 1 THEN pao2fio2ratio ELSE NULL END) AS pao2fio2_vent_min
  FROM pafi1
  GROUP BY
    stay_id
), scorecomp AS (
  SELECT
    ie.stay_id,
    v.mbp_min,
    mv.rate_norepinephrine,
    mv.rate_epinephrine,
    mv.rate_dopamine,
    mv.rate_dobutamine,
    l.creatinine_max,
    l.bilirubin_total_max AS bilirubin_max,
    l.platelets_min AS platelet_min,
    pf.pao2fio2_novent_min,
    pf.pao2fio2_vent_min,
    uo.urineoutput,
    gcs.gcs_min
  FROM mimiciv_icu.icustays AS ie
  LEFT JOIN vaso_mv AS mv
    ON ie.stay_id = mv.stay_id
  LEFT JOIN pafi2 AS pf
    ON ie.stay_id = pf.stay_id
  LEFT JOIN mimiciv_derived.first_day_vitalsign AS v
    ON ie.stay_id = v.stay_id
  LEFT JOIN mimiciv_derived.first_day_lab AS l
    ON ie.stay_id = l.stay_id
  LEFT JOIN mimiciv_derived.first_day_urine_output AS uo
    ON ie.stay_id = uo.stay_id
  LEFT JOIN mimiciv_derived.first_day_gcs AS gcs
    ON ie.stay_id = gcs.stay_id
), scorecalc AS (
  SELECT
    stay_id,
    CASE
      WHEN pao2fio2_vent_min < 100
      THEN 4
      WHEN pao2fio2_vent_min < 200
      THEN 3
      WHEN pao2fio2_novent_min < 300
      THEN 2
      WHEN pao2fio2_novent_min < 400
      THEN 1
      WHEN COALESCE(pao2fio2_vent_min, pao2fio2_novent_min) IS NULL
      THEN NULL
      ELSE 0
    END AS respiration,
    CASE
      WHEN platelet_min < 20
      THEN 4
      WHEN platelet_min < 50
      THEN 3
      WHEN platelet_min < 100
      THEN 2
      WHEN platelet_min < 150
      THEN 1
      WHEN platelet_min IS NULL
      THEN NULL
      ELSE 0
    END AS coagulation,
    CASE
      WHEN bilirubin_max >= 12.0
      THEN 4
      WHEN bilirubin_max >= 6.0
      THEN 3
      WHEN bilirubin_max >= 2.0
      THEN 2
      WHEN bilirubin_max >= 1.2
      THEN 1
      WHEN bilirubin_max IS NULL
      THEN NULL
      ELSE 0
    END AS liver,
    CASE
      WHEN rate_dopamine > 15 OR rate_epinephrine > 0.1 OR rate_norepinephrine > 0.1
      THEN 4
      WHEN rate_dopamine > 5 OR rate_epinephrine <= 0.1 OR rate_norepinephrine <= 0.1
      THEN 3
      WHEN rate_dopamine > 0 OR rate_dobutamine > 0
      THEN 2
      WHEN mbp_min < 70
      THEN 1
      WHEN COALESCE(mbp_min, rate_dopamine, rate_dobutamine, rate_epinephrine, rate_norepinephrine) IS NULL
      THEN NULL
      ELSE 0
    END AS cardiovascular,
    CASE
      WHEN (
        gcs_min >= 13 AND gcs_min <= 14
      )
      THEN 1
      WHEN (
        gcs_min >= 10 AND gcs_min <= 12
      )
      THEN 2
      WHEN (
        gcs_min >= 6 AND gcs_min <= 9
      )
      THEN 3
      WHEN gcs_min < 6
      THEN 4
      WHEN gcs_min IS NULL
      THEN NULL
      ELSE 0
    END AS cns,
    CASE
      WHEN (
        creatinine_max >= 5.0
      )
      THEN 4
      WHEN urineoutput < 200
      THEN 4
      WHEN (
        creatinine_max >= 3.5 AND creatinine_max < 5.0
      )
      THEN 3
      WHEN urineoutput < 500
      THEN 3
      WHEN (
        creatinine_max >= 2.0 AND creatinine_max < 3.5
      )
      THEN 2
      WHEN (
        creatinine_max >= 1.2 AND creatinine_max < 2.0
      )
      THEN 1
      WHEN COALESCE(urineoutput, creatinine_max) IS NULL
      THEN NULL
      ELSE 0
    END AS renal
  FROM scorecomp
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.stay_id,
  COALESCE(respiration, 0) + COALESCE(coagulation, 0) + COALESCE(liver, 0) + COALESCE(cardiovascular, 0) + COALESCE(cns, 0) + COALESCE(renal, 0) AS sofa,
  respiration,
  coagulation,
  liver,
  cardiovascular,
  cns,
  renal
FROM mimiciv_icu.icustays AS ie
LEFT JOIN scorecalc AS s
  ON ie.stay_id = s.stay_id