-- Validate the MIMIC-IV tables built correctly by checking against known row counts
-- of MIMIC-IV v2.2
WITH expected AS
(
    SELECT 'admissions' AS tbl,         431231 AS row_count UNION ALL
    SELECT 'd_hcpcs' AS tbl,            89200 AS row_count UNION ALL
    SELECT 'd_icd_diagnoses' AS tbl,    109775 AS row_count UNION ALL
    SELECT 'd_icd_procedures' AS tbl,   85257 AS row_count UNION ALL
    SELECT 'd_labitems' AS tbl,         1622 AS row_count UNION ALL
    SELECT 'diagnoses_icd' AS tbl,      4756326 AS row_count UNION ALL
    SELECT 'drgcodes' AS tbl,           604377 AS row_count UNION ALL
    SELECT 'emar' AS tbl,               26850359 AS row_count UNION ALL
    SELECT 'emar_detail' AS tbl,        54744789 AS row_count UNION ALL
    SELECT 'hcpcsevents' AS tbl,        150771 AS row_count UNION ALL
    SELECT 'labevents' AS tbl,          118171367 AS row_count UNION ALL
    SELECT 'microbiologyevents' AS tbl, 3228713 AS row_count UNION ALL
    SELECT 'omr' AS tbl,                6439169 AS row_count UNION ALL
    SELECT 'patients' AS tbl,           299712 AS row_count UNION ALL
    SELECT 'pharmacy' AS tbl,           13584514 AS row_count UNION ALL
    SELECT 'poe' AS tbl,                39366291 AS row_count UNION ALL
    SELECT 'poe_detail' AS tbl,         3879418 AS row_count UNION ALL
    SELECT 'prescriptions' AS tbl,      15416708 AS row_count UNION ALL
    SELECT 'procedures_icd' AS tbl,     669186 AS row_count UNION ALL
    SELECT 'services' AS tbl,           468029 AS row_count UNION ALL
    SELECT 'transfers' AS tbl,          1890972 AS row_count UNION ALL
    -- icu data
    SELECT 'icustays' AS tbl,           73181 AS row_count UNION ALL
    SELECT 'd_items' AS tbl,            4014 AS row_count UNION ALL
    SELECT 'chartevents' AS tbl,        313645063 AS row_count UNION ALL
    SELECT 'datetimeevents' AS tbl,     7112999 AS row_count UNION ALL
    SELECT 'inputevents' AS tbl,        8978893 AS row_count UNION ALL
    SELECT 'outputevents' AS tbl,       4234967 AS row_count UNION ALL
    SELECT 'procedureevents' AS tbl,    696092 AS row_count
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