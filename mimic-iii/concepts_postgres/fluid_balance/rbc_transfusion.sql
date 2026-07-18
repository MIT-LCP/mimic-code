-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.rbc_transfusion; CREATE TABLE mimiciii_derived.rbc_transfusion AS
/* Retrieves instances of red blood cell transfusions */
WITH raw_rbc AS (
  SELECT
    CASE WHEN NOT amount IS NULL THEN amount WHEN NOT stopped IS NULL THEN 0 ELSE 375 END AS amount,
    amountuom,
    icustay_id,
    charttime
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (30179, /* PRBC's */30001, /* Packed RBC's */30004 /* Washed PRBC's */)
    AND NOT icustay_id IS NULL
  UNION ALL
  SELECT
    amount,
    amountuom,
    icustay_id,
    endtime AS charttime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid IN (225168 /* Packed Red Blood Cells */)
    AND amount > 0
    AND NOT icustay_id IS NULL
), pre_icu_rbc AS (
  SELECT
    SUM(amount) AS amount,
    icustay_id
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (
      42324, /* er prbc */
      42588, /* VICU PRBC */
      42239, /* CC7 PRBC */
      46407, /* ED PRBC */
      46612, /* E.R. prbc */
      46124, /* er in prbc */
      42740 /* prbc in er */
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
    itemid IN (227070 /* PACU Packed RBC Intake */)
    AND amount > 0
    AND NOT icustay_id IS NULL
  GROUP BY
    icustay_id
), cumulative AS (
  SELECT
    SUM(amount) OVER (PARTITION BY icustay_id ORDER BY charttime DESC NULLS LAST) AS amount,
    amountuom,
    icustay_id,
    charttime,
    CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', LAG(charttime) OVER (PARTITION BY icustay_id ORDER BY charttime ASC NULLS FIRST)) - DATE_TRUNC('hour', charttime)) / 3600 AS BIGINT) AS delta
  FROM raw_rbc
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
    WHEN CAST(pre.amount AS DECIMAL(38, 9)) IS NULL
    THEN CAST(0 AS DECIMAL(38, 9))
    ELSE CAST(pre.amount AS DECIMAL(38, 9))
  END AS NUMERIC), 2) AS totalamount,
  cm.amountuom
FROM cumulative AS cm
LEFT JOIN pre_icu_rbc AS pre
  USING (icustay_id)
WHERE
  delta IS NULL OR delta < -1
WINDOW w AS (PARTITION BY cm.icustay_id ORDER BY cm.charttime DESC NULLS LAST)
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST