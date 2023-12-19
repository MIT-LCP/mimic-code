-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.bg; CREATE TABLE mimiciv_derived.bg AS
WITH bg AS (
  SELECT
    MAX(subject_id) AS subject_id,
    MAX(hadm_id) AS hadm_id,
    MAX(charttime) AS charttime,
    MAX(storetime) AS storetime,
    le.specimen_id,
    MAX(CASE WHEN itemid = 52033 THEN value ELSE NULL END) AS specimen,
    MAX(CASE WHEN itemid = 50801 THEN valuenum ELSE NULL END) AS aado2,
    MAX(CASE WHEN itemid = 50802 THEN valuenum ELSE NULL END) AS baseexcess,
    MAX(CASE WHEN itemid = 50803 THEN valuenum ELSE NULL END) AS bicarbonate,
    MAX(CASE WHEN itemid = 50804 THEN valuenum ELSE NULL END) AS totalco2,
    MAX(CASE WHEN itemid = 50805 THEN valuenum ELSE NULL END) AS carboxyhemoglobin,
    MAX(CASE WHEN itemid = 50806 THEN valuenum ELSE NULL END) AS chloride,
    MAX(CASE WHEN itemid = 50808 THEN valuenum ELSE NULL END) AS calcium,
    MAX(CASE WHEN itemid = 50809 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS glucose,
    MAX(CASE WHEN itemid = 50810 AND valuenum <= 100 THEN valuenum ELSE NULL END) AS hematocrit,
    MAX(CASE WHEN itemid = 50811 THEN valuenum ELSE NULL END) AS hemoglobin,
    MAX(CASE WHEN itemid = 50813 AND valuenum <= 10000 THEN valuenum ELSE NULL END) AS lactate,
    MAX(CASE WHEN itemid = 50814 THEN valuenum ELSE NULL END) AS methemoglobin,
    MAX(CASE WHEN itemid = 50815 THEN valuenum ELSE NULL END) AS o2flow,
    MAX(
      CASE
        WHEN itemid = 50816
        THEN CASE
          WHEN valuenum > 20 AND valuenum <= 100
          THEN valuenum
          WHEN valuenum > 0.2 AND valuenum <= 1.0
          THEN valuenum * 100.0
          ELSE NULL
        END
        ELSE NULL
      END
    ) AS fio2,
    MAX(CASE WHEN itemid = 50817 AND valuenum <= 100 THEN valuenum ELSE NULL END) AS so2,
    MAX(CASE WHEN itemid = 50818 THEN valuenum ELSE NULL END) AS pco2,
    MAX(CASE WHEN itemid = 50819 THEN valuenum ELSE NULL END) AS peep,
    MAX(CASE WHEN itemid = 50820 THEN valuenum ELSE NULL END) AS ph,
    MAX(CASE WHEN itemid = 50821 THEN valuenum ELSE NULL END) AS po2,
    MAX(CASE WHEN itemid = 50822 THEN valuenum ELSE NULL END) AS potassium,
    MAX(CASE WHEN itemid = 50823 THEN valuenum ELSE NULL END) AS requiredo2,
    MAX(CASE WHEN itemid = 50824 THEN valuenum ELSE NULL END) AS sodium,
    MAX(CASE WHEN itemid = 50825 THEN valuenum ELSE NULL END) AS temperature,
    MAX(CASE WHEN itemid = 50807 THEN value ELSE NULL END) AS comments
  FROM mimiciv_hosp.labevents AS le
  WHERE
    le.itemid IN (52033, 50801, 50802, 50803, 50804, 50805, 50806, 50807, 50808, 50809, 50810, 50811, 50813, 50814, 50815, 50816, 50817, 50818, 50819, 50820, 50821, 50822, 50823, 50824, 50825)
  GROUP BY
    le.specimen_id
), stg_spo2 AS (
  SELECT
    subject_id,
    charttime,
    AVG(valuenum) AS spo2
  FROM mimiciv_icu.chartevents
  WHERE
    itemid = 220277 AND valuenum > 0 AND valuenum <= 100
  GROUP BY
    subject_id,
    charttime
), stg_fio2 AS (
  SELECT
    subject_id,
    charttime,
    MAX(
      CASE
        WHEN valuenum > 0.2 AND valuenum <= 1
        THEN valuenum * 100
        WHEN valuenum > 1 AND valuenum < 20
        THEN NULL
        WHEN valuenum >= 20 AND valuenum <= 100
        THEN valuenum
        ELSE NULL
      END
    ) AS fio2_chartevents
  FROM mimiciv_icu.chartevents
  WHERE
    itemid = 223835 AND valuenum > 0 AND valuenum <= 100
  GROUP BY
    subject_id,
    charttime
), stg2 AS (
  SELECT
    bg.*,
    ROW_NUMBER() OVER (PARTITION BY bg.subject_id, bg.charttime ORDER BY s1.charttime DESC) AS lastrowspo2,
    s1.spo2
  FROM bg
  LEFT JOIN stg_spo2 AS s1
    ON bg.subject_id = s1.subject_id
    AND s1.charttime BETWEEN bg.charttime - INTERVAL '2' HOUR AND bg.charttime
  WHERE
    NOT bg.po2 IS NULL
), stg3 AS (
  SELECT
    bg.*,
    ROW_NUMBER() OVER (PARTITION BY bg.subject_id, bg.charttime ORDER BY s2.charttime DESC) AS lastrowfio2,
    s2.fio2_chartevents
  FROM stg2 AS bg
  LEFT JOIN stg_fio2 AS s2
    ON bg.subject_id = s2.subject_id
    AND s2.charttime >= bg.charttime - INTERVAL '4' HOUR
    AND s2.charttime <= bg.charttime
    AND s2.fio2_chartevents > 0
  WHERE
    bg.lastrowspo2 = 1
)
SELECT
  stg3.subject_id,
  stg3.hadm_id,
  stg3.charttime,
  specimen,
  so2,
  po2,
  pco2,
  fio2_chartevents,
  fio2,
  aado2,
  CASE
    WHEN po2 IS NULL OR pco2 IS NULL
    THEN NULL
    WHEN NOT fio2 IS NULL
    THEN (
      fio2 / 100
    ) * (
      760 - 47
    ) - (
      pco2 / 0.8
    ) - po2
    WHEN NOT fio2_chartevents IS NULL
    THEN (
      fio2_chartevents / 100
    ) * (
      760 - 47
    ) - (
      pco2 / 0.8
    ) - po2
    ELSE NULL
  END AS aado2_calc,
  CASE
    WHEN po2 IS NULL
    THEN NULL
    WHEN NOT fio2 IS NULL
    THEN 100 * po2 / fio2
    WHEN NOT fio2_chartevents IS NULL
    THEN 100 * po2 / fio2_chartevents
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
  glucose
FROM stg3
WHERE
  lastrowfio2 = 1