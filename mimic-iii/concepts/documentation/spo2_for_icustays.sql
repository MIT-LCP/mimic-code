-- Template: SpO2 rows for a list of icustay_id values (both common itemids).

SELECT ce.icustay_id, ce.itemid, ce.charttime, ce.valuenum, ce.valueuom
FROM mimiciii.chartevents AS ce
WHERE ce.itemid IN (646, 220277)
  AND ce.icustay_id IN (/* your icustay_id list */)
ORDER BY ce.icustay_id, ce.charttime
LIMIT 100;
