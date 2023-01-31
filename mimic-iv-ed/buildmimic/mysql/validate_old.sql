-- Validate the MIMIC-IV-ED tables built correctly by checking against known row counts.
-- Only For MIMIC-IV-ED v1.0, v2.0
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
    SELECT 'edstays'    AS tbl, 447712   AS row_count UNION ALL
    SELECT 'diagnosis'  AS tbl, 946692   AS row_count UNION ALL
    SELECT 'medrecon'   AS tbl, 3143791  AS row_count UNION ALL
    SELECT 'pyxis'      AS tbl, 1670590  AS row_count UNION ALL
    SELECT 'triage'     AS tbl, 447712   AS row_count UNION ALL
    SELECT 'vitalsign'  AS tbl, 1646976  AS row_count
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