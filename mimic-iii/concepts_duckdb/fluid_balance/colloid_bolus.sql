-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.colloid_bolus; CREATE TABLE mimiciii_derived.colloid_bolus AS
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
    mv.itemid IN (220864, 220862, 225174, 225795, 225796)
    AND mv.statusdescription <> 'Rewritten'
    AND (
      (
        mv.rateuom = 'mL/hour' AND mv.rate > 100
      )
      OR (
        mv.rateuom = 'mL/min' AND mv.rate > (
          100 / 60.0
        )
      )
      OR (
        mv.rateuom = 'mL/kg/hour' AND (
          mv.rate * mv.patientweight
        ) > 100
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
      30008,
      30009,
      42832,
      40548,
      45403,
      44203,
      30181,
      46564,
      43237,
      43353,
      30012,
      46313,
      30011,
      30016,
      42975,
      42944,
      46336,
      46729,
      40033,
      45410,
      42731
    )
    AND cv.amount > 100
    AND cv.amount < 2000
), t3 AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    ROUND(ce.valuenum) AS amount
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.itemid IN (2510, 3087, 6937, 3087, 3088)
    AND NOT ce.valuenum IS NULL
    AND ce.valuenum > 100
    AND ce.valuenum < 2000
)
SELECT
  icustay_id,
  charttime,
  SUM(amount) AS colloid_bolus
FROM t1
WHERE
  amount > 100
GROUP BY
  t1.icustay_id,
  t1.charttime
UNION ALL
SELECT
  icustay_id,
  charttime,
  SUM(amount) AS colloid_bolus
FROM t2
GROUP BY
  t2.icustay_id,
  t2.charttime
UNION ALL
SELECT
  icustay_id,
  charttime,
  SUM(amount) AS colloid_bolus
FROM t3
GROUP BY
  t3.icustay_id,
  t3.charttime
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST