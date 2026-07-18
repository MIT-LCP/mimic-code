-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ffp_transfusion; CREATE TABLE mimiciii_derived.ffp_transfusion AS
/* Retrieves instances of fresh frozen plasma transfusions */
WITH raw_ffp AS (
  SELECT
    CASE WHEN NOT amount IS NULL THEN amount WHEN NOT stopped IS NULL THEN 0 ELSE 200 END AS amount,
    amountuom,
    icustay_id,
    charttime
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (30005, /* Fresh Frozen Plasma */30180 /* Fresh Froz Plasma */)
    AND amount > 0
    AND NOT icustay_id IS NULL
  UNION ALL
  SELECT
    amount,
    amountuom,
    icustay_id,
    endtime AS charttime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid IN (220970 /* Fresh Frozen Plasma */)
    AND amount > 0
    AND NOT icustay_id IS NULL
), pre_icu_ffp AS (
  SELECT
    SUM(amount) AS amount,
    icustay_id
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (
      44172, /* FFP GTT         */
      44236, /* E.R. FFP        */
      46410, /* angio FFP */
      46418, /* ER ffp */
      46684, /* ER FFP */
      44819, /* FFP ON FARR 2 */
      46530, /* Floor FFP       */
      44044, /* FFP Drip */
      46122, /* ER in FFP */
      45669, /* ED FFP */
      42323 /* er ffp */
    )
    AND amount > 0
    AND NOT icustay_id IS NULL
  GROUP BY
    icustay_id
  UNION ALL
  SELECT
    SUM(amount) AS amount,
    icustay_id
  FROM mimiciii.inputevents_mv
  WHERE
    itemid IN (227072 /* PACU FFP Intake */) AND amount > 0 AND NOT icustay_id IS NULL
  GROUP BY
    icustay_id
), cumulative AS (
  SELECT
    SUM(amount) OVER (PARTITION BY icustay_id ORDER BY charttime DESC NULLS LAST) AS amount,
    amountuom,
    icustay_id,
    charttime,
    CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', LAG(charttime) OVER (PARTITION BY icustay_id ORDER BY charttime ASC NULLS FIRST)) - DATE_TRUNC('hour', charttime)) / 3600 AS BIGINT) AS delta
  FROM raw_ffp
)
/* We consider any transfusions started within 1 hr of the last one */ /* to be part of the same event */
SELECT
  cm.icustay_id,
  cm.charttime,
  ROUND(CAST(CAST(cm.amount AS DECIMAL(38, 9)) - CASE
    WHEN ROW_NUMBER() OVER w = 1
    THEN CAST(0 AS DECIMAL(38, 9))
    ELSE CAST(LAG(cm.amount) OVER w AS DECIMAL(38, 9))
  END AS NUMERIC), 2) AS amount,
  ROUND(CAST(CAST(cm.amount AS DECIMAL(38, 9)) + CASE
    WHEN pre.amount IS NULL
    THEN CAST(0 AS DECIMAL(38, 9))
    ELSE CAST(pre.amount AS DECIMAL(38, 9))
  END AS NUMERIC), 2) AS totalamount,
  cm.amountuom
FROM cumulative AS cm
LEFT JOIN pre_icu_ffp AS pre
  USING (icustay_id)
WHERE
  delta IS NULL OR delta < -1
WINDOW w AS (PARTITION BY cm.icustay_id ORDER BY cm.charttime DESC NULLS LAST)
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST