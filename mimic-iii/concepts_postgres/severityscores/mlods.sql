-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.mlods; CREATE TABLE mimiciii_derived.mlods AS
/* ------------------------------------------------------------------ */ /* Title: Modified Logistic organ dysfunction system (mLODS) */ /* This query extracts a modified version of the logistic organ dysfunction system. */ /* This score was used in the third international definition of sepsis: Sepsis-3. */ /* This score is a measure of organ failure in a patient. */ /* ------------------------------------------------------------------ */ /* Reference for LODS: */ /*  Le Gall, J. R., Klar, J., Lemeshow, S., Saulnier, F., Alberti, C., Artigas, A., & Teres, D. */ /*  The Logistic Organ Dysfunction system: a new way to assess organ dysfunction in the intensive care unit. */ /*  JAMA 276.10 (1996): 802-810. */ /* Reference for modified LODS: */ /*  Le Gall, J. R., Klar, J., Lemeshow, S., Saulnier, F., Alberti, C., Artigas, A., & Teres, D. */ /*  The Logistic Organ Dysfunction system: a new way to assess organ dysfunction in the intensive care unit. */ /*  JAMA 276.10 (1996): 802-810. */ /* Variables used in mLODS: */ /*  GCS */ /*  VITALS: Heart rate, systolic blood pressure */ /*  FLAGS: ventilation/cpap */ /*  LABS: WBC, bilirubin, creatinine, platelets */ /*  ABG: PaO2 with associated FiO2 */ /* Variables *excluded*, that are used in the original LODS: */ /*  prothrombin time (PT), blood urea nitrogen, urine output */ /* Note: */ /*  The score is calculated for *all* ICU patients, with the assumption that the user will subselect appropriate ICUSTAY_IDs. */ /*  For example, the score is calculated for neonates, but it is likely inappropriate to actually use the score values for these patients. */ /* extract CPAP from the "Oxygen Delivery Device" fields */
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
    ON ie.icustay_id = ce.icustay_id AND ce.charttime BETWEEN ie.intime AND ie.outtime
  WHERE
    itemid IN (
      467, /* TODO: when metavision data import fixed, check the values in 226732 match the value clause below */
      469,
      226732
    )
    AND (
      LOWER(ce.value) LIKE '%cpap%' OR LOWER(ce.value) LIKE '%bipap mask%'
    )
    AND /* exclude rows marked as error */ (
      ce.error IS NULL OR ce.error = 0
    )
  GROUP BY
    ie.icustay_id
), pafi1 AS (
  /* join blood gas to ventilation durations to determine if patient was vent */ /* also join to cpap table for the same purpose */
  SELECT
    bg.icustay_id,
    bg.charttime,
    PaO2FiO2,
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
  /* get the minimum PaO2/FiO2 ratio *only for ventilated/cpap patients* */
  SELECT
    icustay_id,
    MIN(PaO2FiO2) AS PaO2FiO2_vent_min
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
    gcs.mingcs,
    vital.heartrate_max,
    vital.heartrate_min,
    vital.sysbp_max,
    vital.sysbp_min, /* this value is non-null iff the patient is on vent/cpap */
    pf.PaO2FiO2_vent_min,
    labs.wbc_max,
    labs.wbc_min,
    labs.bilirubin_max,
    labs.creatinine_max,
    labs.platelet_min
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.admissions AS adm
    ON ie.hadm_id = adm.hadm_id
  INNER JOIN mimiciii.patients AS pat
    ON ie.subject_id = pat.subject_id
  /* join to above view to get pao2/fio2 ratio */
  LEFT JOIN pafi2 AS pf
    ON ie.icustay_id = pf.icustay_id
  /* join to custom tables to get more data.... */
  LEFT JOIN mimiciii_derived.gcs_first_day AS gcs
    ON ie.icustay_id = gcs.icustay_id
  LEFT JOIN mimiciii_derived.vitals_first_day AS vital
    ON ie.icustay_id = vital.icustay_id
  LEFT JOIN mimiciii_derived.labs_first_day AS labs
    ON ie.icustay_id = labs.icustay_id
), scorecomp AS (
  SELECT
    cohort.*, /* neurologic */
    CASE
      WHEN mingcs IS NULL
      THEN NULL
      WHEN mingcs < 3
      THEN NULL /* erroneous value/on trach */
      WHEN mingcs <= 5
      THEN 5
      WHEN mingcs <= 8
      THEN 3
      WHEN mingcs <= 13
      THEN 1
      ELSE 0
    END AS neurologic, /* cardiovascular */
    CASE
      WHEN heartrate_max IS NULL AND sysbp_min IS NULL
      THEN NULL
      WHEN heartrate_min < 30
      THEN 5
      WHEN sysbp_min < 40
      THEN 5
      WHEN sysbp_min < 70
      THEN 3
      WHEN sysbp_max >= 270
      THEN 3
      WHEN heartrate_max >= 140
      THEN 1
      WHEN sysbp_max >= 240
      THEN 1
      WHEN sysbp_min < 90
      THEN 1
      ELSE 0
    END AS cardiovascular, /* renal */
    CASE
      WHEN creatinine_max IS NULL
      THEN NULL
      WHEN creatinine_max >= 1.60
      THEN 3
      WHEN creatinine_max >= 1.20
      THEN 1
      ELSE 0
    END AS renal, /* pulmonary */
    CASE
      WHEN PaO2FiO2_vent_min IS NULL
      THEN 0
      WHEN PaO2FiO2_vent_min >= 150
      THEN 1
      WHEN PaO2FiO2_vent_min < 150
      THEN 3
      ELSE NULL
    END AS pulmonary, /* hematologic */
    CASE
      WHEN wbc_max IS NULL AND platelet_min IS NULL
      THEN NULL
      WHEN wbc_min < 1.0
      THEN 3
      WHEN wbc_min < 2.5
      THEN 1
      WHEN platelet_min < 50.0
      THEN 1
      WHEN wbc_max >= 50.0
      THEN 1
      ELSE 0
    END AS hematologic, /* hepatic */
    CASE WHEN bilirubin_max IS NULL THEN NULL WHEN bilirubin_max >= 2.0 THEN 1 ELSE 0 END AS hepatic
  FROM cohort
)
SELECT
  ie.icustay_id, /* coalesce statements impute normal score of zero if data element is missing */
  COALESCE(neurologic, 0) + COALESCE(cardiovascular, 0) + COALESCE(renal, 0) + COALESCE(pulmonary, 0) + COALESCE(hematologic, 0) + COALESCE(hepatic, 0) AS mLODS,
  neurologic,
  cardiovascular,
  renal,
  pulmonary,
  hematologic,
  hepatic
FROM mimiciii.icustays AS ie
LEFT JOIN scorecomp AS s
  ON ie.icustay_id = s.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST