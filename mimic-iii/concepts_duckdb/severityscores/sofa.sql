-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.sofa; CREATE TABLE mimiciii_derived.sofa AS
WITH wt AS (
  SELECT
    ie.icustay_id,
    AVG(
      CASE
        WHEN itemid IN (762, 763, 3723, 3580, 226512)
        THEN valuenum
        WHEN itemid IN (3581)
        THEN valuenum * 0.45359237
        WHEN itemid IN (3582)
        THEN valuenum * 0.0283495231
        ELSE NULL
      END
    ) AS weight
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii.chartevents AS c
    ON ie.icustay_id = c.icustay_id
  WHERE
    NOT valuenum IS NULL
    AND itemid IN (762, 763, 3723, 3580, 3581, 3582, 226512)
    AND valuenum <> 0
    AND charttime BETWEEN ie.intime - INTERVAL '1' DAY AND ie.intime + INTERVAL '1' DAY
    AND (
      c.error IS NULL OR c.error = 0
    )
  GROUP BY
    ie.icustay_id
), echo2 AS (
  SELECT
    ie.icustay_id,
    AVG(weight * 0.45359237) AS weight
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii_derived.echo_data AS echo
    ON ie.hadm_id = echo.hadm_id
    AND echo.charttime > ie.intime - INTERVAL '7' DAY
    AND echo.charttime < ie.intime + INTERVAL '1' DAY
  GROUP BY
    ie.icustay_id
), vaso_cv AS (
  SELECT
    ie.icustay_id,
    MAX(
      CASE
        WHEN itemid = 30047
        THEN rate / COALESCE(wt.weight, ec.weight)
        WHEN itemid = 30120
        THEN rate
        ELSE NULL
      END
    ) AS rate_norepinephrine,
    MAX(
      CASE
        WHEN itemid = 30044
        THEN rate / COALESCE(wt.weight, ec.weight)
        WHEN itemid IN (30119, 30309)
        THEN rate
        ELSE NULL
      END
    ) AS rate_epinephrine,
    MAX(CASE WHEN itemid IN (30043, 30307) THEN rate END) AS rate_dopamine,
    MAX(CASE WHEN itemid IN (30042, 30306) THEN rate END) AS rate_dobutamine
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.inputevents_cv AS cv
    ON ie.icustay_id = cv.icustay_id
    AND cv.charttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
  LEFT JOIN wt
    ON ie.icustay_id = wt.icustay_id
  LEFT JOIN echo2 AS ec
    ON ie.icustay_id = ec.icustay_id
  WHERE
    itemid IN (30047, 30120, 30044, 30119, 30309, 30043, 30307, 30042, 30306)
    AND NOT rate IS NULL
  GROUP BY
    ie.icustay_id
), vaso_mv AS (
  SELECT
    ie.icustay_id,
    MAX(CASE WHEN itemid = 221906 THEN rate END) AS rate_norepinephrine,
    MAX(CASE WHEN itemid = 221289 THEN rate END) AS rate_epinephrine,
    MAX(CASE WHEN itemid = 221662 THEN rate END) AS rate_dopamine,
    MAX(CASE WHEN itemid = 221653 THEN rate END) AS rate_dobutamine
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.inputevents_mv AS mv
    ON ie.icustay_id = mv.icustay_id
    AND mv.starttime BETWEEN ie.intime AND ie.intime + INTERVAL '1' DAY
  WHERE
    itemid IN (221906, 221289, 221662, 221653) AND statusdescription <> 'Rewritten'
  GROUP BY
    ie.icustay_id
), pafi1 AS (
  SELECT
    bg.icustay_id,
    bg.charttime,
    pao2fio2,
    CASE WHEN NOT vd.icustay_id IS NULL THEN 1 ELSE 0 END AS isvent
  FROM mimiciii_derived.blood_gas_first_day_arterial AS bg
  LEFT JOIN mimiciii_derived.ventilation_durations AS vd
    ON bg.icustay_id = vd.icustay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
  ORDER BY
    bg.icustay_id NULLS FIRST,
    bg.charttime NULLS FIRST
), pafi2 AS (
  SELECT
    icustay_id,
    MIN(CASE WHEN isvent = 0 THEN pao2fio2 ELSE NULL END) AS pao2fio2_novent_min,
    MIN(CASE WHEN isvent = 1 THEN pao2fio2 ELSE NULL END) AS pao2fio2_vent_min
  FROM pafi1
  GROUP BY
    icustay_id
), scorecomp AS (
  SELECT
    ie.icustay_id,
    v.meanbp_min,
    COALESCE(cv.rate_norepinephrine, mv.rate_norepinephrine) AS rate_norepinephrine,
    COALESCE(cv.rate_epinephrine, mv.rate_epinephrine) AS rate_epinephrine,
    COALESCE(cv.rate_dopamine, mv.rate_dopamine) AS rate_dopamine,
    COALESCE(cv.rate_dobutamine, mv.rate_dobutamine) AS rate_dobutamine,
    l.creatinine_max,
    l.bilirubin_max,
    l.platelet_min,
    pf.pao2fio2_novent_min,
    pf.pao2fio2_vent_min,
    uo.urineoutput,
    gcs.mingcs
  FROM mimiciii.icustays AS ie
  LEFT JOIN vaso_cv AS cv
    ON ie.icustay_id = cv.icustay_id
  LEFT JOIN vaso_mv AS mv
    ON ie.icustay_id = mv.icustay_id
  LEFT JOIN pafi2 AS pf
    ON ie.icustay_id = pf.icustay_id
  LEFT JOIN mimiciii_derived.vitals_first_day AS v
    ON ie.icustay_id = v.icustay_id
  LEFT JOIN mimiciii_derived.labs_first_day AS l
    ON ie.icustay_id = l.icustay_id
  LEFT JOIN mimiciii_derived.urine_output_first_day AS uo
    ON ie.icustay_id = uo.icustay_id
  LEFT JOIN mimiciii_derived.gcs_first_day AS gcs
    ON ie.icustay_id = gcs.icustay_id
), scorecalc AS (
  SELECT
    icustay_id,
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
      WHEN meanbp_min < 70
      THEN 1
      WHEN COALESCE(meanbp_min, rate_dopamine, rate_dobutamine, rate_epinephrine, rate_norepinephrine) IS NULL
      THEN NULL
      ELSE 0
    END AS cardiovascular,
    CASE
      WHEN (
        mingcs >= 13 AND mingcs <= 14
      )
      THEN 1
      WHEN (
        mingcs >= 10 AND mingcs <= 12
      )
      THEN 2
      WHEN (
        mingcs >= 6 AND mingcs <= 9
      )
      THEN 3
      WHEN mingcs < 6
      THEN 4
      WHEN mingcs IS NULL
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
  ie.icustay_id,
  COALESCE(respiration, 0) + COALESCE(coagulation, 0) + COALESCE(liver, 0) + COALESCE(cardiovascular, 0) + COALESCE(cns, 0) + COALESCE(renal, 0) AS SOFA,
  respiration,
  coagulation,
  liver,
  cardiovascular,
  cns,
  renal
FROM mimiciii.icustays AS ie
LEFT JOIN scorecalc AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST