-- --------------------------------------------------------
-- Title: Retrieves the urine output of adult patients
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------

WITH agetbl AS
(
  SELECT ie.icustay_id, ie.intime
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  INNER JOIN patients p
  ON ie.subject_id = p.subject_id
  WHERE
  -- filter to only adults
  DATETIME_DIFF(ie.intime, p.dob, YEAR) > 15
)
-- Urine output is measured hourly, but the individual values are not of interest
-- Usually, you want an overall picture of patient output
-- This query sums the data over the first 24 hours
, uo_sum as
(
  select oe.icustay_id, sum(oe.VALUE) as urineoutput
  FROM outputevents oe
  INNER JOIN agetbl
  ON oe.icustay_id = agetbl.icustay_id
  -- and ensure the data occurs during the first day
  and oe.charttime between agetbl.intime and (DATETIME_ADD(agetbl.intime, INTERVAL 1 DAY)) -- first ICU day
  WHERE itemid IN
  (
  -- these are the most frequently occurring urine output observations in CareVue
  40055, -- "Urine Out Foley"
  43175, -- "Urine ."
  40069, -- "Urine Out Void"
  40094, -- "Urine Out Condom Cath"
  40715, -- "Urine Out Suprapubic"
  40473, -- "Urine Out IleoConduit"
  40085, -- "Urine Out Incontinent"
  40057, -- "Urine Out Rt Nephrostomy"
  40056, -- "Urine Out Lt Nephrostomy"
  40405, -- "Urine Out Other"
  40428, -- "Urine Out Straight Cath"
  40086,--	Urine Out Incontinent
  40096, -- "Urine Out Ureteral Stent #1"
  40651, -- "Urine Out Ureteral Stent #2"

  -- these are the most frequently occurring urine output observations in Metavision
  226559, -- "Foley"
  226560, -- "Void"
  227510, -- "TF Residual"
  226561, -- "Condom Cath"
  226584, -- "Ileoconduit"
  226563, -- "Suprapubic"
  226564, -- "R Nephrostomy"
  226565, -- "L Nephrostomy"
  226567, --	Straight Cath
  226557, -- "R Ureteral Stent"
  226558  -- "L Ureteral Stent"
  )
  group by oe.icustay_id
)
, uo as
(
  SELECT width_bucket(urineoutput, 0, 5000, 50) AS bucket
  FROM uo_sum
)
SELECT bucket*100 as UrineOutput, COUNT(*)
FROM uo
GROUP BY bucket
ORDER BY bucket;
