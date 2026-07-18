-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.kdigo_creatinine; CREATE TABLE mimiciii_derived.kdigo_creatinine AS
WITH cr AS (
  SELECT
    ie.icustay_id,
    ie.intime,
    ie.outtime,
    le.valuenum AS creat,
    le.charttime
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii.labevents AS le
    ON ie.subject_id = le.subject_id
    AND le.ITEMID = 50912
    AND NOT le.VALUENUM IS NULL
    AND DATE_DIFF('HOUR', ie.intime, le.charttime) <= (
      7 * 24 - 6
    )
    AND le.CHARTTIME >= ie.intime - INTERVAL '6' HOUR
    AND le.CHARTTIME <= ie.intime + INTERVAL '7' DAY
)
SELECT
  cr.icustay_id,
  cr.charttime,
  cr.creat,
  MIN(cr48.creat) AS creat_low_past_48hr,
  MIN(cr7.creat) AS creat_low_past_7day
FROM cr
LEFT JOIN cr AS cr48
  ON cr.icustay_id = cr48.icustay_id
  AND cr48.charttime < cr.charttime
  AND DATE_DIFF('HOUR', cr48.charttime, cr.charttime) <= 48
LEFT JOIN cr AS cr7
  ON cr.icustay_id = cr7.icustay_id
  AND cr7.charttime < cr.charttime
  AND DATE_DIFF('DAY', cr7.charttime, cr.charttime) <= 7
GROUP BY
  cr.icustay_id,
  cr.charttime,
  cr.creat
ORDER BY
  cr.icustay_id NULLS FIRST,
  cr.charttime NULLS FIRST,
  cr.creat NULLS FIRST