-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS blood_differential; CREATE TABLE blood_differential AS 
-- For reference, some common unit conversions:
-- 10^9/L == K/uL == 10^3/uL
WITH blood_diff AS
(
SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- create one set of columns for percentages, and one set of columns for counts
  -- we harmonize all count units into K/uL == 10^9/L
  -- counts have an "_abs" suffix, percentages do not

  -- absolute counts
  , MAX(CASE WHEN itemid in (51300, 51301, 51755) THEN valuenum ELSE NULL END) AS wbc
  , MAX(CASE WHEN itemid = 52069 THEN valuenum ELSE NULL END) AS basophils_abs
  -- 52073 in K/uL, 51199 in #/uL
  , MAX(CASE WHEN itemid = 52073 THEN valuenum WHEN itemid = 51199 THEN valuenum / 1000.0 ELSE NULL END) AS eosinophils_abs
  -- 51133 in K/uL, 52769 in #/uL
  , MAX(CASE WHEN itemid = 51133 THEN valuenum WHEN itemid = 52769 THEN valuenum / 1000.0 ELSE NULL END) AS lymphocytes_abs
  -- 52074 in K/uL, 51253 in #/uL
  , MAX(CASE WHEN itemid = 52074 THEN valuenum WHEN itemid = 51253 THEN valuenum / 1000.0 ELSE NULL END) AS monocytes_abs
  , MAX(CASE WHEN itemid = 52075 THEN valuenum ELSE NULL END) AS neutrophils_abs
  -- convert from #/uL to K/uL
  , MAX(CASE WHEN itemid = 51218 THEN valuenum / 1000.0 ELSE NULL END) AS granulocytes_abs

  -- percentages, equal to cell count / white blood cell count
  , MAX(CASE WHEN itemid = 51146 THEN valuenum ELSE NULL END) AS basophils
  , MAX(CASE WHEN itemid = 51200 THEN valuenum ELSE NULL END) AS eosinophils
  , MAX(CASE WHEN itemid in (51244, 51245) THEN valuenum ELSE NULL END) AS lymphocytes
  , MAX(CASE WHEN itemid = 51254 THEN valuenum ELSE NULL END) AS monocytes
  , MAX(CASE WHEN itemid = 51256 THEN valuenum ELSE NULL END) AS neutrophils

  -- other cell count percentages
  , MAX(CASE WHEN itemid = 51143 THEN valuenum ELSE NULL END) AS atypical_lymphocytes
  , MAX(CASE WHEN itemid = 51144 THEN valuenum ELSE NULL END) AS bands
  , MAX(CASE WHEN itemid = 52135 THEN valuenum ELSE NULL END) AS immature_granulocytes
  , MAX(CASE WHEN itemid = 51251 THEN valuenum ELSE NULL END) AS metamyelocytes
  , MAX(CASE WHEN itemid = 51257 THEN valuenum ELSE NULL END) AS nrbc

  -- utility flags which determine whether imputation is possible
  , CASE
    -- WBC is available
    WHEN MAX(CASE WHEN itemid in (51300, 51301, 51755) THEN valuenum ELSE NULL END) > 0
    -- and we have at least one percentage from the diff
    -- sometimes the entire diff is 0%, which looks like bad data
    AND SUM(CASE WHEN itemid IN (51146, 51200, 51244, 51245, 51254, 51256) THEN valuenum ELSE NULL END) > 0
    THEN 1 ELSE 0 END AS impute_abs

FROM mimiciv_hosp.labevents le
WHERE le.itemid IN
(
    51146, -- basophils
    52069, -- Absolute basophil count
    51199, -- Eosinophil Count
    51200, -- Eosinophils
    52073, -- Absolute Eosinophil count
    51244, -- Lymphocytes
    51245, -- Lymphocytes, Percent
    51133, -- Absolute Lymphocyte Count
    52769, -- Absolute Lymphocyte Count
    51253, -- Monocyte Count
    51254, -- Monocytes
    52074, -- Absolute Monocyte Count
    51256, -- Neutrophils
    52075, -- Absolute Neutrophil Count
    51143, -- Atypical lymphocytes
    51144, -- Bands (%)
    51218, -- Granulocyte Count
    52135, -- Immature granulocytes (%)
    51251, -- Metamyelocytes
    51257,  -- Nucleated Red Cells

    -- wbc totals measured in K/uL
    51300, 51301, 51755
    -- 52220 (wbcp) is percentage

    -- below are point of care tests which are extremely infrequent and usually low quality
    -- 51697, -- Neutrophils (mmol/L)

    -- below itemid do not have data as of MIMIC-IV v1.0
    -- 51536, -- Absolute Lymphocyte Count
    -- 51537, -- Absolute Neutrophil
    -- 51690, -- Lymphocytes
    -- 52151, -- NRBC
)
AND valuenum IS NOT NULL
-- differential values cannot be negative
AND valuenum >= 0
GROUP BY le.specimen_id
)
SELECT 
subject_id, hadm_id, charttime, specimen_id

, wbc
-- impute absolute count if percentage & WBC is available
, ROUND( CAST( CASE
    WHEN basophils_abs IS NULL AND basophils IS NOT NULL AND impute_abs = 1
        THEN basophils * wbc / 100
    ELSE basophils_abs
END as numeric),4) AS basophils_abs
, ROUND( CAST( CASE
    WHEN eosinophils_abs IS NULL AND eosinophils IS NOT NULL AND impute_abs = 1
        THEN eosinophils * wbc / 100
    ELSE eosinophils_abs
END as numeric),4) AS eosinophils_abs
, ROUND( CAST( CASE
    WHEN lymphocytes_abs IS NULL AND lymphocytes IS NOT NULL AND impute_abs = 1
        THEN lymphocytes * wbc / 100
    ELSE lymphocytes_abs
END as numeric),4) AS lymphocytes_abs
, ROUND( CAST( CASE
    WHEN monocytes_abs IS NULL AND monocytes IS NOT NULL AND impute_abs = 1
        THEN monocytes * wbc / 100
    ELSE monocytes_abs
END as numeric),4) AS monocytes_abs
, ROUND( CAST( CASE
    WHEN neutrophils_abs IS NULL AND neutrophils IS NOT NULL AND impute_abs = 1
        THEN neutrophils * wbc / 100
    ELSE neutrophils_abs
END as numeric),4) AS neutrophils_abs

, basophils
, eosinophils
, lymphocytes
, monocytes
, neutrophils

-- impute bands/blasts?
, atypical_lymphocytes
, bands
, immature_granulocytes
, metamyelocytes
, nrbc
FROM blood_diff
;
