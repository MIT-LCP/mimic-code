-- Count SpO2-like chartevents for CareVue (646) vs MetaVision (220277).
-- Useful when a neonatal cohort returns 0 rows for one era (#1957).

SELECT
  ce.itemid,
  COUNT(*) AS n_rows,
  COUNT(DISTINCT ce.icustay_id) AS n_stays
FROM mimiciii.chartevents AS ce
WHERE ce.itemid IN (646, 220277)
GROUP BY ce.itemid
ORDER BY ce.itemid;
