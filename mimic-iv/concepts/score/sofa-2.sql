-- ------------------------------------------------------------------
-- Title: Sequential Organ Failure Assessment 2.0 (SOFA-2)
-- Author: Rasoul Samei (Contributor to the original SOFA-2 publication)
-- 
-- Description: Extracts the hourly SOFA-2 score, including the 24-hour 
--              rolling maximums for each organ system component.
--
-- Note on Methodology: Scored hourly, using max over last 24h.
-- Source for thresholds/rules: SOFA-2 Table 2 + footnotes.
-- Reference: doi:10.1001/jama.2025.20516
-- ------------------------------------------------------------------

WITH co AS (
    SELECT ih.stay_id, ie.hadm_id
        , hr
        , TIMESTAMP_SUB(ih.endtime, INTERVAL '1' HOUR) AS starttime
        , ih.endtime
    FROM `mimic-iv-data.mimiciv_derived.icustay_hourly` ih
    INNER JOIN `mimic-iv-data.mimiciv_icu.icustays` ie
        ON ih.stay_id = ie.stay_id
)
-- ========= SpO2/FiO2 fallback (SOFA-2 respiratory) =========
, spo2_obs AS (
  SELECT
    stay_id,
    charttime,
    spo2
  FROM `mimic-iv-data.mimiciv_derived.vitalsign`
  WHERE charttime IS NOT NULL
    AND spo2 IS NOT NULL
    AND spo2 < 98   -- SOFA-2 rule: only use S/F when SpO2 < 98%
)

, fio2_obs AS (
  SELECT
    stay_id,
    charttime,
    -- normalize FiO2 to a fraction (0.21–1.0)
    CASE
      WHEN fio2 IS NULL THEN NULL
      WHEN fio2 > 1.0 THEN fio2/100.0
      ELSE fio2
    END AS fio2_frac
  FROM `mimic-iv-data.mimiciv_derived.ventilator_setting`
  WHERE charttime IS NOT NULL
    AND fio2 IS NOT NULL
)

, sf_inst AS (
  -- pair SpO2 and FiO2 close in time (±60 minutes)
  SELECT
    s.stay_id,
    s.charttime AS spo2_time,
    f.charttime AS fio2_time,
    s.spo2,
    f.fio2_frac,
    SAFE_DIVIDE(s.spo2, f.fio2_frac) AS spo2fio2ratio
  FROM spo2_obs s
  JOIN fio2_obs f
    ON s.stay_id = f.stay_id
   AND ABS(TIMESTAMP_DIFF(TIMESTAMP(s.charttime), TIMESTAMP(f.charttime), MINUTE)) <= 60
  WHERE f.fio2_frac BETWEEN 0.21 AND 1.00
)

, sf AS (
  -- hourly min S/F ratio (lower is worse)
  SELECT
    co.stay_id,
    co.hr,
    MIN(sf_inst.spo2fio2ratio) AS spo2fio2ratio_min
  FROM co
  LEFT JOIN sf_inst
    ON co.stay_id = sf_inst.stay_id
   AND co.starttime <= sf_inst.spo2_time
   AND co.endtime > sf_inst.spo2_time
  GROUP BY co.stay_id, co.hr
)
-- ========= Respiratory support flags (SOFA-2 “advanced ventilatory support” + ECMO) =========
-- Advanced ventilatory support includes: HFNC, CPAP, BiPAP/NIV, invasive MV, long-term home ventilation.
-- ECMO (all forms) scores 4 if used for respiratory failure.
, vent_support AS (
    SELECT
        vd.stay_id
        , vd.starttime
        , vd.endtime
        , CASE
            WHEN LOWER(vd.ventilation_status) LIKE '%invasive%' THEN 1
            WHEN LOWER(vd.ventilation_status) LIKE '%noninvasive%' THEN 1
            WHEN LOWER(vd.ventilation_status) LIKE '%niv%' THEN 1
            WHEN LOWER(vd.ventilation_status) LIKE '%bipap%' THEN 1
            WHEN LOWER(vd.ventilation_status) LIKE '%cpap%' THEN 1
            WHEN LOWER(vd.ventilation_status) LIKE '%high flow%' THEN 1
            WHEN LOWER(vd.ventilation_status) LIKE '%hfnc%' THEN 1
            WHEN LOWER(vd.ventilation_status) LIKE '%home%' THEN 1
            ELSE 0
          END AS advanced_vent
    FROM `mimic-iv-data.mimiciv_derived.ventilation` vd
)
-- =============== ECMO support from CHARTEVENTS ===============

, vv_ecmo_events AS (
  SELECT
    ce.stay_id,
    ce.charttime
  FROM `mimic-iv-data.mimiciv_icu.chartevents` ce
  WHERE ce.charttime IS NOT NULL
    AND ce.itemid = 229268              -- Circuit Configuration (ECMO)
    AND LOWER(COALESCE(ce.value,'')) IN ('vv','va','vav')
)

, ecmo_hourly AS (
  SELECT
    co.stay_id,
    co.hr,
    1 AS ecmo_any
  FROM co
  JOIN vv_ecmo_events e
    ON co.stay_id = e.stay_id
   AND e.charttime >= co.starttime
   AND e.charttime <  co.endtime
  GROUP BY co.stay_id, co.hr
)
-- ========= PaO2/FiO2 extraction (same pattern as your query) =========
, pafi AS (
    SELECT ie.stay_id
        , bg.charttime
        , bg.pao2fio2ratio
        , MAX(CASE WHEN vs.advanced_vent = 1 THEN 1 ELSE 0 END) AS advanced_vent_now
    FROM `mimic-iv-data.mimiciv_icu.icustays` ie
    INNER JOIN `mimic-iv-data.mimiciv_derived.bg` bg
        ON ie.hadm_id = bg.hadm_id
    LEFT JOIN vent_support vs
        ON ie.stay_id = vs.stay_id
        AND bg.charttime >= vs.starttime
        AND bg.charttime < vs.endtime
    WHERE bg.specimen = 'ART.'
    GROUP BY ie.stay_id, bg.charttime, bg.pao2fio2ratio
)

, pf AS (
    SELECT co.stay_id, co.hr
        , MIN(pafi.pao2fio2ratio) AS pao2fio2ratio_min
        , MAX(pafi.advanced_vent_now) AS advanced_vent_any
    FROM co
    LEFT JOIN pafi
        ON co.stay_id = pafi.stay_id
        AND pafi.charttime >= co.starttime
        AND pafi.charttime <  co.endtime
    GROUP BY co.stay_id, co.hr
)
-- ========= Vitals / labs=========
, vs AS (
    SELECT co.stay_id, co.hr
        , MIN(vs.mbp) AS meanbp_min
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.vitalsign` vs
        ON co.stay_id = vs.stay_id
        AND co.starttime <= vs.charttime
        AND co.endtime > vs.charttime
    GROUP BY co.stay_id, co.hr
)
-- ========= Sedation timing for SOFA-2 brain (footnote c) =========
, sedative_itemids AS (
  SELECT itemid
  FROM `mimic-iv-data.mimiciv_icu.d_items`
  WHERE REGEXP_CONTAINS(LOWER(label), r'\b(propofol|midazolam|lorazepam|dexmedetomidine)\b')
)

, sedation_intervals AS (
  SELECT
    ie.stay_id,
    ie.starttime,
    ie.endtime
  FROM `mimic-iv-data.mimiciv_icu.inputevents` ie
  WHERE ie.stay_id IS NOT NULL
    AND ie.starttime IS NOT NULL
    AND ie.endtime IS NOT NULL
    AND ie.itemid IN (SELECT itemid FROM sedative_itemids)
)

, sed_start AS (
  SELECT
    stay_id,
    MIN(starttime) AS sed_starttime
  FROM sedation_intervals
  GROUP BY stay_id
)

, sedation_hourly AS (
  SELECT
    co.stay_id,
    co.hr,
    CASE WHEN COUNTIF(s.starttime < co.endtime AND s.endtime > co.starttime) > 0 THEN 1 ELSE 0 END AS sedated_hour
  FROM co
  LEFT JOIN sedation_intervals s
    ON co.stay_id = s.stay_id
  GROUP BY co.stay_id, co.hr
)
, gcs AS (
  -- Raw component events
  WITH gcs_components AS (
    SELECT
      ce.stay_id,
      ce.charttime,
      CASE WHEN ce.itemid = 223901 THEN SAFE_CAST(ce.valuenum AS INT64) END AS motor,
      CASE WHEN ce.itemid = 223900 THEN
        CASE
          WHEN LOWER(ce.value) = 'no response-ett' THEN NULL  -- cannot evaluate verbal
          ELSE SAFE_CAST(ce.valuenum AS INT64)
        END
      END AS verbal,
      CASE WHEN ce.itemid = 220739 THEN SAFE_CAST(ce.valuenum AS INT64) END AS eyes,
      CASE WHEN ce.itemid = 223900 AND LOWER(ce.value) = 'no response-ett' THEN 1 ELSE 0 END AS ett_flag
    FROM `mimic-iv-data.mimiciv_icu.chartevents` ce
    WHERE ce.stay_id IS NOT NULL
      AND ce.charttime IS NOT NULL
      AND ce.itemid IN (223901, 223900, 220739)
  ),

  -- Hourly observed total + best motor in the hour
  gcs_hourly_obs AS (
    SELECT
      co.stay_id,
      co.hr,
      MIN(
        CASE
          WHEN gc.motor IS NOT NULL AND gc.verbal IS NOT NULL AND gc.eyes IS NOT NULL
          THEN (gc.motor + gc.verbal + gc.eyes)
        END
      ) AS total_gcs_obs,
      MAX(gc.motor) AS motor_best,
      MAX(gc.ett_flag) AS gcs_unable_any
    FROM co
    LEFT JOIN gcs_components gc
      ON co.stay_id = gc.stay_id
     AND gc.charttime >= co.starttime
     AND gc.charttime <  co.endtime
    GROUP BY co.stay_id, co.hr
  ),

  -- Last recorded TOTAL GCS before sedation starttime (per stay)
  pre_sed AS (
    SELECT
      ss.stay_id,
      ARRAY_AGG(
        (gc.motor + gc.verbal + gc.eyes)
        ORDER BY gc.charttime DESC
        LIMIT 1
      )[SAFE_OFFSET(0)] AS pre_sed_total_gcs
    FROM sed_start ss
    JOIN gcs_components gc
      ON ss.stay_id = gc.stay_id
     AND gc.charttime < ss.sed_starttime
    WHERE gc.motor IS NOT NULL AND gc.verbal IS NOT NULL AND gc.eyes IS NOT NULL
    GROUP BY ss.stay_id
  )

  SELECT
    o.stay_id,
    o.hr,
    COALESCE(sh.sedated_hour, 0) AS sedated_hour,

    -- gcs_min kept for downstream compatibility:
    -- if sedated => last pre-sedation total GCS; else observed hourly total GCS
    CASE
      WHEN COALESCE(sh.sedated_hour,0) = 1 THEN ps.pre_sed_total_gcs
      ELSE o.total_gcs_obs
    END AS gcs_min,

    -- motor fallback (footnote d): best achieved motor in the hour
    o.motor_best AS gcs_motor_min,

    o.gcs_unable_any
  FROM gcs_hourly_obs o
  LEFT JOIN sedation_hourly sh
    ON o.stay_id = sh.stay_id AND o.hr = sh.hr
  LEFT JOIN pre_sed ps
    ON o.stay_id = ps.stay_id
)

, bili AS (
    SELECT co.stay_id, co.hr
        , MAX(enz.bilirubin_total) AS bilirubin_max
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.enzyme` enz
        ON co.hadm_id = enz.hadm_id
        AND co.starttime <= enz.charttime
        AND co.endtime > enz.charttime
    GROUP BY co.stay_id, co.hr
    
)

, cr AS (
    SELECT co.stay_id, co.hr
        , MAX(chem.creatinine) AS creatinine_max
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.chemistry` chem
        ON co.hadm_id = chem.hadm_id
        AND co.starttime <= chem.charttime
        AND co.endtime > chem.charttime
    GROUP BY co.stay_id, co.hr
)
-- ========= RRT eligibility labs for SOFA-2 kidney score 4 (footnote p) =========
-- Criteria (if NOT receiving RRT): (Cr >1.2 OR oliguria <0.3 mL/kg/h for >6h)
-- AND [K >= 6.0 OR (pH <= 7.20 AND HCO3 <= 12)]

, k_hco3 AS (
  SELECT
    co.stay_id,
    co.hr,
    MAX(chem.potassium)   AS potassium_max,
    MIN(chem.bicarbonate) AS bicarbonate_min
  FROM co
  LEFT JOIN `mimic-iv-data.mimiciv_derived.chemistry` chem
    ON co.hadm_id = chem.hadm_id
   AND co.starttime <= chem.charttime
   AND co.endtime > chem.charttime
  GROUP BY co.stay_id, co.hr
)

, ph_lab AS (
  SELECT
    co.stay_id,
    co.hr,
    MIN(bg.ph) AS ph_min
  FROM co
  LEFT JOIN `mimic-iv-data.mimiciv_derived.bg` bg
    ON co.hadm_id = bg.hadm_id
   AND co.starttime <= bg.charttime
   AND co.endtime > bg.charttime
  WHERE bg.ph IS NOT NULL
  GROUP BY co.stay_id, co.hr
)
, plt AS (
    SELECT co.stay_id, co.hr
        , MIN(cbc.platelet) AS platelet_min
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.complete_blood_count` cbc
        ON co.hadm_id = cbc.hadm_id
        AND cbc.charttime >= co.starttime
        AND cbc.charttime <  co.endtime
    GROUP BY co.stay_id, co.hr
)

-- ========= Urine output (SOFA-2: mL/kg/h windows using urine_output + weight_durations) =========

, wt_stay AS (
  SELECT
    stay_id,
    AVG(weight) AS avg_weight_kg
  FROM `mimic-iv-data.mimiciv_derived.weight_durations`
  WHERE weight IS NOT NULL AND weight > 0
  GROUP BY stay_id
)

, wt_hour AS (
  SELECT
    co.stay_id,
    co.hr,
    (ARRAY_AGG(wd.weight IGNORE NULLS ORDER BY wd.starttime DESC LIMIT 1))[SAFE_OFFSET(0)] AS weight_hour_kg
  FROM co
  LEFT JOIN `mimic-iv-data.mimiciv_derived.weight_durations` wd
    ON co.stay_id = wd.stay_id
   AND co.endtime > wd.starttime
   AND co.endtime < wd.endtime
  GROUP BY co.stay_id, co.hr
)

, wt AS (
  SELECT
    wh.stay_id,
    wh.hr,
    COALESCE(wh.weight_hour_kg, ws.avg_weight_kg) AS weight_kg
  FROM wt_hour wh
  LEFT JOIN wt_stay ws
    ON wh.stay_id = ws.stay_id
)
,uo AS (
  SELECT
    co.stay_id,
    co.hr,
    wt.weight_kg,

    SUM(CASE WHEN u.charttime >= DATETIME_SUB(co.endtime, INTERVAL 6 HOUR)
             AND u.charttime < co.endtime
             THEN u.urineoutput ELSE 0 END) AS uo_6h_ml,

    SUM(CASE WHEN u.charttime >= DATETIME_SUB(co.endtime, INTERVAL 12 HOUR)
             AND u.charttime < co.endtime
             THEN u.urineoutput ELSE 0 END) AS uo_12h_ml,

    SUM(CASE WHEN u.charttime >= DATETIME_SUB(co.endtime, INTERVAL 24 HOUR)
             AND u.charttime < co.endtime
             THEN u.urineoutput ELSE 0 END) AS uo_24h_ml,

    MAX(CASE WHEN u.charttime >= DATETIME_SUB(co.endtime, INTERVAL 6 HOUR)
             AND u.charttime < co.endtime THEN 1 ELSE 0 END) AS has_uo_meas_6h,

    MAX(CASE WHEN u.charttime >= DATETIME_SUB(co.endtime, INTERVAL 12 HOUR)
             AND u.charttime < co.endtime THEN 1 ELSE 0 END) AS has_uo_meas_12h,

    MAX(CASE WHEN u.charttime >= DATETIME_SUB(co.endtime, INTERVAL 24 HOUR)
             AND u.charttime < co.endtime THEN 1 ELSE 0 END) AS has_uo_meas_24h

  FROM co
  LEFT JOIN `mimic-iv-data.mimiciv_derived.urine_output` u
    ON co.stay_id = u.stay_id
   AND u.charttime > DATETIME_SUB(co.endtime, INTERVAL 24 HOUR)
   AND u.charttime <= co.endtime
  LEFT JOIN wt
    ON co.stay_id = wt.stay_id
   AND co.hr = wt.hr
  GROUP BY co.stay_id, co.hr, wt.weight_kg
),

uo_flags AS (
  SELECT
    stay_id,
    hr,
    uo_6h_ml,
    weight_kg,

    -- 6–12h: <0.5 mL/kg/h over last 6h
    CASE
      WHEN weight_kg IS NULL OR weight_kg <= 0 THEN NULL
      WHEN has_uo_meas_6h = 0 THEN NULL
      WHEN hr < 5 THEN NULL  -- need ≥6h history (hours 0..5)
      WHEN SAFE_DIVIDE(uo_6h_ml,  weight_kg * 6.0)  < 0.5
       AND (
            hr < 11
            OR has_uo_meas_12h = 0
            OR SAFE_DIVIDE(uo_12h_ml, weight_kg * 12.0) >= 0.5
           )
      THEN 1
      ELSE 0
    END AS uo_ml_kg_hr_6_12_flag,

    -- ≥12h: <0.5 mL/kg/h over last 12h
    CASE
      WHEN weight_kg IS NULL OR weight_kg <= 0 THEN NULL
      WHEN has_uo_meas_12h = 0 THEN NULL
      WHEN hr < 11 THEN NULL  -- need ≥12h history
      WHEN SAFE_DIVIDE(uo_12h_ml, weight_kg * 12.0) < 0.5 THEN 1
      ELSE 0
    END AS uo_ml_kg_hr_gt12_flag,

    -- ≥24h <0.3 mL/kg/h OR anuria ≥12h
    CASE
      WHEN weight_kg IS NULL OR weight_kg <= 0 THEN NULL

      -- anuria: 0 mL in last 12h (needs 12h window + any measurement)
      WHEN hr >= 11 AND has_uo_meas_12h = 1 AND uo_12h_ml = 0 THEN 1

      -- oliguria: <0.3 mL/kg/h over last 24h (needs 24h window + any measurement)
      WHEN hr >= 23 AND has_uo_meas_24h = 1
       AND SAFE_DIVIDE(uo_24h_ml, weight_kg * 24.0) < 0.3 THEN 1

      ELSE 0
    END AS uo_ml_kg_hr_gt24_or_anuria_flag

  FROM uo
)

-- ========= RRT flag (SOFA-2 kidney score 4 if receiving RRT; also has “eligible for RRT” rule) =========
, rrt AS (
  SELECT
      stay_id
    , charttime
    , CASE
        WHEN dialysis_active = 1 THEN 1
        WHEN dialysis_present = 1 THEN 1
      END AS on_rrt
    , dialysis_type
  FROM `mimic-iv-data.mimiciv_derived.rrt`
  WHERE charttime IS NOT NULL
)

-- =============== Delirium treatment from EMAR ===============
, delirium_meds AS (
  SELECT 'haloperidol' AS token UNION ALL
  SELECT 'quetiapine' UNION ALL
  SELECT 'olanzapine' UNION ALL
  SELECT 'risperidone' UNION ALL
  SELECT 'ziprasidone' UNION ALL
  SELECT 'chlorpromazine' UNION ALL
  SELECT 'dexmedetomidine' UNION ALL
  SELECT 'precedex'
)

, emar_filtered AS (
  SELECT
    i.stay_id,
    e.charttime,
    LOWER(COALESCE(e.medication, '')) AS med_text,
    LOWER(COALESCE(e.event_txt, '')) AS event_txt
  FROM `mimic-iv-data.mimiciv_icu.icustays` i
  INNER JOIN `mimic-iv-data.mimiciv_hosp.emar` e
    ON i.hadm_id = e.hadm_id
  WHERE e.charttime BETWEEN i.intime AND i.outtime
    AND (
      LOWER(COALESCE(e.event_txt,'')) LIKE '%admin%'
      OR LOWER(COALESCE(e.event_txt,'')) LIKE '%started%'
      OR LOWER(COALESCE(e.event_txt,'')) LIKE '%new bag%'
      OR LOWER(COALESCE(e.event_txt,'')) LIKE '%confirmed%'
    )
    AND LOWER(COALESCE(e.event_txt,'')) NOT LIKE '%not given%'
    AND LOWER(COALESCE(e.event_txt,'')) NOT LIKE '%not started%'
    AND LOWER(COALESCE(e.event_txt,'')) NOT LIKE '%not confirmed%' 
    AND LOWER(COALESCE(e.event_txt,'')) NOT LIKE '%held%'
    AND LOWER(COALESCE(e.event_txt,'')) NOT LIKE '%hold%'
    AND LOWER(COALESCE(e.event_txt,'')) NOT LIKE '%refused%'
)

, delirium_tx AS (
  SELECT
    stay_id,
    charttime,
    1 AS delirium_treated
  FROM emar_filtered m
  WHERE EXISTS (
    SELECT 1
    FROM delirium_meds d
    WHERE LOWER(m.med_text) LIKE CONCAT('%', LOWER(d.token), '%')
  )
)

-- ========== Other vaso/inotrope hourly flag (SOFA-2) ==========
, other_vaso_inotrope AS (
  SELECT
    stay_id,
    hr,
    MAX(flag) AS other_vaso_inotrope_flag
  FROM (

    -- Vasopressin
    SELECT
      co.stay_id,
      co.hr,
      MAX(CASE WHEN vp.vaso_rate IS NOT NULL AND vp.vaso_rate > 0 THEN 1 ELSE 0 END) AS flag
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.vasopressin` vp
      ON co.stay_id = vp.stay_id
      AND TIMESTAMP_DIFF(
       LEAST(vp.endtime, co.endtime),
       GREATEST(vp.starttime, co.starttime),
       MINUTE
     ) >= 60
    GROUP BY co.stay_id, co.hr

    UNION ALL

    -- Phenylephrine
    SELECT
      co.stay_id,
      co.hr,
      MAX(CASE WHEN phe.vaso_rate IS NOT NULL AND phe.vaso_rate > 0 THEN 1 ELSE 0 END) AS flag
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.phenylephrine` phe
      ON co.stay_id = phe.stay_id
      AND TIMESTAMP_DIFF(
       LEAST(phe.endtime, co.endtime),
       GREATEST(phe.starttime, co.starttime),
       MINUTE
     ) >= 60
    GROUP BY co.stay_id, co.hr

    UNION ALL

    SELECT
      co.stay_id,
      co.hr,
      MAX(CASE WHEN mil.vaso_rate IS NOT NULL AND mil.vaso_rate > 0 THEN 1 ELSE 0 END) AS flag
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.milrinone` mil
      ON co.stay_id = mil.stay_id
      AND TIMESTAMP_DIFF(
       LEAST(mil.endtime, co.endtime),
       GREATEST(mil.starttime, co.starttime),
       MINUTE
     ) >= 60
    GROUP BY co.stay_id, co.hr

  )
  GROUP BY stay_id, hr
)

-- ========== VA-ECMO detection for cardiovascular mechanical support ==========
, ecmo_circuit_item AS (
  SELECT itemid
  FROM `mimic-iv-data.mimiciv_icu.d_items`
  WHERE LOWER(label) = 'circuit configuration (ecmo)'
  LIMIT 1
)

, va_ecmo_events AS (
  SELECT
    ce.stay_id,
    ce.charttime
  FROM `mimic-iv-data.mimiciv_icu.chartevents` ce
  WHERE ce.charttime IS NOT NULL
    AND ce.itemid IN (SELECT itemid FROM ecmo_circuit_item)
    AND LOWER(COALESCE(ce.value,'')) IN ('va', 'vav') 
)

, va_ecmo_hourly AS (
  SELECT
    co.stay_id,
    co.hr,
    1 AS va_ecmo_flag
  FROM co
  JOIN va_ecmo_events e
    ON co.stay_id = e.stay_id
   AND co.starttime <= e.charttime
   AND co.endtime   > e.charttime
  GROUP BY co.stay_id, co.hr
)
-- ========== Mechanical circulatory support (MCS) for SOFA-2 cardiovascular ==========
-- Includes IABP/Impella/LVAD/VAD + VA-ECMO (from circuit configuration)

, mcs_itemids AS (
  SELECT itemid
  FROM `mimic-iv-data.mimiciv_icu.d_items`
  WHERE
       LOWER(label) LIKE '%iabp%'
    OR LOWER(label) LIKE '%impella%'
    OR LOWER(label) LIKE '%lvad%'
    OR LOWER(label) LIKE '% vad%'
)

, mcs_device_events AS (
  SELECT
    ce.stay_id,
    ce.charttime
  FROM `mimic-iv-data.mimiciv_icu.chartevents` ce
  WHERE ce.charttime IS NOT NULL
    AND ce.itemid IN (SELECT itemid FROM mcs_itemids)
)

, mcs_hourly AS (
  SELECT
    co.stay_id,
    co.hr,
    1 AS mechanical_support_flag
  FROM co
  LEFT JOIN mcs_device_events d
    ON co.stay_id = d.stay_id
   AND d.charttime >= co.starttime AND d.charttime < co.endtime
  LEFT JOIN va_ecmo_hourly va
    ON co.stay_id = va.stay_id
   AND co.hr = va.hr
  WHERE d.charttime IS NOT NULL OR va.va_ecmo_flag = 1
  GROUP BY co.stay_id, co.hr
)
, vaso AS (
    SELECT
        co.stay_id
        , co.hr
        , MAX(epi.vaso_rate) AS rate_epinephrine_ugkgmin
        , MAX(nor.vaso_rate) AS rate_norepinephrine_ugkgmin
        , MAX(dop.vaso_rate) AS rate_dopamine_mcgkgmin
        , MAX(dob.vaso_rate) AS rate_dobutamine -- treat as “other inotrope”
        , COALESCE(MAX(ov.other_vaso_inotrope_flag), 0) AS other_vaso_inotrope_flag
        , COALESCE(MAX(mcs.mechanical_support_flag), 0) AS mechanical_support_flag
    FROM co
    LEFT JOIN `mimic-iv-data.mimiciv_derived.epinephrine` epi
        ON co.stay_id = epi.stay_id AND TIMESTAMP_DIFF(
       LEAST(epi.endtime, co.endtime),
       GREATEST(epi.starttime, co.starttime),
       MINUTE
     ) >= 60
    LEFT JOIN `mimic-iv-data.mimiciv_derived.norepinephrine` nor
        ON co.stay_id = nor.stay_id AND TIMESTAMP_DIFF(
       LEAST(nor.endtime, co.endtime),
       GREATEST(nor.starttime, co.starttime),
       MINUTE
     ) >= 60
    LEFT JOIN `mimic-iv-data.mimiciv_derived.dopamine` dop
        ON co.stay_id = dop.stay_id AND TIMESTAMP_DIFF(
       LEAST(dop.endtime, co.endtime),
       GREATEST(dop.starttime, co.starttime),
       MINUTE
     ) >= 60
    LEFT JOIN `mimic-iv-data.mimiciv_derived.dobutamine` dob
        ON co.stay_id = dob.stay_id AND TIMESTAMP_DIFF(
       LEAST(dob.endtime, co.endtime),
       GREATEST(dob.starttime, co.starttime),
       MINUTE
     ) >= 60
    LEFT JOIN other_vaso_inotrope ov ON co.stay_id = ov.stay_id AND co.hr = ov.hr
    LEFT JOIN mcs_hourly mcs ON co.stay_id = mcs.stay_id AND co.hr = mcs.hr
    GROUP BY co.stay_id, co.hr
)

, scorecomp AS (
    SELECT
        co.stay_id, co.hr, co.starttime, co.endtime
        , pf.pao2fio2ratio_min
        , pf.advanced_vent_any
        -- , pf.ecmo_any
        , vs.meanbp_min
        , gcs.gcs_min
        , gcs.gcs_motor_min
        , gcs.gcs_unable_any
        , bili.bilirubin_max
        , cr.creatinine_max
        , plt.platelet_min
        , vaso.rate_epinephrine_ugkgmin
        , vaso.rate_norepinephrine_ugkgmin
        , vaso.rate_dopamine_mcgkgmin
        , vaso.rate_dobutamine
        , vaso.other_vaso_inotrope_flag
        , vaso.mechanical_support_flag
        , MAX(rrt.on_rrt) AS on_rrt_any
        , MAX(del.delirium_treated) AS delirium_treated_any
        , MAX(uo.uo_ml_kg_hr_6_12_flag) AS uo_6_12_flag
        , MAX(uo.uo_ml_kg_hr_gt12_flag) AS uo_gt12_flag
        , MAX(uo.uo_ml_kg_hr_gt24_or_anuria_flag) AS uo_gt24_or_anuria_flag
        , COALESCE(MAX(eh.ecmo_any), 0) AS ecmo_any
        , MIN(sf.spo2fio2ratio_min) AS spo2fio2ratio_min
        , MAX(kh.potassium_max)
        , MIN(kh.bicarbonate_min)
        , MIN(ph.ph_min)
        , MAX(uo.uo_6h_ml) AS uo_6h_ml
        , gcs.sedated_hour

        , CASE
            
            WHEN (MAX(cr.creatinine_max) IS NULL AND MAX(uo.uo_6h_ml) IS NULL) THEN 0

            WHEN (
                -- renal dysfunction trigger (SOFA-2 footnote p): Cr > 1.2 OR oliguria <0.3 mL/kg/h for >6h
                (MAX(cr.creatinine_max) > 1.2)
                OR (
                    MAX(uo.weight_kg) IS NOT NULL AND MAX(uo.weight_kg) > 0
                    AND co.hr >= 5
                    AND SAFE_DIVIDE(MAX(uo.uo_6h_ml), MAX(uo.weight_kg) * 6.0) < 0.3
                )
                )
            AND (
                -- severity trigger: K >= 6 OR (pH <= 7.20 AND HCO3 <= 12)
                MAX(kh.potassium_max) >= 6.0
                OR (MIN(ph.ph_min) <= 7.20 AND MIN(kh.bicarbonate_min) <= 12.0)
                )
            THEN 1
            ELSE 0
        END AS rrt_eligible_flag
    FROM co
    LEFT JOIN pf  ON co.stay_id = pf.stay_id  AND co.hr = pf.hr
    LEFT JOIN ecmo_hourly eh ON co.stay_id = eh.stay_id AND co.hr = eh.hr
    LEFT JOIN vs  ON co.stay_id = vs.stay_id  AND co.hr = vs.hr
    LEFT JOIN gcs ON co.stay_id = gcs.stay_id AND co.hr = gcs.hr
    LEFT JOIN bili ON co.stay_id = bili.stay_id AND co.hr = bili.hr
    LEFT JOIN cr   ON co.stay_id = cr.stay_id   AND co.hr = cr.hr
    LEFT JOIN plt  ON co.stay_id = plt.stay_id  AND co.hr = plt.hr
    LEFT JOIN vaso ON co.stay_id = vaso.stay_id AND co.hr = vaso.hr
    LEFT JOIN rrt ON co.stay_id = rrt.stay_id AND rrt.charttime >= co.starttime 
                                            AND rrt.charttime < co.endtime 
    LEFT JOIN delirium_tx del
        ON co.stay_id = del.stay_id AND del.charttime >= co.starttime 
                                    AND del.charttime < co.endtime
    LEFT JOIN uo_flags uo ON co.stay_id = uo.stay_id AND co.hr = uo.hr
    LEFT JOIN sf ON co.stay_id = sf.stay_id AND co.hr = sf.hr
    LEFT JOIN k_hco3 kh ON co.stay_id = kh.stay_id AND co.hr = kh.hr
    LEFT JOIN ph_lab ph ON co.stay_id = ph.stay_id AND co.hr = ph.hr
    GROUP BY
        co.stay_id, co.hr, co.starttime, co.endtime,
        pf.pao2fio2ratio_min, pf.advanced_vent_any, --pf.ecmo_any,
        vs.meanbp_min, gcs.gcs_min, gcs.gcs_motor_min, gcs.gcs_unable_any, gcs.sedated_hour,
        bili.bilirubin_max, cr.creatinine_max, plt.platelet_min,
        vaso.rate_epinephrine_ugkgmin, vaso.rate_norepinephrine_ugkgmin,
        vaso.rate_dopamine_mcgkgmin, vaso.rate_dobutamine,
        vaso.other_vaso_inotrope_flag, vaso.mechanical_support_flag
)

, scorecalc AS (
    SELECT s.*

    -- ===================== Respiratory (SOFA-2) =====================
    , CASE

    -- ECMO always respiratory = 4
    WHEN ecmo_any = 1 THEN 4

    -- Prefer PaO2/FiO2 when available
    WHEN pao2fio2ratio_min IS NOT NULL THEN
      CASE
        WHEN advanced_vent_any = 1 AND pao2fio2ratio_min <= 75 THEN 4
        WHEN advanced_vent_any = 1 AND pao2fio2ratio_min <= 150 THEN 3
        WHEN pao2fio2ratio_min <= 225 THEN 2
        WHEN pao2fio2ratio_min <= 300 THEN 1
        ELSE 0
      END

    -- Fallback SpO2/FiO2
    WHEN spo2fio2ratio_min IS NOT NULL THEN
      CASE
        WHEN advanced_vent_any = 1 AND spo2fio2ratio_min <= 120 THEN 4
        WHEN advanced_vent_any = 1 AND spo2fio2ratio_min <= 200 THEN 3
        WHEN spo2fio2ratio_min <= 250 THEN 2
        WHEN spo2fio2ratio_min <= 300 THEN 1
        ELSE 0
      END

    ELSE NULL
  END AS respiration
    -- ===================== Hemostasis (platelets, SOFA-2) =====================
    -- 0: >150; 1: <=150; 2: <=100; 3: <=80; 4: <=50 (x10^3/µL) 
    , CASE
        WHEN platelet_min <= 50 THEN 4
        WHEN platelet_min <= 80 THEN 3
        WHEN platelet_min <= 100 THEN 2
        WHEN platelet_min <= 150 THEN 1
        WHEN platelet_min IS NULL THEN NULL
        ELSE 0
      END AS hemostasis

    -- ===================== Liver (bilirubin, SOFA-2) =====================
    -- 0: <1.2; 1: <3; 2: <6; 3: <12; 4: >=12 (mg/dL) 
    , CASE
        WHEN bilirubin_max > 12.0 THEN 4
        WHEN bilirubin_max > 6.0 THEN 3
        WHEN bilirubin_max > 3.0 THEN 2
        WHEN bilirubin_max > 1.2 THEN 1
        WHEN bilirubin_max IS NULL THEN NULL
        ELSE 0
      END AS liver

    -- ===================== Brain (SOFA-2) =====================
    -- 0: GCS 15; 1: 13-14 OR delirium treated; 2: 9-12; 3: 6-8; 4: 3-5 
    , CASE
        -- Footnote c: if sedated and previous GCS unknown -> score 0
        WHEN sedated_hour = 1 AND gcs_min IS NULL THEN 0

        -- Footnote e: delirium treatment -> score at least 1 (even if GCS 15 / motor 6)
        WHEN delirium_treated_any = 1 THEN
        CASE
            WHEN gcs_min BETWEEN 3 AND 5 THEN 4
            WHEN gcs_min BETWEEN 6 AND 8 THEN 3
            WHEN gcs_min BETWEEN 9 AND 12 THEN 2
            WHEN gcs_min BETWEEN 13 AND 14 THEN 1
            WHEN gcs_min = 15 THEN 1

            -- Footnote d motor fallback if total unavailable
            WHEN gcs_motor_min <= 2 THEN 4
            WHEN gcs_motor_min = 3 THEN 3
            WHEN gcs_motor_min = 4 THEN 2
            WHEN gcs_motor_min = 5 THEN 1
            WHEN gcs_motor_min = 6 THEN 1
            ELSE 1
        END

        -- Total GCS available
        WHEN gcs_min IS NOT NULL THEN
        CASE
            WHEN gcs_min BETWEEN 3 AND 5 THEN 4
            WHEN gcs_min BETWEEN 6 AND 8 THEN 3
            WHEN gcs_min BETWEEN 9 AND 12 THEN 2
            WHEN gcs_min BETWEEN 13 AND 14 THEN 1
            WHEN gcs_min = 15 THEN 0
            ELSE NULL
        END

        -- Footnote d: cannot evaluate all 3 domains -> best achieved motor
        WHEN gcs_motor_min IS NOT NULL THEN
        CASE
            WHEN gcs_motor_min <= 2 THEN 4
            WHEN gcs_motor_min = 3 THEN 3
            WHEN gcs_motor_min = 4 THEN 2
            WHEN gcs_motor_min = 5 THEN 1
            WHEN gcs_motor_min = 6 THEN 0
            ELSE NULL
        END

        ELSE NULL
    END AS brain
    -- ===================== Cardiovascular (SOFA-2) =====================
    -- 0: MAP >=70 and no vaso/inotrope
    -- 1: MAP <70 and no vaso/inotrope
    -- 2: low-dose norepi+epi (<=0.2 µg/kg/min) OR any dose other vaso/inotrope OR dopamine-only <=20
    -- 3: (0.2,0.4] OR low-dose + any other vaso/inotrope OR dopamine-only (20,40]
    -- 4: >0.4 OR medium + any other vaso/inotrope OR mechanical support OR dopamine-only >40
    , CASE
        WHEN mechanical_support_flag = 1 THEN 4
        WHEN (
            -- dopamine-only path (must be sole vaso)
            rate_dopamine_mcgkgmin > 0
            AND COALESCE(rate_norepinephrine_ugkgmin,0) = 0
            AND COALESCE(rate_epinephrine_ugkgmin,0) = 0
            AND COALESCE(rate_dobutamine,0) = 0
            AND COALESCE(other_vaso_inotrope_flag,0) = 0
        ) THEN
            CASE
              WHEN rate_dopamine_mcgkgmin > 40 THEN 4
              WHEN rate_dopamine_mcgkgmin > 20 THEN 3
              ELSE 2
            END
        ELSE
          -- norepi+epi sum path
          CASE
            WHEN (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) > 0.4
              THEN 4
            WHEN (
              (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) > 0.2
              AND (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) <= 0.4
              AND (COALESCE(other_vaso_inotrope_flag,0) = 1 OR COALESCE(rate_dobutamine,0) > 0)
            ) THEN 4
            WHEN (
              (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) > 0.2
              AND (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) <= 0.4
            ) THEN 3
            WHEN (
              (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) <= 0.2
              AND (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) > 0
              AND (COALESCE(other_vaso_inotrope_flag,0) = 1 OR COALESCE(rate_dobutamine,0) > 0)
            ) THEN 3
            WHEN (
              (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) <= 0.2
              AND (COALESCE(rate_norepinephrine_ugkgmin,0) + COALESCE(rate_epinephrine_ugkgmin,0)) > 0
            ) THEN 2
            WHEN (COALESCE(other_vaso_inotrope_flag,0) = 1 OR COALESCE(rate_dobutamine,0) > 0) THEN 2
            WHEN meanbp_min < 70
                AND rate_norepinephrine_ugkgmin IS NULL
                AND rate_epinephrine_ugkgmin IS NULL
                AND rate_dopamine_mcgkgmin IS NULL
                AND rate_dobutamine IS NULL
                AND COALESCE(other_vaso_inotrope_flag,0) = 0
                THEN 1
            WHEN meanbp_min < 70 THEN 1
            WHEN meanbp_min IS NULL THEN NULL
            ELSE 0
          END
      END AS cardiovascular

    -- ===================== Kidney (SOFA-2) =====================
    -- 0: Cr <1.2
    -- 1: Cr <2.0 OR UO <0.5 mL/kg/h for 6-12h
    -- 2: Cr <3.5 OR UO <0.5 mL/kg/h for >12h
    -- 3: Cr >=3.5 OR UO <0.3 mL/kg/h for >24h OR anuria
    -- 4: Receiving (or fulfills criteria for) RRT 
    , CASE
        WHEN (on_rrt_any = 1 OR rrt_eligible_flag = 1) THEN 4
        WHEN uo_gt24_or_anuria_flag = 1 THEN 3
        WHEN creatinine_max > 3.5 THEN 3
        WHEN uo_gt12_flag = 1 THEN 2
        WHEN creatinine_max > 2.0 AND creatinine_max <= 3.5 THEN 2
        WHEN uo_6_12_flag = 1 THEN 1
        WHEN creatinine_max > 1.2 AND creatinine_max <= 2.0 THEN 1
        WHEN creatinine_max IS NULL AND on_rrt_any IS NULL
            AND uo_6_12_flag IS NULL AND uo_gt12_flag IS NULL AND uo_gt24_or_anuria_flag IS NULL
            AND rrt_eligible_flag IS NULL
            THEN NULL
        ELSE 0
        END AS kidney

    FROM scorecomp s
)

, score_final AS (
    SELECT s.*
        , COALESCE(MAX(respiration)     OVER w, 0) AS respiration_24hours
        , COALESCE(MAX(hemostasis)      OVER w, 0) AS hemostasis_24hours
        , COALESCE(MAX(liver)           OVER w, 0) AS liver_24hours
        , COALESCE(MAX(cardiovascular)  OVER w, 0) AS cardiovascular_24hours
        , COALESCE(MAX(brain)           OVER w, 0) AS brain_24hours
        , COALESCE(MAX(kidney)          OVER w, 0) AS kidney_24hours

        , COALESCE(MAX(respiration)     OVER w, 0)
        + COALESCE(MAX(hemostasis)      OVER w, 0)
        + COALESCE(MAX(liver)           OVER w, 0)
        + COALESCE(MAX(cardiovascular)  OVER w, 0)
        + COALESCE(MAX(brain)           OVER w, 0)
        + COALESCE(MAX(kidney)          OVER w, 0)
        AS sofa2_24hours
    FROM scorecalc s
    WINDOW w AS (
        PARTITION BY stay_id
        ORDER BY hr
        ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING
    )
)
SELECT *
FROM score_final
WHERE hr >= 0;