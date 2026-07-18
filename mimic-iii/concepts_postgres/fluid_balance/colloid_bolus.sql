-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.colloid_bolus; CREATE TABLE mimiciii_derived.colloid_bolus AS
/* received colloid before admission */ /* 226365  --  OR Colloid Intake */ /* 226376  --  PACU Colloid Intake */
WITH t1 AS (
  SELECT
    mv.icustay_id,
    mv.starttime AS charttime, /* standardize the units to millilitres */ /* also metavision has floating point precision.. but we only care down to the mL */
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
    mv.itemid IN (
      220864, /*	Albumin 5%	7466 132 7466 */
      220862, /*	Albumin 25%	9851 174 9851 */
      225174, /*	Hetastarch (Hespan) 6%	82 1 82 */
      225795, /*	Dextran 40	38 3 38 */
      225796 /*  Dextran 70 */
    ) /* below ITEMIDs not in use */ /* 220861 | Albumin (Human) 20% */ /* 220863 | Albumin (Human) 4% */
    AND mv.statusdescription <> 'Rewritten'
    AND (
      (
        mv.rateuom = 'mL/hour' AND mv.rate > 100
      )
      OR (
        mv.rateuom = 'mL/min' AND mv.rate > (
          CAST(100 AS DOUBLE PRECISION) / 60.0
        )
      )
      OR (
        mv.rateuom = 'mL/kg/hour' AND (
          mv.rate * mv.patientweight
        ) > 100
      )
    ) /* in MetaVision, these ITEMIDs never appear with a null rate */ /* so it is sufficient to check the rate is > 100 */
), t2 AS (
  SELECT
    cv.icustay_id,
    cv.charttime, /* carevue always has units in millilitres (or null) */
    ROUND(cv.amount) AS amount
  FROM mimiciii.inputevents_cv AS cv
  WHERE
    cv.itemid IN (
      30008, /*	Albumin 5% */
      30009, /*	Albumin 25% */
      42832, /*	albumin 12.5% */
      40548, /*	ALBUMIN */
      45403, /*	albumin */
      44203, /*	Albumin 12.5% */
      30181, /* Serum Albumin 5% */
      46564, /* Albumin */
      43237, /* 25% Albumin */
      43353, /* Albumin (human) 25% */
      30012, /*	Hespan */
      46313, /*	6% Hespan */
      30011, /* Dextran 40 */
      30016, /* Dextrose 10% */
      42975, /*	DEXTRAN DRIP */
      42944, /*	dextran */
      46336, /*	10% Dextran 40/D5W */
      46729, /*	Dextran */
      40033, /*	DEXTRAN */
      45410, /*	10% Dextran 40 */
      42731 /* Dextran40 10% */
    )
    AND cv.amount > 100
    AND cv.amount < 2000
), t3 /* some colloids are charted in chartevents */ AS (
  SELECT
    ce.icustay_id,
    ce.charttime, /* carevue always has units in millilitres (or null) */
    ROUND(ce.valuenum) AS amount
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.itemid IN (
      2510, /*	DEXTRAN LML 10% */
      3087, /*	DEXTRAN 40  10% */
      6937, /*	Dextran */
      3087, /* DEXTRAN 40  10% */
      3088 /*	DEXTRAN 40% */
    )
    AND NOT ce.valuenum IS NULL
    AND ce.valuenum > 100
    AND ce.valuenum < 2000
)
SELECT
  icustay_id,
  charttime,
  SUM(amount) AS colloid_bolus
FROM t1
/* just because the rate was high enough, does *not* mean the final amount was */
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