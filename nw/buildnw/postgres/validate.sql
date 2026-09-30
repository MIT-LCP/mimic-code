-- Validate the NW built correctly by checking against known row counts
WITH expected AS (
    SELECT 'admissions' AS tbl,         61843 AS row_count UNION ALL
    SELECT 'patients' AS tbl,           25923 AS row_count UNION ALL
    SELECT 'd_icd_diagnoses' AS tbl,    73958 AS row_count UNION ALL
    SELECT 'diagnoses_icd' AS tbl,      371807 AS row_count UNION ALL
    SELECT 'd_labitems' AS tbl,         256 AS row_count UNION ALL
    SELECT 'labevents' AS tbl,          16668451 AS row_count UNION ALL
    SELECT 'prescriptions' AS tbl,      1852983 AS row_count UNION ALL
    SELECT 'emar' AS tbl,               19196614 AS row_count UNION ALL
    -- icu data
    SELECT 'icustays' AS tbl,           28612 AS row_count UNION ALL
    SELECT 'd_items' AS tbl,            344 AS row_count UNION ALL
    SELECT 'chartevents' AS tbl,        9619759 AS row_count UNION ALL
    SELECT 'procedureevents' AS tbl,    1017891 AS row_count
),
observed AS (
    SELECT 'admissions' AS tbl, count(*) AS row_count FROM nw_hosp.admissions UNION ALL
    SELECT 'patients' AS tbl, count(*) AS row_count FROM nw_hosp.patients UNION ALL
    SELECT 'd_icd_diagnoses' AS tbl, count(*) AS row_count FROM nw_hosp.d_icd_diagnoses UNION ALL
    SELECT 'diagnoses_icd' AS tbl, count(*) AS row_count FROM nw_hosp.diagnoses_icd UNION ALL
    SELECT 'd_labitems' AS tbl, count(*) AS row_count FROM nw_hosp.d_labitems UNION ALL
    SELECT 'labevents' AS tbl, count(*) AS row_count FROM nw_hosp.labevents UNION ALL
    SELECT 'prescriptions' AS tbl, count(*) AS row_count FROM nw_hosp.prescriptions UNION ALL
    SELECT 'emar' AS tbl, count(*) AS row_count FROM nw_hosp.emar UNION ALL
    -- icu data
    SELECT 'icustays' AS tbl, count(*) AS row_count FROM nw_icu.icustays UNION ALL
    SELECT 'd_items' AS tbl, count(*) AS row_count FROM nw_icu.d_items UNION ALL
    SELECT 'chartevents' AS tbl, count(*) AS row_count FROM nw_icu.chartevents UNION ALL
    SELECT 'procedureevents' AS tbl, count(*) AS row_count FROM nw_icu.procedureevents 
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
