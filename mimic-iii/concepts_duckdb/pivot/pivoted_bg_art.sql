-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_bg_art; CREATE TABLE mimiciii_derived.pivoted_bg_art AS
WITH stg_spo2 AS (
  SELECT
    hadm_id,
    charttime,
    AVG(valuenum) AS spo2
  FROM mimiciii.chartevents
  WHERE
    ITEMID IN (646, 220277) AND valuenum > 0 AND valuenum <= 100
  GROUP BY
    hadm_id,
    charttime
), stg_fio2 AS (
  SELECT
    hadm_id,
    charttime,
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
        END
        WHEN itemid IN (3420, 3422)
        THEN valuenum
        WHEN itemid = 190 AND valuenum > 0.20 AND valuenum < 1
        THEN valuenum * 100
        ELSE NULL
      END
    ) AS fio2_chartevents
  FROM mimiciii.chartevents
  WHERE
    ITEMID IN (3420, 190, 223835, 3422)
    AND valuenum > 0
    AND valuenum < 100
    AND (
      error IS NULL OR error <> 1
    )
  GROUP BY
    hadm_id,
    charttime
), stg2 AS (
  SELECT
    bg.*,
    ROW_NUMBER() OVER (PARTITION BY bg.hadm_id, bg.charttime ORDER BY s1.charttime DESC) AS lastrowspo2,
    s1.spo2
  FROM mimiciii_derived.pivoted_bg AS bg
  LEFT JOIN stg_spo2 AS s1
    ON bg.hadm_id = s1.hadm_id
    AND s1.charttime BETWEEN bg.charttime - INTERVAL '2' HOUR AND bg.charttime
  WHERE
    NOT bg.po2 IS NULL
), stg3 AS (
  SELECT
    bg.*,
    ROW_NUMBER() OVER (PARTITION BY bg.hadm_id, bg.charttime ORDER BY s2.charttime DESC) AS lastrowfio2,
    s2.fio2_chartevents,
    1 / (
      1 + EXP(
        -(
          -0.02544 + 0.04598 * po2 + COALESCE(-0.15356 * spo2, -0.15356 * 97.49420 + 0.13429) + COALESCE(0.00621 * fio2_chartevents, 0.00621 * 51.49550 + -0.24958) + COALESCE(0.10559 * hemoglobin, 0.10559 * 10.32307 + 0.05954) + COALESCE(0.13251 * so2, 0.13251 * 93.66539 + -0.23172) + COALESCE(-0.01511 * pco2, -0.01511 * 42.08866 + -0.01630) + COALESCE(0.01480 * fio2, 0.01480 * 63.97836 + -0.31142) + COALESCE(-0.00200 * aado2, -0.00200 * 442.21186 + -0.01328) + COALESCE(-0.03220 * bicarbonate, -0.03220 * 22.96894 + -0.06535) + COALESCE(0.05384 * totalco2, 0.05384 * 24.72632 + -0.01405) + COALESCE(0.08202 * lactate, 0.08202 * 3.06436 + 0.06038) + COALESCE(0.10956 * ph, 0.10956 * 7.36233 + -0.00617) + COALESCE(0.00848 * o2flow, 0.00848 * 7.59362 + -0.35803)
        )
      )
    ) AS specimen_prob
  FROM stg2 AS bg
  LEFT JOIN stg_fio2 AS s2
    ON bg.hadm_id = s2.hadm_id
    AND s2.charttime BETWEEN bg.charttime - INTERVAL '4' HOUR AND bg.charttime
    AND s2.fio2_chartevents > 0
  WHERE
    bg.lastRowSpO2 = 1
)
SELECT
  stg3.hadm_id,
  stg3.icustay_id,
  stg3.charttime,
  specimen,
  CASE
    WHEN NOT SPECIMEN IS NULL
    THEN SPECIMEN
    WHEN SPECIMEN_PROB > 0.75
    THEN 'ART'
    ELSE NULL
  END AS specimen_pred,
  specimen_prob,
  so2,
  spo2,
  po2,
  pco2,
  fio2_chartevents,
  fio2,
  aado2,
  CASE
    WHEN NOT PO2 IS NULL
    AND NOT pco2 IS NULL
    AND NOT COALESCE(FIO2, fio2_chartevents) IS NULL
    THEN (
      COALESCE(FIO2, fio2_chartevents) / 100
    ) * (
      760 - 47
    ) - (
      pco2 / 0.8
    ) - po2
    ELSE NULL
  END AS aado2_calc,
  CASE
    WHEN NOT PO2 IS NULL AND NOT COALESCE(FIO2, fio2_chartevents) IS NULL
    THEN 100 * PO2 / (
      COALESCE(FIO2, fio2_chartevents)
    )
    ELSE NULL
  END AS pao2fio2ratio,
  ph,
  baseexcess,
  bicarbonate,
  totalco2,
  hematocrit,
  hemoglobin,
  carboxyhemoglobin,
  methemoglobin,
  chloride,
  calcium,
  temperature,
  potassium,
  sodium,
  lactate,
  glucose,
  intubated,
  tidalvolume,
  ventilationrate,
  ventilator,
  peep,
  o2flow,
  requiredo2
FROM stg3
WHERE
  lastRowFiO2 = 1 AND (
    specimen = 'ART' OR specimen_prob > 0.75
  )
ORDER BY
  hadm_id NULLS FIRST,
  charttime NULLS FIRST