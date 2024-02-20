-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.blood_differential; CREATE TABLE mimiciv_derived.blood_differential AS
WITH blood_diff AS (
  SELECT
    MAX(subject_id) AS subject_id,
    MAX(hadm_id) AS hadm_id,
    MAX(charttime) AS charttime,
    le.specimen_id,
    MAX(CASE WHEN itemid IN (51300, 51301, 51755) THEN valuenum ELSE NULL END) AS wbc,
    MAX(CASE WHEN itemid = 52069 THEN valuenum ELSE NULL END) AS basophils_abs,
    MAX(
      CASE
        WHEN itemid = 52073
        THEN valuenum
        WHEN itemid = 51199
        THEN valuenum / 1000.0
        ELSE NULL
      END
    ) AS eosinophils_abs,
    MAX(
      CASE
        WHEN itemid = 51133
        THEN valuenum
        WHEN itemid = 52769
        THEN valuenum / 1000.0
        ELSE NULL
      END
    ) AS lymphocytes_abs,
    MAX(
      CASE
        WHEN itemid = 52074
        THEN valuenum
        WHEN itemid = 51253
        THEN valuenum / 1000.0
        ELSE NULL
      END
    ) AS monocytes_abs,
    MAX(CASE WHEN itemid = 52075 THEN valuenum ELSE NULL END) AS neutrophils_abs,
    MAX(CASE WHEN itemid = 51218 THEN valuenum / 1000.0 ELSE NULL END) AS granulocytes_abs,
    MAX(CASE WHEN itemid = 51146 THEN valuenum ELSE NULL END) AS basophils,
    MAX(CASE WHEN itemid = 51200 THEN valuenum ELSE NULL END) AS eosinophils,
    MAX(CASE WHEN itemid IN (51244, 51245) THEN valuenum ELSE NULL END) AS lymphocytes,
    MAX(CASE WHEN itemid = 51254 THEN valuenum ELSE NULL END) AS monocytes,
    MAX(CASE WHEN itemid = 51256 THEN valuenum ELSE NULL END) AS neutrophils,
    MAX(CASE WHEN itemid = 51143 THEN valuenum ELSE NULL END) AS atypical_lymphocytes,
    MAX(CASE WHEN itemid = 51144 THEN valuenum ELSE NULL END) AS bands,
    MAX(CASE WHEN itemid = 52135 THEN valuenum ELSE NULL END) AS immature_granulocytes,
    MAX(CASE WHEN itemid = 51251 THEN valuenum ELSE NULL END) AS metamyelocytes,
    MAX(CASE WHEN itemid = 51257 THEN valuenum ELSE NULL END) AS nrbc,
    CASE
      WHEN MAX(CASE WHEN itemid IN (51300, 51301, 51755) THEN valuenum ELSE NULL END) > 0
      AND SUM(
        CASE
          WHEN itemid IN (51146, 51200, 51244, 51245, 51254, 51256)
          THEN valuenum
          ELSE NULL
        END
      ) > 0
      THEN 1
      ELSE 0
    END AS impute_abs
  FROM mimiciv_hosp.labevents AS le
  WHERE
    le.itemid IN (51146, 52069, 51199, 51200, 52073, 51244, 51245, 51133, 52769, 51253, 51254, 52074, 51256, 52075, 51143, 51144, 51218, 52135, 51251, 51257, 51300, 51301, 51755)
    AND NOT valuenum IS NULL
    AND valuenum >= 0
  GROUP BY
    le.specimen_id
)
SELECT
  subject_id,
  hadm_id,
  charttime,
  specimen_id,
  wbc,
  ROUND(
    TRY_CAST(CASE
      WHEN basophils_abs IS NULL AND NOT basophils IS NULL AND impute_abs = 1
      THEN basophils * wbc / 100
      ELSE basophils_abs
    END AS DECIMAL),
    4
  ) AS basophils_abs,
  ROUND(
    TRY_CAST(CASE
      WHEN eosinophils_abs IS NULL AND NOT eosinophils IS NULL AND impute_abs = 1
      THEN eosinophils * wbc / 100
      ELSE eosinophils_abs
    END AS DECIMAL),
    4
  ) AS eosinophils_abs,
  ROUND(
    TRY_CAST(CASE
      WHEN lymphocytes_abs IS NULL AND NOT lymphocytes IS NULL AND impute_abs = 1
      THEN lymphocytes * wbc / 100
      ELSE lymphocytes_abs
    END AS DECIMAL),
    4
  ) AS lymphocytes_abs,
  ROUND(
    TRY_CAST(CASE
      WHEN monocytes_abs IS NULL AND NOT monocytes IS NULL AND impute_abs = 1
      THEN monocytes * wbc / 100
      ELSE monocytes_abs
    END AS DECIMAL),
    4
  ) AS monocytes_abs,
  ROUND(
    TRY_CAST(CASE
      WHEN neutrophils_abs IS NULL AND NOT neutrophils IS NULL AND impute_abs = 1
      THEN neutrophils * wbc / 100
      ELSE neutrophils_abs
    END AS DECIMAL),
    4
  ) AS neutrophils_abs,
  basophils,
  eosinophils,
  lymphocytes,
  monocytes,
  neutrophils,
  atypical_lymphocytes,
  bands,
  immature_granulocytes,
  metamyelocytes,
  nrbc
FROM blood_diff