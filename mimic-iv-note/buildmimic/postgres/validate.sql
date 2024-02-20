WITH expected AS
(
    SELECT 'discharge'          AS tbl, 331793   AS row_count UNION ALL
    SELECT 'radiology'          AS tbl, 2321355  AS row_count UNION ALL
    SELECT 'discharge_detail'   AS tbl, 186138   AS row_count UNION ALL
    SELECT 'radiology_detail'   AS tbl, 6046121  AS row_count
)
, observed as
(
    SELECT 'discharge'          AS tbl, COUNT(*) AS row_count FROM mimiciv_note.discharge UNION ALL
    SELECT 'radiology'          AS tbl, COUNT(*) AS row_count FROM mimiciv_note.radiology UNION ALL
    SELECT 'discharge_detail'   AS tbl, COUNT(*) AS row_count FROM mimiciv_note.discharge_detail UNION ALL
    SELECT 'radiology_detail'   AS tbl, COUNT(*) AS row_count FROM mimiciv_note.radiology_detail
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
