-- Retrieves instances of fresh frozen plasma transfusions
WITH raw_ffp AS (
  SELECT
      CASE
        WHEN amount IS NOT NULL THEN amount
        WHEN stopped IS NOT NULL THEN 0
        -- impute 200 mL when unit is not documented
        -- this is an approximation which holds ~90% of the time
        ELSE 200
      END AS amount
    , amountuom
    , icustay_id
    , charttime
  FROM `physionet-data.mimiciii_clinical.inputevents_cv`
  WHERE itemid IN
  (
    30005,  -- Fresh Frozen Plasma
    30180   -- Fresh Froz Plasma
  )
  AND amount > 0
  AND icustay_id IS NOT NULL
  UNION ALL
  SELECT amount
    , amountuom
    , icustay_id
    , endtime AS charttime
  FROM `physionet-data.mimiciii_clinical.inputevents_mv`
  WHERE itemid in
  (
    220970   -- Fresh Frozen Plasma
  )
  AND amount > 0
  AND icustay_id IS NOT NULL
),
pre_icu_ffp as (
  SELECT
    sum(amount) as amount, icustay_id
  FROM `physionet-data.mimiciii_clinical.inputevents_cv`
  WHERE itemid IN (
    44172,  -- FFP GTT         
    44236,  -- E.R. FFP        
    46410,  -- angio FFP
    46418,  -- ER ffp
    46684,  -- ER FFP
    44819,  -- FFP ON FARR 2
    46530,  -- Floor FFP       
    44044,  -- FFP Drip
    46122,  -- ER in FFP
    45669,  -- ED FFP
    42323   -- er ffp
  )
  AND amount > 0
  AND icustay_id IS NOT NULL
  GROUP BY icustay_id
  UNION ALL
  SELECT
    sum(amount) as amount, icustay_id
  FROM `physionet-data.mimiciii_clinical.inputevents_mv`
  WHERE itemid IN (
    227072  -- PACU FFP Intake
  )
  AND amount > 0
  AND icustay_id IS NOT NULL
  GROUP BY icustay_id
),
cumulative AS (
  SELECT
    sum(amount) over (PARTITION BY icustay_id ORDER BY charttime DESC) AS amount
    , amountuom
    , icustay_id
    , charttime
    , DATETIME_DIFF(lag(charttime) over (PARTITION BY icustay_id ORDER BY charttime ASC), charttime, HOUR) AS delta
  FROM raw_ffp
)
-- We consider any transfusions started within 1 hr of the last one
-- to be part of the same event
SELECT
    cm.icustay_id
  , cm.charttime
  , ROUND(CAST(cm.amount AS numeric) - CASE
      WHEN ROW_NUMBER() OVER w = 1 THEN CAST(0 AS numeric)
      ELSE cast(lag(cm.amount) OVER w AS numeric)
    END, 2) AS amount
  , ROUND(CAST(cm.amount AS numeric) + CASE
      WHEN pre.amount IS NULL THEN CAST(0 AS numeric)
      ELSE CAST(pre.amount AS numeric)
    END, 2) AS totalamount
  , cm.amountuom
FROM cumulative AS cm
LEFT JOIN pre_icu_ffp AS pre
  USING (icustay_id)
WHERE delta IS NULL OR delta < -1
WINDOW w AS (PARTITION BY cm.icustay_id ORDER BY cm.charttime DESC)
ORDER BY icustay_id, charttime;
