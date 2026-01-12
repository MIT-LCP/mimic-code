-- =====================================================================
-- PostgreSQL version of BigQuery pivoted-bg-art.sql (MIMIC-III)
-- Requires: mimiciii_derived.pivoted_bg
--
-- Output: mimiciii_derived.pivoted_bg_art
-- =====================================================================

DROP TABLE IF EXISTS mimiciii_derived.pivoted_bg_art;

CREATE TABLE mimiciii_derived.pivoted_bg_art AS
WITH stg_spo2 AS
(
  SELECT
      hadm_id
    , charttime
    , AVG(valuenum) AS spo2
  FROM mimiciii_clinical.chartevents
  WHERE itemid IN (646, 220277)     -- SpO2
    AND valuenum > 0 AND valuenum <= 100
    AND charttime IS NOT NULL
  GROUP BY hadm_id, charttime
)
, stg_fio2 AS
(
  SELECT
      hadm_id
    , charttime
    , MAX(
        CASE
          WHEN itemid = 223835 THEN
            CASE
              WHEN valuenum > 0 AND valuenum <= 1 THEN valuenum * 100
              WHEN valuenum > 1 AND valuenum < 21 THEN NULL
              WHEN valuenum >= 21 AND valuenum <= 100 THEN valuenum
              ELSE NULL
            END
          WHEN itemid IN (3420, 3422) THEN
            valuenum
          WHEN itemid = 190 AND valuenum > 0.20 AND valuenum < 1 THEN
            valuenum * 100
          ELSE NULL
        END
      ) AS fio2_chartevents
  FROM mimiciii_clinical.chartevents
  WHERE itemid IN (3420, 190, 223835, 3422)
    AND valuenum > 0 AND valuenum < 100
    AND charttime IS NOT NULL
    -- exclude rows marked as error (if column exists in your import)
    AND (error IS NULL OR error <> 1)
  GROUP BY hadm_id, charttime
)
, stg2 AS
(
  SELECT
      bg.*
    , ROW_NUMBER() OVER
        (PARTITION BY bg.hadm_id, bg.charttime
         ORDER BY s1.charttime DESC NULLS LAST) AS lastrowspo2
    , s1.spo2
  FROM mimiciii_derived.pivoted_bg bg
  LEFT JOIN stg_spo2 s1
    ON bg.hadm_id = s1.hadm_id
   AND s1.charttime BETWEEN (bg.charttime - INTERVAL '2' HOUR) AND bg.charttime
  WHERE bg.po2 IS NOT NULL
)
, stg3 AS
(
  SELECT
      bg.*
    , ROW_NUMBER() OVER
        (PARTITION BY bg.hadm_id, bg.charttime
         ORDER BY s2.charttime DESC NULLS LAST) AS lastrowfio2
    , s2.fio2_chartevents

    -- Logistic regression probability (same coefficients as BigQuery)
    , 1.0 / (1.0 + EXP(-(
        -0.02544
        + 0.04598 * po2
        + COALESCE(-0.15356 * spo2            , -0.15356 * 97.49420 + 0.13429)
        + COALESCE( 0.00621 * fio2_chartevents,  0.00621 * 51.49550 - 0.24958)
        + COALESCE( 0.10559 * hemoglobin      ,  0.10559 * 10.32307 + 0.05954)
        + COALESCE( 0.13251 * so2             ,  0.13251 * 93.66539 - 0.23172)
        + COALESCE(-0.01511 * pco2            , -0.01511 * 42.08866 - 0.01630)
        + COALESCE( 0.01480 * fio2            ,  0.01480 * 63.97836 - 0.31142)
        + COALESCE(-0.00200 * aado2           , -0.00200 * 442.21186 - 0.01328)
        + COALESCE(-0.03220 * bicarbonate     , -0.03220 * 22.96894 - 0.06535)
        + COALESCE( 0.05384 * totalco2        ,  0.05384 * 24.72632 - 0.01405)
        + COALESCE( 0.08202 * lactate         ,  0.08202 *  3.06436 + 0.06038)
        + COALESCE( 0.10956 * ph              ,  0.10956 *  7.36233 - 0.00617)
        + COALESCE( 0.00848 * o2flow          ,  0.00848 *  7.59362 - 0.35803)
      ))) AS specimen_prob
  FROM stg2 bg
  LEFT JOIN stg_fio2 s2
    ON bg.hadm_id = s2.hadm_id
   AND s2.charttime BETWEEN (bg.charttime - INTERVAL '4' HOUR) AND bg.charttime
   AND s2.fio2_chartevents > 0
  WHERE bg.lastrowspo2 = 1
)
SELECT
    stg3.hadm_id
  , stg3.icustay_id
  , stg3.charttime
  , stg3.specimen

  , CASE
      WHEN stg3.specimen IS NOT NULL THEN stg3.specimen
      WHEN stg3.specimen_prob > 0.75 THEN 'ART'
      ELSE NULL
    END AS specimen_pred
  , stg3.specimen_prob

  -- oxygen related parameters
  , stg3.so2
  , stg3.spo2
  , stg3.po2
  , stg3.pco2
  , stg3.fio2_chartevents
  , stg3.fio2
  , stg3.aado2

  , CASE
      WHEN stg3.po2 IS NOT NULL
       AND stg3.pco2 IS NOT NULL
       AND COALESCE(stg3.fio2, stg3.fio2_chartevents) IS NOT NULL
      THEN (COALESCE(stg3.fio2, stg3.fio2_chartevents) / 100.0) * (760 - 47) - (stg3.pco2 / 0.8) - stg3.po2
      ELSE NULL
    END AS aado2_calc

  , CASE
      WHEN stg3.po2 IS NOT NULL
       AND COALESCE(stg3.fio2, stg3.fio2_chartevents) IS NOT NULL
      THEN 100.0 * stg3.po2 / COALESCE(stg3.fio2, stg3.fio2_chartevents)
      ELSE NULL
    END AS pao2fio2ratio

  -- acid-base parameters
  , stg3.ph
  , stg3.baseexcess
  , stg3.bicarbonate
  , stg3.totalco2

  -- blood count parameters
  , stg3.hematocrit
  , stg3.hemoglobin
  , stg3.carboxyhemoglobin
  , stg3.methemoglobin

  -- chemistry
  , stg3.chloride
  , stg3.calcium
  , stg3.temperature
  , stg3.potassium
  , stg3.sodium
  , stg3.lactate
  , stg3.glucose

  -- ventilation / misc
  , stg3.intubated
  , stg3.tidalvolume
  , stg3.ventilationrate
  , stg3.ventilator
  , stg3.peep
  , stg3.o2flow
  , stg3.requiredo2
FROM stg3
WHERE stg3.lastrowfio2 = 1
  AND (stg3.specimen = 'ART' OR stg3.specimen_prob > 0.75)
ORDER BY stg3.hadm_id, stg3.charttime;

-- Suggested indexes (optional but strongly recommended)
-- CREATE INDEX IF NOT EXISTS idx_pivoted_bg_art_icustay_charttime
--   ON mimiciii_derived.pivoted_bg_art (icustay_id, charttime);
-- CREATE INDEX IF NOT EXISTS idx_pivoted_bg_art_hadm_charttime
--   ON mimiciii_derived.pivoted_bg_art (hadm_id, charttime);
