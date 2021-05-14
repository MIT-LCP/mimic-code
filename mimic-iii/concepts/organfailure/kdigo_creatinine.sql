-- Extract all creatinine values FROM `physionet-data.mimiciii_clinical.labevents` around patient's ICU stay
with cr as
(
select
    ie.icustay_id
  , ie.intime, ie.outtime
  , le.valuenum as creat
  , le.charttime
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  left join `physionet-data.mimiciii_clinical.labevents` le
    on ie.subject_id = le.subject_id
    and le.ITEMID = 50912
    and le.VALUENUM is not null
    and DATETIME_DIFF(le.charttime, ie.intime, HOUR) <= (7*24-6)
    and le.CHARTTIME >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
    and le.CHARTTIME <= DATETIME_ADD(ie.intime, INTERVAL '7' DAY)
)
-- add in the lowest value in the previous 48 hours/7 days
SELECT
  cr.icustay_id
  , cr.charttime
  , cr.creat
  , MIN(cr48.creat) AS creat_low_past_48hr
  , MIN(cr7.creat) AS creat_low_past_7day
FROM cr
-- add in all creatinine values in the last 48 hours
LEFT JOIN cr cr48
  ON cr.icustay_id = cr48.icustay_id
  AND cr48.charttime <  cr.charttime
  AND DATETIME_DIFF(cr.charttime, cr48.charttime, HOUR) <= 48
-- add in all creatinine values in the last 7 days
LEFT JOIN cr cr7
  ON cr.icustay_id = cr7.icustay_id
  AND cr7.charttime <  cr.charttime
  AND DATETIME_DIFF(cr.charttime, cr7.charttime, DAY) <= 7
GROUP BY cr.icustay_id, cr.charttime, cr.creat
ORDER BY cr.icustay_id, cr.charttime, cr.creat;
