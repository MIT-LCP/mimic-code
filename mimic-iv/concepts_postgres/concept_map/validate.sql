-- Validate the concept_map tables built correctly by checking against known row counts
WITH expected AS
(
    SELECT 'labevents_to_loinc' AS tbl,          1623 AS row_count UNION ALL
    SELECT 'labevents_to_omop' AS tbl,           1623 AS row_count UNION ALL
    SELECT 'prescriptions_to_rxnorm' AS tbl,     3107 AS row_count UNION ALL
    SELECT 'prescriptions_to_omop' AS tbl,       3103 AS row_count UNION ALL
    SELECT 'chartevents_to_loinc' AS tbl,        42 AS row_count UNION ALL
    SELECT 'chartevents_to_omop' AS tbl,         40 AS row_count UNION ALL
    SELECT 'procedureevents_to_snomed' AS tbl,   169 AS row_count UNION ALL
    SELECT 'procedureevents_to_omop' AS tbl,     169 AS row_count
)
, observed as
(
    SELECT 'labevents_to_loinc' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.labevents_to_loinc UNION ALL
    SELECT 'labevents_to_omop' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.labevents_to_omop UNION ALL
    SELECT 'prescriptions_to_rxnorm' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.prescriptions_to_rxnorm UNION ALL
    SELECT 'prescriptions_to_omop' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.prescriptions_to_omop UNION ALL
    SELECT 'chartevents_to_loinc' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.chartevents_to_loinc UNION ALL
    SELECT 'chartevents_to_omop' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.chartevents_to_omop UNION ALL
    SELECT 'procedureevents_to_snomed' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.procedureevents_to_snomed UNION ALL
    SELECT 'procedureevents_to_omop' AS tbl, count(*) AS row_count FROM mimiciv_concept_map.procedureevents_to_omop
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
