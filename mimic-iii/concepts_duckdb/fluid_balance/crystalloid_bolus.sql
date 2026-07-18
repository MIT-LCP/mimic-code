-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.crystalloid_bolus; CREATE TABLE mimiciii_derived.crystalloid_bolus AS
WITH t1 AS (
  SELECT
    mv.icustay_id,
    mv.starttime AS charttime,
    ROUND(
      CASE
        WHEN mv.amountuom = 'L'
        THEN mv.amount * 1000.0
        WHEN mv.amountuom = 'ml'
        THEN mv.amount
        ELSE NULL
      END
    ) AS amount
  FROM mimiciii.inputevents_mv AS mv
  WHERE
    mv.itemid IN (225158, 225828, 225944, 225797, 225159, 225823, 225825, 225827, 225941, 226089)
    AND mv.statusdescription <> 'Rewritten'
    AND (
      (
        NOT mv.rate IS NULL AND mv.rateuom = 'mL/hour' AND mv.rate > 248
      )
      OR (
        NOT mv.rate IS NULL AND mv.rateuom = 'mL/min' AND mv.rate > (
          248 / 60.0
        )
      )
      OR (
        mv.rate IS NULL AND mv.amountuom = 'L' AND mv.amount > 0.248
      )
      OR (
        mv.rate IS NULL AND mv.amountuom = 'ml' AND mv.amount > 248
      )
    )
), t2 AS (
  SELECT
    cv.icustay_id,
    cv.charttime,
    ROUND(cv.amount) AS amount
  FROM mimiciii.inputevents_cv AS cv
  WHERE
    cv.itemid IN (
      30015,
      30018,
      30020,
      30021,
      30058,
      30060,
      30061,
      30063,
      30065,
      30159,
      30160,
      30169,
      30190,
      40850,
      41491,
      42639,
      42187,
      43819,
      41430,
      40712,
      44160,
      42383,
      42297,
      42453,
      40872,
      41915,
      41490,
      46501,
      45045,
      41984,
      41371,
      41582,
      41322,
      40778,
      41896,
      41428,
      43936,
      44200,
      41619,
      40424,
      41457,
      41581,
      42844,
      42429,
      41356,
      40532,
      42548,
      44184,
      44521,
      44741,
      44126,
      44110,
      44633,
      44983,
      44815,
      43986,
      45079,
      46781,
      45155,
      43909,
      41467,
      44367,
      41743,
      40423,
      44263,
      42749,
      45480,
      44491,
      41695,
      46169,
      41580,
      41392,
      45989,
      45137,
      45154,
      44053,
      41416,
      44761,
      41237,
      44426,
      43975,
      44894,
      41380,
      42671
    )
    AND cv.amount > 248
    AND cv.amount <= 2000
    AND cv.amountuom = 'ml'
)
SELECT
  icustay_id,
  charttime,
  SUM(amount) AS crystalloid_bolus
FROM t1
WHERE
  amount > 248
GROUP BY
  t1.icustay_id,
  t1.charttime
UNION
SELECT
  icustay_id,
  charttime,
  SUM(amount) AS crystalloid_bolus
FROM t2
GROUP BY
  t2.icustay_id,
  t2.charttime