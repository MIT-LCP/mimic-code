-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.sofa; CREATE TABLE mimiciv_derived.sofa AS
WITH co AS (
  SELECT
    ih.stay_id,
    ie.hadm_id,
    hr,
    ih.endtime - INTERVAL '1' HOUR AS starttime,
    ih.endtime
  FROM mimiciv_derived.icustay_hourly AS ih
  INNER JOIN mimiciv_icu.icustays AS ie
    ON ih.stay_id = ie.stay_id
), pafi AS (
  SELECT
    ie.stay_id,
    bg.charttime,
    CASE WHEN vd.stay_id IS NULL THEN pao2fio2ratio ELSE NULL END AS pao2fio2ratio_novent,
    CASE WHEN NOT vd.stay_id IS NULL THEN pao2fio2ratio ELSE NULL END AS pao2fio2ratio_vent
  FROM mimiciv_icu.icustays AS ie
  INNER JOIN mimiciv_derived.bg AS bg
    ON ie.subject_id = bg.subject_id
  LEFT JOIN mimiciv_derived.ventilation AS vd
    ON ie.stay_id = vd.stay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
    AND vd.ventilation_status = 'InvasiveVent'
  WHERE
    specimen = 'ART.'
), vs AS (
  SELECT
    co.stay_id,
    co.hr,
    MIN(vs.mbp) AS meanbp_min
  FROM co
  LEFT JOIN mimiciv_derived.vitalsign AS vs
    ON co.stay_id = vs.stay_id
    AND co.starttime < vs.charttime
    AND co.endtime >= vs.charttime
  GROUP BY
    co.stay_id,
    co.hr
), gcs AS (
  SELECT
    co.stay_id,
    co.hr,
    MIN(gcs.gcs) AS gcs_min
  FROM co
  LEFT JOIN mimiciv_derived.gcs AS gcs
    ON co.stay_id = gcs.stay_id
    AND co.starttime < gcs.charttime
    AND co.endtime >= gcs.charttime
  GROUP BY
    co.stay_id,
    co.hr
), bili AS (
  SELECT
    co.stay_id,
    co.hr,
    MAX(enz.bilirubin_total) AS bilirubin_max
  FROM co
  LEFT JOIN mimiciv_derived.enzyme AS enz
    ON co.hadm_id = enz.hadm_id
    AND co.starttime < enz.charttime
    AND co.endtime >= enz.charttime
  GROUP BY
    co.stay_id,
    co.hr
), cr AS (
  SELECT
    co.stay_id,
    co.hr,
    MAX(chem.creatinine) AS creatinine_max
  FROM co
  LEFT JOIN mimiciv_derived.chemistry AS chem
    ON co.hadm_id = chem.hadm_id
    AND co.starttime < chem.charttime
    AND co.endtime >= chem.charttime
  GROUP BY
    co.stay_id,
    co.hr
), plt AS (
  SELECT
    co.stay_id,
    co.hr,
    MIN(cbc.platelet) AS platelet_min
  FROM co
  LEFT JOIN mimiciv_derived.complete_blood_count AS cbc
    ON co.hadm_id = cbc.hadm_id
    AND co.starttime < cbc.charttime
    AND co.endtime >= cbc.charttime
  GROUP BY
    co.stay_id,
    co.hr
), pf AS (
  SELECT
    co.stay_id,
    co.hr,
    MIN(pafi.pao2fio2ratio_novent) AS pao2fio2ratio_novent,
    MIN(pafi.pao2fio2ratio_vent) AS pao2fio2ratio_vent
  FROM co
  LEFT JOIN pafi
    ON co.stay_id = pafi.stay_id
    AND co.starttime < pafi.charttime
    AND co.endtime >= pafi.charttime
  GROUP BY
    co.stay_id,
    co.hr
), uo AS (
  SELECT
    co.stay_id,
    co.hr,
    MAX(
      CASE
        WHEN uo.uo_tm_24hr >= 22 AND uo.uo_tm_24hr <= 30
        THEN uo.urineoutput_24hr / uo.uo_tm_24hr * 24
      END
    ) AS uo_24hr
  FROM co
  LEFT JOIN mimiciv_derived.urine_output_rate AS uo
    ON co.stay_id = uo.stay_id
    AND co.starttime < uo.charttime
    AND co.endtime >= uo.charttime
  GROUP BY
    co.stay_id,
    co.hr
), vaso AS (
  SELECT
    co.stay_id,
    co.hr,
    MAX(epi.vaso_rate) AS rate_epinephrine,
    MAX(nor.vaso_rate) AS rate_norepinephrine,
    MAX(dop.vaso_rate) AS rate_dopamine,
    MAX(dob.vaso_rate) AS rate_dobutamine
  FROM co
  LEFT JOIN mimiciv_derived.epinephrine AS epi
    ON co.stay_id = epi.stay_id
    AND co.endtime > epi.starttime
    AND co.endtime <= epi.endtime
  LEFT JOIN mimiciv_derived.norepinephrine AS nor
    ON co.stay_id = nor.stay_id
    AND co.endtime > nor.starttime
    AND co.endtime <= nor.endtime
  LEFT JOIN mimiciv_derived.dopamine AS dop
    ON co.stay_id = dop.stay_id
    AND co.endtime > dop.starttime
    AND co.endtime <= dop.endtime
  LEFT JOIN mimiciv_derived.dobutamine AS dob
    ON co.stay_id = dob.stay_id
    AND co.endtime > dob.starttime
    AND co.endtime <= dob.endtime
  WHERE
    NOT epi.stay_id IS NULL
    OR NOT nor.stay_id IS NULL
    OR NOT dop.stay_id IS NULL
    OR NOT dob.stay_id IS NULL
  GROUP BY
    co.stay_id,
    co.hr
), scorecomp AS (
  SELECT
    co.stay_id,
    co.hr,
    co.starttime,
    co.endtime,
    pf.pao2fio2ratio_novent,
    pf.pao2fio2ratio_vent,
    vaso.rate_epinephrine,
    vaso.rate_norepinephrine,
    vaso.rate_dopamine,
    vaso.rate_dobutamine,
    vs.meanbp_min,
    gcs.gcs_min,
    uo.uo_24hr,
    bili.bilirubin_max,
    cr.creatinine_max,
    plt.platelet_min
  FROM co
  LEFT JOIN vs
    ON co.stay_id = vs.stay_id AND co.hr = vs.hr
  LEFT JOIN gcs
    ON co.stay_id = gcs.stay_id AND co.hr = gcs.hr
  LEFT JOIN bili
    ON co.stay_id = bili.stay_id AND co.hr = bili.hr
  LEFT JOIN cr
    ON co.stay_id = cr.stay_id AND co.hr = cr.hr
  LEFT JOIN plt
    ON co.stay_id = plt.stay_id AND co.hr = plt.hr
  LEFT JOIN pf
    ON co.stay_id = pf.stay_id AND co.hr = pf.hr
  LEFT JOIN uo
    ON co.stay_id = uo.stay_id AND co.hr = uo.hr
  LEFT JOIN vaso
    ON co.stay_id = vaso.stay_id AND co.hr = vaso.hr
), scorecalc AS (
  SELECT
    scorecomp.*,
    CASE
      WHEN pao2fio2ratio_vent < 100
      THEN 4
      WHEN pao2fio2ratio_vent < 200
      THEN 3
      WHEN pao2fio2ratio_novent < 300
      THEN 2
      WHEN pao2fio2ratio_vent < 300
      THEN 2
      WHEN pao2fio2ratio_novent < 400
      THEN 1
      WHEN pao2fio2ratio_vent < 400
      THEN 1
      WHEN COALESCE(pao2fio2ratio_vent, pao2fio2ratio_novent) IS NULL
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
      WHEN uo_24hr < 200
      THEN 4
      WHEN (
        creatinine_max >= 3.5 AND creatinine_max < 5.0
      )
      THEN 3
      WHEN uo_24hr < 500
      THEN 3
      WHEN (
        creatinine_max >= 2.0 AND creatinine_max < 3.5
      )
      THEN 2
      WHEN (
        creatinine_max >= 1.2 AND creatinine_max < 2.0
      )
      THEN 1
      WHEN COALESCE(uo_24hr, creatinine_max) IS NULL
      THEN NULL
      ELSE 0
    END AS renal
  FROM scorecomp
), score_final AS (
  SELECT
    s.*,
    COALESCE(MAX(respiration) OVER w, 0) AS respiration_24hours,
    COALESCE(MAX(coagulation) OVER w, 0) AS coagulation_24hours,
    COALESCE(MAX(liver) OVER w, 0) AS liver_24hours,
    COALESCE(MAX(cardiovascular) OVER w, 0) AS cardiovascular_24hours,
    COALESCE(MAX(cns) OVER w, 0) AS cns_24hours,
    COALESCE(MAX(renal) OVER w, 0) AS renal_24hours,
    COALESCE(MAX(respiration) OVER w, 0) + COALESCE(MAX(coagulation) OVER w, 0) + COALESCE(MAX(liver) OVER w, 0) + COALESCE(MAX(cardiovascular) OVER w, 0) + COALESCE(MAX(cns) OVER w, 0) + COALESCE(MAX(renal) OVER w, 0) AS sofa_24hours
  FROM scorecalc AS s
  WINDOW w AS (PARTITION BY stay_id ORDER BY hr NULLS FIRST ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING)
)
SELECT
  *
FROM score_final
WHERE
  hr >= 0