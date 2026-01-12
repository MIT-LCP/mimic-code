-- =====================================================================
-- PostgreSQL version of BigQuery pivoted-uo.sql (MIMIC-III)
-- Purpose: Pivot urine output volumes from OUTPUTEVENTS
--
-- Output table:
--   mimiciii_derived.pivoted_uo
--
-- Source table:
--   mimiciii_clinical.outputevents
-- =====================================================================

DROP TABLE IF EXISTS mimiciii_derived.pivoted_uo;

CREATE TABLE mimiciii_derived.pivoted_uo AS
SELECT
    icustay_id
  , charttime
  , SUM(urineoutput) AS urineoutput
FROM
(
  SELECT
      oe.icustay_id
    , oe.charttime
    , CASE
        WHEN oe.itemid = 227488 AND oe.value > 0 THEN -1 * oe.value
        ELSE oe.value
      END AS urineoutput
  FROM mimiciii_clinical.outputevents oe
  WHERE (oe.iserror IS NULL OR oe.iserror <> 1)
    AND oe.itemid IN
    (
      -- CareVue
      40055, 43175, 40069, 40094, 40715, 40473, 40085, 40057, 40056,
      40405, 40428, 40086, 40096, 40651,

      -- MetaVision
      226559, 226560, 226561, 226584, 226563, 226564, 226565, 226567,
      226557, 226558, 227488, 227489
    )
    AND oe.icustay_id IS NOT NULL
    AND oe.charttime IS NOT NULL
) t
GROUP BY icustay_id, charttime
ORDER BY icustay_id, charttime;

-- Suggested index (optional, recommended for downstream joins)
-- CREATE INDEX IF NOT EXISTS idx_pivoted_uo_icustay_charttime
--   ON mimiciii_derived.pivoted_uo (icustay_id, charttime);
