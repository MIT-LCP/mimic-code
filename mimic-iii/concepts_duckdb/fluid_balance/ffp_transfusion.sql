-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ffp_transfusion; CREATE TABLE mimiciii_derived.ffp_transfusion AS
WITH raw_ffp AS (
  SELECT
    CASE WHEN NOT amount IS NULL THEN amount WHEN NOT stopped IS NULL THEN 0 ELSE 200 END AS amount,
    amountuom,
    icustay_id,
    charttime
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (30005, 30180) AND amount > 0 AND NOT icustay_id IS NULL
  UNION ALL
  SELECT
    amount,
    amountuom,
    icustay_id,
    endtime AS charttime
  FROM mimiciii.inputevents_mv
  WHERE
    itemid IN (220970) AND amount > 0 AND NOT icustay_id IS NULL
), pre_icu_ffp AS (
  SELECT
    SUM(amount) AS amount,
    icustay_id
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (44172, 44236, 46410, 46418, 46684, 44819, 46530, 44044, 46122, 45669, 42323)
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
    itemid IN (227072) AND amount > 0 AND NOT icustay_id IS NULL
  GROUP BY
    icustay_id
), cumulative AS (
  SELECT
    SUM(amount) OVER (PARTITION BY icustay_id ORDER BY charttime DESC) AS amount,
    amountuom,
    icustay_id,
    charttime,
    DATE_DIFF(
      'HOUR',
      charttime,
      LAG(charttime) OVER (PARTITION BY icustay_id ORDER BY charttime ASC NULLS FIRST)
    ) AS delta
  FROM raw_ffp
)
SELECT
  cm.icustay_id,
  cm.charttime,
  ROUND(
    CAST(cm.amount AS DECIMAL(38, 9)) - CASE
      WHEN ROW_NUMBER() OVER w = 1
      THEN CAST(0 AS DECIMAL(38, 9))
      ELSE CAST(LAG(cm.amount) OVER w AS DECIMAL(38, 9))
    END,
    2
  ) AS amount,
  ROUND(
    CAST(cm.amount AS DECIMAL(38, 9)) + CASE
      WHEN pre.amount IS NULL
      THEN CAST(0 AS DECIMAL(38, 9))
      ELSE CAST(pre.amount AS DECIMAL(38, 9))
    END,
    2
  ) AS totalamount,
  cm.amountuom
FROM cumulative AS cm
LEFT JOIN pre_icu_ffp AS pre
  USING (icustay_id)
WHERE
  delta IS NULL OR delta < -1
WINDOW w AS (PARTITION BY cm.icustay_id ORDER BY cm.charttime DESC)
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST