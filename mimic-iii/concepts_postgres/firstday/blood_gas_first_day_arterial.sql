-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.blood_gas_first_day_arterial; CREATE TABLE mimiciii_derived.blood_gas_first_day_arterial AS
WITH stg_spo2 AS (
  SELECT
    subject_id,
    hadm_id,
    icustay_id,
    charttime, /* max here is just used to group SpO2 by charttime */
    MAX(CASE WHEN valuenum <= 0 OR valuenum > 100 THEN NULL ELSE valuenum END) AS SpO2
  FROM mimiciii.chartevents
  /* o2 sat */
  WHERE
    ITEMID IN (646, /* SpO2 */220277 /* O2 saturation pulseoxymetry */)
  GROUP BY
    subject_id,
    hadm_id,
    icustay_id,
    charttime
), stg_fio2 AS (
  SELECT
    subject_id,
    hadm_id,
    icustay_id,
    charttime, /* pre-process the FiO2s to ensure they are between 21-100% */
    MAX(
      CASE
        WHEN itemid = 223835
        THEN CASE
          WHEN valuenum > 0 AND valuenum <= 1
          THEN valuenum * 100
          WHEN valuenum > 1 AND valuenum < 21
          THEN NULL
          WHEN valuenum >= 21 AND valuenum <= 100
          THEN valuenum
          ELSE NULL
        END /* unphysiological */
        WHEN itemid IN (3420, 3422)
        THEN valuenum
        WHEN itemid = 190 AND valuenum > 0.20 AND valuenum < 1
        THEN valuenum * 100
        ELSE NULL
      END
    ) AS fio2_chartevents
  FROM mimiciii.chartevents
  WHERE
    ITEMID IN (
      3420, /* FiO2 */
      190, /* FiO2 set */
      223835, /* Inspired O2 Fraction (FiO2) */
      3422 /* FiO2 [measured] */
    )
    AND /* exclude rows marked as error */ (
      error IS NULL OR error = 0
    )
  GROUP BY
    subject_id,
    hadm_id,
    icustay_id,
    charttime
), stg2 AS (
  SELECT
    bg.*,
    ROW_NUMBER() OVER (PARTITION BY bg.icustay_id, bg.charttime ORDER BY s1.charttime DESC NULLS LAST) AS lastRowSpO2,
    s1.spo2
  FROM mimiciii_derived.blood_gas_first_day AS bg
  LEFT JOIN stg_spo2 AS s1
    ON bg.icustay_id = s1.icustay_id
    AND /* spo2 occurred at most 2 hours before this blood gas */ s1.charttime >= bg.charttime - INTERVAL '2' HOUR
    AND s1.charttime <= bg.charttime
  WHERE
    NOT bg.po2 IS NULL
), stg3 AS (
  SELECT
    bg.*,
    ROW_NUMBER() OVER (PARTITION BY bg.icustay_id, bg.charttime ORDER BY s2.charttime DESC NULLS LAST) AS lastRowFiO2,
    s2.fio2_chartevents, /* create our specimen prediction */
    CAST(1 AS DOUBLE PRECISION) / (
      1 + EXP(
        -(
          -0.02544 + 0.04598 * po2 + COALESCE(-0.15356 * spo2, -0.15356 * 97.49420 + 0.13429) + COALESCE(0.00621 * fio2_chartevents, 0.00621 * 51.49550 + -0.24958) + COALESCE(0.10559 * hemoglobin, 0.10559 * 10.32307 + 0.05954) + COALESCE(0.13251 * so2, 0.13251 * 93.66539 + -0.23172) + COALESCE(-0.01511 * pco2, -0.01511 * 42.08866 + -0.01630) + COALESCE(0.01480 * fio2, 0.01480 * 63.97836 + -0.31142) + COALESCE(-0.00200 * aado2, -0.00200 * 442.21186 + -0.01328) + COALESCE(-0.03220 * bicarbonate, -0.03220 * 22.96894 + -0.06535) + COALESCE(0.05384 * totalco2, 0.05384 * 24.72632 + -0.01405) + COALESCE(0.08202 * lactate, 0.08202 * 3.06436 + 0.06038) + COALESCE(0.10956 * ph, 0.10956 * 7.36233 + -0.00617) + COALESCE(0.00848 * o2flow, 0.00848 * 7.59362 + -0.35803)
        )
      )
    ) AS SPECIMEN_PROB
  FROM stg2 AS bg
  LEFT JOIN stg_fio2 AS s2
    ON bg.icustay_id = s2.icustay_id
    AND /* fio2 occurred at most 4 hours before this blood gas */ s2.charttime BETWEEN bg.charttime - INTERVAL '4' HOUR AND bg.charttime
  WHERE
    bg.lastRowSpO2 = 1 /* only the row with the most recent SpO2 (if no SpO2 found lastRowSpO2 = 1) */
)
SELECT
  subject_id,
  hadm_id,
  icustay_id,
  charttime,
  specimen, /* raw data indicating sample type, only present 80% of the time */ /* prediction of specimen for missing data */
  CASE
    WHEN NOT SPECIMEN IS NULL
    THEN SPECIMEN
    WHEN SPECIMEN_PROB > 0.75
    THEN 'ART'
    ELSE NULL
  END AS SPECIMEN_PRED,
  specimen_prob, /* oxygen related parameters */
  so2,
  spo2, /* note spo2 is FROM `physionet-data.mimiciii_clinical.chartevents` */
  po2,
  pco2,
  fio2_chartevents,
  fio2,
  aado2, /* also calculate AADO2 */
  CASE
    WHEN NOT PO2 IS NULL
    AND NOT pco2 IS NULL
    AND NOT COALESCE(fio2, fio2_chartevents) IS NULL
    THEN (
      CAST(COALESCE(fio2, fio2_chartevents) AS DOUBLE PRECISION) / 100
    ) * (
      760 - 47
    ) - (
      CAST(pco2 AS DOUBLE PRECISION) / 0.8
    ) - po2
    ELSE NULL
  END AS AADO2_calc,
  CASE
    WHEN NOT PO2 IS NULL AND NOT COALESCE(fio2, fio2_chartevents) IS NULL
    THEN CAST(100 * PO2 AS DOUBLE PRECISION) / (
      COALESCE(fio2, fio2_chartevents)
    )
    ELSE NULL
  END AS PaO2FiO2, /* acid-base parameters */
  ph,
  baseexcess,
  bicarbonate,
  totalco2, /* blood count parameters */
  hematocrit,
  hemoglobin,
  carboxyhemoglobin,
  methemoglobin, /* chemistry */
  chloride,
  calcium,
  temperature,
  potassium,
  sodium,
  lactate,
  glucose, /* ventilation stuff that's sometimes input */
  intubated,
  tidalvolume,
  ventilationrate,
  ventilator,
  peep,
  o2flow,
  requiredo2
FROM stg3
WHERE
  lastRowFiO2 = 1 /* only the most recent FiO2 */
  AND /* restrict it to *only* arterial samples */ (
    specimen = 'ART' OR specimen_prob > 0.75
  )
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST