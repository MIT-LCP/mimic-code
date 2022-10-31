-- Validate the MIMIC-IV tables built correctly by checking against known row counts.
WITH expected AS
(
    SELECT 'admissions' AS tbl, 454324 AS row_count UNION ALL
    SELECT 'd_hcpcs' AS tbl, 89200 AS row_count UNION ALL
    SELECT 'd_icd_diagnoses' AS tbl, 109775 AS row_count UNION ALL
    SELECT 'd_icd_procedures' AS tbl, 85257 AS row_count UNION ALL
    SELECT 'd_labitems' AS tbl, 1623 AS row_count UNION ALL
    SELECT 'diagnoses_icd' AS tbl, 5006884 AS row_count UNION ALL
    SELECT 'drgcodes' AS tbl, 636157 AS row_count UNION ALL
    SELECT 'emar' AS tbl, 28189413 AS row_count UNION ALL
    SELECT 'emar_detail' AS tbl, 57469291 AS row_count UNION ALL
    SELECT 'hcpcsevents' AS tbl, 159156 AS row_count UNION ALL
    SELECT 'labevents' AS tbl, 124342638 AS row_count UNION ALL
    SELECT 'microbiologyevents' AS tbl, 3395229 AS row_count UNION ALL
    SELECT 'omr' AS tbl, 6770301 AS row_count UNION ALL
    SELECT 'patients' AS tbl, 315460 AS row_count UNION ALL
    SELECT 'pharmacy' AS tbl, 14291703 AS row_count UNION ALL
    SELECT 'poe' AS tbl, 41427803 AS row_count UNION ALL
    SELECT 'poe_detail' AS tbl, 3174971 AS row_count UNION ALL
    SELECT 'prescriptions' AS tbl, 16219412 AS row_count UNION ALL
    SELECT 'procedures_icd' AS tbl, 704124 AS row_count UNION ALL
    SELECT 'services' AS tbl, 492967 AS row_count UNION ALL
    SELECT 'transfers' AS tbl, 1991704 AS row_count UNION ALL
    -- icu data
    SELECT 'icustays' AS tbl, 76943 AS row_count UNION ALL
    SELECT 'd_items' AS tbl, 4014 AS row_count UNION ALL
    SELECT 'chartevents' AS tbl, 329822285 AS row_count UNION ALL
    SELECT 'datetimeevents' AS tbl, 7477876 AS row_count UNION ALL
    SELECT 'inputevents' AS tbl, 9442345 AS row_count UNION ALL
    SELECT 'outputevents' AS tbl, 4450049 AS row_count UNION ALL
    SELECT 'procedureevents' AS tbl, 731788 AS row_count
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