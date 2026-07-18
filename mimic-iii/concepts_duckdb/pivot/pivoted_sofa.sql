-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_sofa; CREATE TABLE mimiciii_derived.pivoted_sofa AS
WITH co AS (
  SELECT
    ih.icustay_id,
    ie.hadm_id,
    hr,
    ih.endtime - INTERVAL '1' HOUR AS starttime,
    ih.endtime
  FROM mimiciii_derived.icustay_hours AS ih
  INNER JOIN mimiciii.icustays AS ie
    ON ih.icustay_id = ie.icustay_id
), bp AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    MIN(valuenum) AS meanbp_min
  FROM mimiciii.chartevents AS ce
  WHERE
    (
      ce.error IS NULL OR ce.error <> 1
    )
    AND ce.itemid IN (456, 52, 6702, 443, 220052, 220181, 225312)
    AND valuenum > 0
    AND valuenum < 300
  GROUP BY
    ce.icustay_id,
    ce.charttime
), pafi AS (
  SELECT
    ie.icustay_id,
    bg.charttime,
    CASE WHEN vd.icustay_id IS NULL THEN pao2fio2ratio ELSE NULL END AS pao2fio2ratio_novent,
    CASE WHEN NOT vd.icustay_id IS NULL THEN pao2fio2ratio ELSE NULL END AS pao2fio2ratio_vent
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii_derived.pivoted_bg_art AS bg
    ON ie.icustay_id = bg.icustay_id
  LEFT JOIN mimiciii_derived.ventilation_durations AS vd
    ON ie.icustay_id = vd.icustay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
), mini_agg AS (
  SELECT
    co.icustay_id,
    co.hr,
    MIN(bp.meanbp_min) AS meanbp_min,
    MIN(gcs.GCS) AS GCS_min,
    MAX(labs.bilirubin) AS bilirubin_max,
    MAX(labs.creatinine) AS creatinine_max,
    MIN(labs.platelet) AS platelet_min,
    MIN(CASE WHEN vd.icustay_id IS NULL THEN pao2fio2ratio ELSE NULL END) AS pao2fio2ratio_novent,
    MIN(CASE WHEN NOT vd.icustay_id IS NULL THEN pao2fio2ratio ELSE NULL END) AS pao2fio2ratio_vent
  FROM co
  LEFT JOIN bp
    ON co.icustay_id = bp.icustay_id
    AND co.starttime < bp.charttime
    AND co.endtime >= bp.charttime
  LEFT JOIN mimiciii_derived.pivoted_gcs AS gcs
    ON co.icustay_id = gcs.icustay_id
    AND co.starttime < gcs.charttime
    AND co.endtime >= gcs.charttime
  LEFT JOIN mimiciii_derived.pivoted_lab AS labs
    ON co.hadm_id = labs.hadm_id
    AND co.starttime < labs.charttime
    AND co.endtime >= labs.charttime
  LEFT JOIN mimiciii_derived.pivoted_bg_art AS bg
    ON co.icustay_id = bg.icustay_id
    AND co.starttime < bg.charttime
    AND co.endtime >= bg.charttime
  LEFT JOIN mimiciii_derived.ventilation_durations AS vd
    ON co.icustay_id = vd.icustay_id
    AND bg.charttime >= vd.starttime
    AND bg.charttime <= vd.endtime
  GROUP BY
    co.icustay_id,
    co.hr
), uo AS (
  SELECT
    co.icustay_id,
    co.hr,
    SUM(uo.urineoutput) AS urineoutput
  FROM co
  LEFT JOIN mimiciii_derived.pivoted_uo AS uo
    ON co.icustay_id = uo.icustay_id
    AND co.starttime < uo.charttime
    AND co.endtime >= uo.charttime
  GROUP BY
    co.icustay_id,
    co.hr
), scorecomp AS (
  SELECT
    co.icustay_id,
    co.hr,
    co.starttime,
    co.endtime,
    ma.pao2fio2ratio_novent,
    ma.pao2fio2ratio_vent,
    epi.vaso_rate AS rate_epinephrine,
    nor.vaso_rate AS rate_norepinephrine,
    dop.vaso_rate AS rate_dopamine,
    dob.vaso_rate AS rate_dobutamine,
    ma.meanbp_min,
    ma.GCS_min,
    uo.urineoutput,
    ma.bilirubin_max,
    ma.creatinine_max,
    ma.platelet_min
  FROM co
  LEFT JOIN mini_agg AS ma
    ON co.icustay_id = ma.icustay_id AND co.hr = ma.hr
  LEFT JOIN uo
    ON co.icustay_id = uo.icustay_id AND co.hr = uo.hr
  LEFT JOIN pafi
    ON co.icustay_id = pafi.icustay_id
    AND co.starttime < pafi.charttime
    AND co.endtime >= pafi.charttime
  LEFT JOIN mimiciii_derived.epinephrine_dose AS epi
    ON co.icustay_id = epi.icustay_id
    AND co.endtime > epi.starttime
    AND co.endtime <= epi.endtime
  LEFT JOIN mimiciii_derived.norepinephrine_dose AS nor
    ON co.icustay_id = nor.icustay_id
    AND co.endtime > nor.starttime
    AND co.endtime <= nor.endtime
  LEFT JOIN mimiciii_derived.dopamine_dose AS dop
    ON co.icustay_id = dop.icustay_id
    AND co.endtime > dop.starttime
    AND co.endtime <= dop.endtime
  LEFT JOIN mimiciii_derived.dobutamine_dose AS dob
    ON co.icustay_id = dob.icustay_id
    AND co.endtime > dob.starttime
    AND co.endtime <= dob.endtime
), scorecalc AS (
  SELECT
    scorecomp.*,
    CAST(CASE
      WHEN pao2fio2ratio_vent < 100
      THEN 4
      WHEN pao2fio2ratio_vent < 200
      THEN 3
      WHEN pao2fio2ratio_novent < 300
      THEN 2
      WHEN pao2fio2ratio_novent < 400
      THEN 1
      WHEN COALESCE(pao2fio2ratio_vent, pao2fio2ratio_novent) IS NULL
      THEN NULL
      ELSE 0
    END AS SMALLINT) AS respiration,
    CAST(CASE
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
    END AS SMALLINT) AS coagulation,
    CAST(CASE
      WHEN Bilirubin_Max >= 12.0
      THEN 4
      WHEN Bilirubin_Max >= 6.0
      THEN 3
      WHEN Bilirubin_Max >= 2.0
      THEN 2
      WHEN Bilirubin_Max >= 1.2
      THEN 1
      WHEN Bilirubin_Max IS NULL
      THEN NULL
      ELSE 0
    END AS SMALLINT) AS liver,
    CAST(CASE
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
    END AS SMALLINT) AS cardiovascular,
    CAST(CASE
      WHEN (
        GCS_min >= 13 AND GCS_min <= 14
      )
      THEN 1
      WHEN (
        GCS_min >= 10 AND GCS_min <= 12
      )
      THEN 2
      WHEN (
        GCS_min >= 6 AND GCS_min <= 9
      )
      THEN 3
      WHEN GCS_min < 6
      THEN 4
      WHEN GCS_min IS NULL
      THEN NULL
      ELSE 0
    END AS SMALLINT) AS cns,
    CAST(CASE
      WHEN (
        Creatinine_Max >= 5.0
      )
      THEN 4
      WHEN SUM(urineoutput) OVER W < 200
      THEN 4
      WHEN (
        Creatinine_Max >= 3.5 AND Creatinine_Max < 5.0
      )
      THEN 3
      WHEN SUM(urineoutput) OVER W < 500
      THEN 3
      WHEN (
        Creatinine_Max >= 2.0 AND Creatinine_Max < 3.5
      )
      THEN 2
      WHEN (
        Creatinine_Max >= 1.2 AND Creatinine_Max < 2.0
      )
      THEN 1
      WHEN COALESCE(SUM(urineoutput) OVER W, Creatinine_Max) IS NULL
      THEN NULL
      ELSE 0
    END AS SMALLINT) AS renal
  FROM scorecomp
  WINDOW W AS (
    PARTITION BY icustay_id
    ORDER BY hr NULLS FIRST
    ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING
  )
), score_final AS (
  SELECT
    s.*,
    CAST(COALESCE(
      MAX(respiration) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) AS SMALLINT) AS respiration_24hours,
    CAST(COALESCE(
      MAX(coagulation) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) AS SMALLINT) AS coagulation_24hours,
    CAST(COALESCE(
      MAX(liver) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) AS SMALLINT) AS liver_24hours,
    CAST(COALESCE(
      MAX(cardiovascular) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) AS SMALLINT) AS cardiovascular_24hours,
    CAST(COALESCE(
      MAX(cns) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) AS SMALLINT) AS cns_24hours,
    CAST(COALESCE(
      MAX(renal) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) AS SMALLINT) AS renal_24hours,
    COALESCE(
      MAX(respiration) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) + COALESCE(
      MAX(coagulation) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) + COALESCE(
      MAX(liver) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) + COALESCE(
      MAX(cardiovascular) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) + COALESCE(
      MAX(cns) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) + CAST(COALESCE(
      MAX(renal) OVER (
        PARTITION BY icustay_id
        ORDER BY HR NULLS FIRST
        ROWS BETWEEN 24 PRECEDING AND 0 FOLLOWING
      ),
      0
    ) AS SMALLINT) AS sofa_24hours
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
ORDER BY
  icustay_id NULLS FIRST,
  hr NULLS FIRST