-- Validate the MIMIC-IV-ED tables built correctly by checking against known row counts.
-- Tested against MIMIC-IV-ED v2.2.
WITH expected AS
(
    SELECT 'edstays'    AS tbl, 425087   AS row_count UNION ALL
    SELECT 'diagnosis'  AS tbl, 899050   AS row_count UNION ALL
    SELECT 'medrecon'   AS tbl, 2987342  AS row_count UNION ALL
    SELECT 'pyxis'      AS tbl, 1586053  AS row_count UNION ALL
    SELECT 'triage'     AS tbl, 425087   AS row_count UNION ALL
    SELECT 'vitalsign'  AS tbl, 1564610  AS row_count
)
, observed as
(
    SELECT 'edstays'    AS tbl, COUNT(*) AS row_count FROM mimiciv_ed.edstays UNION ALL
    SELECT 'diagnosis'  AS tbl, COUNT(*) AS row_count FROM mimiciv_ed.diagnosis UNION ALL
    SELECT 'medrecon'   AS tbl, COUNT(*) AS row_count FROM mimiciv_ed.medrecon UNION ALL
    SELECT 'pyxis'      AS tbl, COUNT(*) AS row_count FROM mimiciv_ed.pyxis UNION ALL
    SELECT 'triage'     AS tbl, COUNT(*) AS row_count FROM mimiciv_ed.triage UNION ALL
    SELECT 'vitalsign'  AS tbl, COUNT(*) AS row_count FROM mimiciv_ed.vitalsign
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