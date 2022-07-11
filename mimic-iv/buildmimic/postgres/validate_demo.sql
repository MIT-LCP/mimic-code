-- Validate the MIMIC-IV tables built correctly by checking against known row counts.
-- This script checks using the number of rows in the MIMIC-IV demo, a 100 patient subset
-- of MIMIC-IV.
WITH expected AS
(
    SELECT 'admissions' AS tbl, 275 AS row_count UNION ALL
    SELECT 'd_hcpcs' AS tbl, 89200 AS row_count UNION ALL
    SELECT 'd_icd_diagnoses' AS tbl, 109775 AS row_count UNION ALL
    SELECT 'd_icd_procedures' AS tbl, 85257 AS row_count UNION ALL
    SELECT 'd_labitems' AS tbl, 1623 AS row_count UNION ALL
    SELECT 'diagnoses_icd' AS tbl, 4506 AS row_count UNION ALL
    SELECT 'drgcodes' AS tbl, 454 AS row_count UNION ALL
    SELECT 'emar' AS tbl, 35835 AS row_count UNION ALL
    SELECT 'emar_detail' AS tbl, 72018 AS row_count UNION ALL
    SELECT 'hcpcsevents' AS tbl, 61 AS row_count UNION ALL
    SELECT 'labevents' AS tbl, 107727 AS row_count UNION ALL
    SELECT 'microbiologyevents' AS tbl, 2899 AS row_count UNION ALL
    SELECT 'omr' AS tbl, 2964 AS row_count UNION ALL
    SELECT 'patients' AS tbl, 100 AS row_count UNION ALL
    SELECT 'pharmacy' AS tbl, 15306 AS row_count UNION ALL
    SELECT 'poe' AS tbl, 45154 AS row_count UNION ALL
    SELECT 'poe_detail' AS tbl, 3053 AS row_count UNION ALL
    SELECT 'prescriptions' AS tbl, 18087 AS row_count UNION ALL
    SELECT 'procedures_icd' AS tbl, 722 AS row_count UNION ALL
    SELECT 'services' AS tbl, 319 AS row_count UNION ALL
    SELECT 'transfers' AS tbl, 1190 AS row_count UNION ALL
    -- icu data
    SELECT 'icustays' AS tbl, 140 AS row_count UNION ALL
    SELECT 'd_items' AS tbl, 4014 AS row_count UNION ALL
    SELECT 'chartevents' AS tbl, 668862 AS row_count UNION ALL
    SELECT 'datetimeevents' AS tbl, 15280 AS row_count UNION ALL
    SELECT 'inputevents' AS tbl, 20404 AS row_count UNION ALL
    SELECT 'outputevents' AS tbl, 9362 AS row_count UNION ALL
    SELECT 'procedureevents' AS tbl, 1468 AS row_count
)
, observed as
(
    SELECT 'admissions' AS tbl, count(*) AS row_count FROM mimiciv_hosp.admissions UNION ALL
    SELECT 'd_hcpcs' AS tbl, count(*) AS row_count FROM mimiciv_hosp.d_hcpcs UNION ALL
    SELECT 'd_icd_diagnoses' AS tbl, count(*) AS row_count FROM mimiciv_hosp.d_icd_diagnoses UNION ALL
    SELECT 'd_icd_procedures' AS tbl, count(*) AS row_count FROM mimiciv_hosp.d_icd_procedures UNION ALL
    SELECT 'd_labitems' AS tbl, count(*) AS row_count FROM mimiciv_hosp.d_labitems UNION ALL
    SELECT 'diagnoses_icd' AS tbl, count(*) AS row_count FROM mimiciv_hosp.diagnoses_icd UNION ALL
    SELECT 'drgcodes' AS tbl, count(*) AS row_count FROM mimiciv_hosp.drgcodes UNION ALL
    SELECT 'emar' AS tbl, count(*) AS row_count FROM mimiciv_hosp.emar UNION ALL
    SELECT 'emar_detail' AS tbl, count(*) AS row_count FROM mimiciv_hosp.emar_detail UNION ALL
    SELECT 'hcpcsevents' AS tbl, count(*) AS row_count FROM mimiciv_hosp.hcpcsevents UNION ALL
    SELECT 'labevents' AS tbl, count(*) AS row_count FROM mimiciv_hosp.labevents UNION ALL
    SELECT 'microbiologyevents' AS tbl, count(*) AS row_count FROM mimiciv_hosp.microbiologyevents UNION ALL
    SELECT 'omr' AS tbl, count(*) AS row_count FROM mimiciv_hosp.omr UNION ALL
    SELECT 'patients' AS tbl, count(*) AS row_count FROM mimiciv_hosp.patients UNION ALL
    SELECT 'pharmacy' AS tbl, count(*) AS row_count FROM mimiciv_hosp.pharmacy UNION ALL
    SELECT 'poe' AS tbl, count(*) AS row_count FROM mimiciv_hosp.poe UNION ALL
    SELECT 'poe_detail' AS tbl, count(*) AS row_count FROM mimiciv_hosp.poe_detail UNION ALL
    SELECT 'prescriptions' AS tbl, count(*) AS row_count FROM mimiciv_hosp.prescriptions UNION ALL
    SELECT 'procedures_icd' AS tbl, count(*) AS row_count FROM mimiciv_hosp.procedures_icd UNION ALL
    SELECT 'services' AS tbl, count(*) AS row_count FROM mimiciv_hosp.services UNION ALL
    SELECT 'transfers' AS tbl, count(*) AS row_count FROM mimiciv_hosp.transfers UNION ALL
    -- icu data
    SELECT 'icustays' AS tbl, count(*) AS row_count FROM mimiciv_icu.icustays UNION ALL
    SELECT 'chartevents' AS tbl, count(*) AS row_count FROM mimiciv_icu.chartevents UNION ALL
    SELECT 'd_items' AS tbl, count(*) AS row_count FROM mimiciv_icu.d_items UNION ALL
    SELECT 'datetimeevents' AS tbl, count(*) AS row_count FROM mimiciv_icu.datetimeevents UNION ALL
    SELECT 'inputevents' AS tbl, count(*) AS row_count FROM mimiciv_icu.inputevents UNION ALL
    SELECT 'outputevents' AS tbl, count(*) AS row_count FROM mimiciv_icu.outputevents UNION ALL
    SELECT 'procedureevents' AS tbl, count(*) AS row_count FROM mimiciv_icu.procedureevents
)
SELECT
    exp.tbl
    , exp.row_count AS expected_count
    , obs.row_count AS observed_count
    , CASE
        WHEN exp.row_count = obs.row_count
        THEN 'PASSED'
        ELSE 'FAILED'
    END AS ROW_COUNT_CHECK
FROM expected exp
INNER JOIN observed obs
  ON exp.tbl = obs.tbl
ORDER BY exp.tbl
;