-- Validate the MIMIC-IV-ED tables built correctly by checking against known row counts.
-- Tested against MIMIC-IV-ED v2.2.
SELECT
    CASE
        WHEN exp.row_count = obs.row_count
        THEN 'PASSED'
        ELSE 'FAILED'
    END AS chk
    , exp.row_count AS exp
    , obs.row_count AS obs
    , exp.tbl as table_name
FROM (
    SELECT 'edstays'    AS tbl, 425087   AS row_count UNION ALL
    SELECT 'diagnosis'  AS tbl, 899050   AS row_count UNION ALL
    SELECT 'medrecon'   AS tbl, 2987342  AS row_count UNION ALL
    SELECT 'pyxis'      AS tbl, 1586053  AS row_count UNION ALL
    SELECT 'triage'     AS tbl, 425087   AS row_count UNION ALL
    SELECT 'vitalsign'  AS tbl, 1564610  AS row_count
) exp
INNER JOIN (
    SELECT 'edstays'    AS tbl, COUNT(*) AS row_count FROM edstays UNION ALL
    SELECT 'diagnosis'  AS tbl, COUNT(*) AS row_count FROM diagnosis UNION ALL
    SELECT 'medrecon'   AS tbl, COUNT(*) AS row_count FROM medrecon UNION ALL
    SELECT 'pyxis'      AS tbl, COUNT(*) AS row_count FROM pyxis UNION ALL
    SELECT 'triage'     AS tbl, COUNT(*) AS row_count FROM triage UNION ALL
    SELECT 'vitalsign'  AS tbl, COUNT(*) AS row_count FROM vitalsign
) obs
  ON exp.tbl = obs.tbl
ORDER BY exp.tbl
;