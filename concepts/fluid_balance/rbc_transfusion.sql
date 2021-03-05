-- Retrieves instances of red blood cell transfusions
with raw_rbc as (
  SELECT
      CASE
        WHEN amount IS NOT NULL THEN amount
        WHEN stopped IS NOT NULL THEN 0
        -- impute 375 mL when unit is not documented
        ELSE 375
      END AS amount
    , amountuom
    , icustay_id
    , charttime
  FROM `physionet-data.mimiciii_clinical.inputevents_cv`
  WHERE itemid IN
  (
    30179,  -- PRBC's
    30001,  -- Packed RBC's
    30004   -- Washed PRBC's
  )
  AND icustay_id IS NOT NULL
  UNION ALL
  SELECT amount
    , amountuom
    , icustay_id
    , endtime AS charttime
  FROM `physionet-data.mimiciii_clinical.inputevents_mv`
  WHERE itemid in
  (
    225168   -- Packed Red Blood Cells
  )
  AND amount > 0
  AND icustay_id IS NOT NULL
),
pre_icu_rbc as (
  SELECT
    sum(amount) as amount, icustay_id
  FROM `physionet-data.mimiciii_clinical.inputevents_cv`
  WHERE itemid IN (
    42324,  -- er prbc
    42588,  -- VICU PRBC
    42239,  -- CC7 PRBC
    46407,  -- ED PRBC
    46612,  -- E.R. prbc
    46124,  -- er in prbc
    42740   -- prbc in er
  )
  AND amount > 0
  AND icustay_id IS NOT NULL
  GROUP BY icustay_id
  UNION ALL
  SELECT
    sum(amount) as amount, icustay_id
  FROM `physionet-data.mimiciii_clinical.inputevents_mv`
  WHERE itemid IN (
    227070  -- PACU Packed RBC Intake
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
  FROM raw_rbc
)
-- We consider any transfusions started within 1 hr of the last one
-- to be part of the same event
SELECT
    cm.icustay_id
  , cm.charttime
  , ROUND(CAST(cm.amount AS numeric) - CASE
      WHEN ROW_NUMBER() OVER w = 1 THEN CAST(0 AS numeric)
      ELSE CAST(lag(cm.amount) OVER w AS numeric)
    END, 2) AS amount
  , ROUND(CAST(cm.amount AS numeric) + CASE
      WHEN CAST(pre.amount AS numeric) IS NULL THEN CAST(0 AS numeric)
      ELSE CAST(pre.amount AS numeric)
    END, 2) AS totalamount
  , cm.amountuom
FROM cumulative AS cm
LEFT JOIN pre_icu_rbc AS pre
  USING (icustay_id)
WHERE delta IS NULL OR delta < -1
WINDOW w AS (PARTITION BY cm.icustay_id ORDER BY cm.charttime DESC)
ORDER BY icustay_id, charttime;
