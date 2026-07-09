-- =====================================================================
-- PostgreSQL version of BigQuery pivoted_sofa.sql (MIMIC-III)
-- Output table:
--   mimiciii_derived.pivoted_sofa
-- =====================================================================

DROP TABLE IF EXISTS mimiciii_derived.pivoted_sofa;

CREATE TABLE mimiciii_derived.pivoted_sofa AS
WITH co AS
(
  SELECT
      ih.icustay_id
    , ie.hadm_id
    , ih.hr
    -- start/endtime can be used to filter to values within this hour
    , (ih.endtime - INTERVAL '1' HOUR) AS starttime
    , ih.endtime
  FROM mimiciii_derived.icustay_hours ih
  INNER JOIN mimiciii_clinical.icustays ie
    ON ih.icustay_id = ie.icustay_id
)
, bp AS
(
  SELECT
      ce.icustay_id
    , ce.charttime
    , MIN(ce.valuenum) AS meanbp_min
  FROM mimiciii_clinical.chartevents ce
  WHERE (ce.error IS NULL OR ce.error != 1)
    AND ce.itemid IN
    (
      456,    -- NBP Mean
      52,     -- Arterial BP Mean
      6702,   -- Arterial BP Mean #2
      443,    -- Manual BP Mean(calc)
      220052, -- Arterial Blood Pressure mean
      220181, -- Non Invasive Blood Pressure mean
      225312  -- ART BP mean
    )
    AND ce.valuenum > 0
    AND ce.valuenum < 300
    AND ce.charttime IS NOT NULL
  GROUP BY ce.icustay_id, ce.charttime
)
, pafi AS
(
  -- join blood gas to ventilation durations to determine if patient was vent
  SELECT
      ie.icustay_id
    , bg.charttime
    , CASE WHEN vd.icustay_id IS NULL THEN bg.pao2fio2ratio ELSE NULL END AS pao2fio2ratio_novent
    , CASE WHEN vd.icustay_id IS NOT NULL THEN bg.pao2fio2ratio ELSE NULL END AS pao2fio2ratio_vent
  FROM mimiciii_clinical.icustays ie
  INNER JOIN mimiciii_derived.pivoted_bg_art bg
    ON ie.icustay_id = bg.icustay_id
  LEFT JOIN mimiciii_derived.ventilation_durations vd
    ON ie.icustay_id = vd.icustay_id
   AND bg.charttime >= vd.starttime
   AND bg.charttime <= vd.endtime
  WHERE bg.charttime IS NOT NULL
)
, mini_agg AS
(
  SELECT
      co.icustay_id
    , co.hr
    -- vitals
    , MIN(bp.meanbp_min) AS meanbp_min
    -- gcs
    , MIN(gcs.gcs) AS gcs_min
    -- labs
    , MAX(labs.bilirubin)  AS bilirubin_max
    , MAX(labs.creatinine) AS creatinine_max
    , MIN(labs.platelet)   AS platelet_min
    -- PaO2/FiO2 with vent interaction
    , MIN(CASE WHEN vd.icustay_id IS NULL THEN bg.pao2fio2ratio ELSE NULL END) AS pao2fio2ratio_novent
    , MIN(CASE WHEN vd.icustay_id IS NOT NULL THEN bg.pao2fio2ratio ELSE NULL END) AS pao2fio2ratio_vent
  FROM co
  LEFT JOIN bp
    ON co.icustay_id = bp.icustay_id
   AND co.starttime < bp.charttime
   AND co.endtime   >= bp.charttime
  LEFT JOIN mimiciii_derived.pivoted_gcs gcs
    ON co.icustay_id = gcs.icustay_id
   AND co.starttime < gcs.charttime
   AND co.endtime   >= gcs.charttime
  LEFT JOIN mimiciii_derived.pivoted_lab labs
    ON co.hadm_id = labs.hadm_id
   AND co.starttime < labs.charttime
   AND co.endtime   >= labs.charttime
  -- bring in blood gases that occurred during this hour
  LEFT JOIN mimiciii_derived.pivoted_bg_art bg
    ON co.icustay_id = bg.icustay_id
   AND co.starttime < bg.charttime
   AND co.endtime   >= bg.charttime
  -- at the time of the blood gas, determine if patient was ventilated
  LEFT JOIN mimiciii_derived.ventilation_durations vd
    ON co.icustay_id = vd.icustay_id
   AND bg.charttime >= vd.starttime
   AND bg.charttime <= vd.endtime
  GROUP BY co.icustay_id, co.hr
)
, uo AS
(
  -- sum uo separately to prevent duplicating values
  SELECT
      co.icustay_id
    , co.hr
    , SUM(uo.urineoutput) AS urineoutput
  FROM co
  LEFT JOIN mimiciii_derived.pivoted_uo uo
    ON co.icustay_id = uo.icustay_id
   AND co.starttime < uo.charttime
   AND co.endtime   >= uo.charttime
  GROUP BY co.icustay_id, co.hr
)
, scorecomp AS
(
  SELECT
      co.icustay_id
    , co.hr
    , co.starttime
    , co.endtime
    , ma.pao2fio2ratio_novent
    , ma.pao2fio2ratio_vent
    , epi.vaso_rate AS rate_epinephrine
    , nor.vaso_rate AS rate_norepinephrine
    , dop.vaso_rate AS rate_dopamine
    , dob.vaso_rate AS rate_dobutamine
    , ma.meanbp_min
    , ma.gcs_min
    , uo.urineoutput
    , ma.bilirubin_max
    , ma.creatinine_max
    , ma.platelet_min
  FROM co
  LEFT JOIN mini_agg ma
    ON co.icustay_id = ma.icustay_id
   AND co.hr = ma.hr
  LEFT JOIN uo
    ON co.icustay_id = uo.icustay_id
   AND co.hr = uo.hr
  LEFT JOIN mimiciii_derived.epinephrine_dose epi
    ON co.icustay_id = epi.icustay_id
   AND co.endtime > epi.starttime
   AND co.endtime <= epi.endtime
  LEFT JOIN mimiciii_derived.norepinephrine_dose nor
    ON co.icustay_id = nor.icustay_id
   AND co.endtime > nor.starttime
   AND co.endtime <= nor.endtime
  LEFT JOIN mimiciii_derived.dopamine_dose dop
    ON co.icustay_id = dop.icustay_id
   AND co.endtime > dop.starttime
   AND co.endtime <= dop.endtime
  LEFT JOIN mimiciii_derived.dobutamine_dose dob
    ON co.icustay_id = dob.icustay_id
   AND co.endtime > dob.starttime
   AND co.endtime <= dob.endtime
)
, scorecalc AS
(
  SELECT
      scorecomp.*

    -- Respiration
    , CAST(
        CASE
          WHEN pao2fio2ratio_vent   < 100 THEN 4
          WHEN pao2fio2ratio_vent   < 200 THEN 3
          WHEN pao2fio2ratio_novent < 300 THEN 2
          WHEN pao2fio2ratio_novent < 400 THEN 1
          WHEN COALESCE(pao2fio2ratio_vent, pao2fio2ratio_novent) IS NULL THEN NULL
          ELSE 0
        END AS SMALLINT
      ) AS respiration

    -- Coagulation
    , CAST(
        CASE
          WHEN platelet_min < 20  THEN 4
          WHEN platelet_min < 50  THEN 3
          WHEN platelet_min < 100 THEN 2
          WHEN platelet_min < 150 THEN 1
          WHEN platelet_min IS NULL THEN NULL
          ELSE 0
        END AS SMALLINT
      ) AS coagulation

    -- Liver (bilirubin mg/dL)
    , CAST(
        CASE
          WHEN bilirubin_max >= 12.0 THEN 4
          WHEN bilirubin_max >= 6.0  THEN 3
          WHEN bilirubin_max >= 2.0  THEN 2
          WHEN bilirubin_max >= 1.2  THEN 1
          WHEN bilirubin_max IS NULL THEN NULL
          ELSE 0
        END AS SMALLINT
      ) AS liver

    -- Cardiovascular
    , CAST(
        CASE
          WHEN rate_dopamine > 15 OR rate_epinephrine > 0.1 OR rate_norepinephrine > 0.1 THEN 4
          WHEN rate_dopamine >  5 OR rate_epinephrine <= 0.1 OR rate_norepinephrine <= 0.1 THEN 3
          WHEN rate_dopamine >  0 OR rate_dobutamine > 0 THEN 2
          WHEN meanbp_min < 70 THEN 1
          WHEN COALESCE(meanbp_min, rate_dopamine, rate_dobutamine, rate_epinephrine, rate_norepinephrine) IS NULL THEN NULL
          ELSE 0
        END AS SMALLINT
      ) AS cardiovascular

    -- CNS (GCS)
    , CAST(
        CASE
          WHEN (gcs_min >= 13 AND gcs_min <= 14) THEN 1
          WHEN (gcs_min >= 10 AND gcs_min <= 12) THEN 2
          WHEN (gcs_min >=  6 AND gcs_min <=  9) THEN 3
          WHEN  gcs_min < 6 THEN 4
          WHEN  gcs_min IS NULL THEN NULL
          ELSE 0
        END AS SMALLINT
      ) AS cns

    -- Renal (creatinine or urine output)
    , CAST(
        CASE
          WHEN creatinine_max >= 5.0 THEN 4
          WHEN SUM(urineoutput) OVER w < 200 THEN 4
          WHEN (creatinine_max >= 3.5 AND creatinine_max < 5.0) THEN 3
          WHEN SUM(urineoutput) OVER w < 500 THEN 3
          WHEN (creatinine_max >= 2.0 AND creatinine_max < 3.5) THEN 2
          WHEN (creatinine_max >= 1.2 AND creatinine_max < 2.0) THEN 1
          WHEN COALESCE(SUM(urineoutput) OVER w, creatinine_max) IS NULL THEN NULL
          ELSE 0
        END AS SMALLINT
      ) AS renal

  FROM scorecomp
  WINDOW w AS
  (
    PARTITION BY icustay_id
    ORDER BY hr
    ROWS BETWEEN 23 PRECEDING AND CURRENT ROW
  )
)
, score_final AS
(
  SELECT
      s.*

    -- 24h rolling max for each component (impute 0 if missing)
    , CAST(COALESCE(
        MAX(respiration) OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
      , 0) AS SMALLINT) AS respiration_24hours

    , CAST(COALESCE(
        MAX(coagulation) OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
      , 0) AS SMALLINT) AS coagulation_24hours

    , CAST(COALESCE(
        MAX(liver) OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
      , 0) AS SMALLINT) AS liver_24hours

    , CAST(COALESCE(
        MAX(cardiovascular) OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
      , 0) AS SMALLINT) AS cardiovascular_24hours

    , CAST(COALESCE(
        MAX(cns) OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
      , 0) AS SMALLINT) AS cns_24hours

    , CAST(COALESCE(
        MAX(renal) OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
      , 0) AS SMALLINT) AS renal_24hours

    -- total SOFA (sum of 24h rolling max components)
    , (
        COALESCE(MAX(respiration)     OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW), 0)
      + COALESCE(MAX(coagulation)     OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW), 0)
      + COALESCE(MAX(liver)           OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW), 0)
      + COALESCE(MAX(cardiovascular)  OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW), 0)
      + COALESCE(MAX(cns)             OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW), 0)
      + COALESCE(MAX(renal)           OVER (PARTITION BY icustay_id ORDER BY hr ROWS BETWEEN 24 PRECEDING AND CURRENT ROW), 0)
      )::SMALLINT AS sofa_24hours

  FROM scorecalc s
)
SELECT *
FROM score_final
WHERE hr >= 0
ORDER BY icustay_id, hr;

-- Suggested indexes (optional)
-- CREATE INDEX IF NOT EXISTS idx_pivoted_sofa_icustay_hr
--   ON mimiciii_derived.pivoted_sofa (icustay_id, hr);
-- CREATE INDEX IF NOT EXISTS idx_pivoted_sofa_icustay_endtime
--   ON mimiciii_derived.pivoted_sofa (icustay_id, endtime);
