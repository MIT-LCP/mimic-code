SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 52056 THEN valuenum ELSE NULL END) AS abs_basophils
  , MAX(CASE WHEN itemid = 52060 THEN valuenum ELSE NULL END) AS abs_eosinophils
  , MAX(CASE
          WHEN itemid = 51133 THEN valuenum
          -- convert #/uL to K/uL
          WHEN itemid = 52733 THEN valuenum / 1000.0
      ELSE NULL END) AS abs_lymphocytes
  , MAX(CASE WHEN itemid = 52061 THEN valuenum ELSE NULL END) AS abs_monocytes
  , MAX(CASE WHEN itemid = 52062 THEN valuenum ELSE NULL END) AS abs_neutrophils
  , MAX(CASE WHEN itemid = 51143 THEN valuenum ELSE NULL END) AS atyps
  , MAX(CASE WHEN itemid = 51144 THEN valuenum ELSE NULL END) AS bands
  , MAX(CASE WHEN itemid = 52122 THEN valuenum ELSE NULL END) AS imm_granulocytes
  , MAX(CASE WHEN itemid = 51251 THEN valuenum ELSE NULL END) AS metas
  , MAX(CASE WHEN itemid = 51257 THEN valuenum ELSE NULL END) AS nrbc
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    52056, -- Absolute basophil count
    52060, -- Absolute Eosinophil count
    51133, -- Absolute Lymphocyte Count, K/uL
    52733, -- Absolute Lymphocyte Count, #/uL
    52061, -- Absolute Monocyte Count
    52062, -- Absolute Neutrophil Count
    51143, -- Atypical lymphocytes
    51144, -- Bands (%)
    52122, -- Immature granulocytes (%)
    51251, -- Metamyelocytes
    51257 -- Nucleated RBC
)
AND valuenum IS NOT NULL
-- lab values cannot be 0 and cannot be negative
AND valuenum > 0
GROUP BY le.specimen_id
;
