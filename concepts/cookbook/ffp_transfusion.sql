-- --------------------------------------------------------
-- Title: Retrieves instances of FFP transfusions
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO public, mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- This will create the table on the "public" schema.
-- --------------------------------------------------------

DROP materialized VIEW IF EXISTS ffp_transfusion CASCADE; 
CREATE materialized VIEW ffp_transfusion AS
WITH raw_ffp AS (
  SELECT
      amount
    , amountuom
    , icustay_id
    , charttime
  FROM inputevents_cv
  WHERE itemid IN
  (
    30005,  -- Fresh Frozen Plasma
    30180   -- Fresh Froz Plasma
  )
  AND amount > 0
  UNION ALL
  SELECT amount
    , amountuom
    , icustay_id
    , endtime AS charttime
  FROM inputevents_mv
  WHERE itemid in
  (
    220970   -- Fresh Frozen Plasma
  )
  AND amount > 0
),
pre_icu_ffp as (
  SELECT
    sum(amount) as amount, icustay_id
  FROM inputevents_cv
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
  GROUP BY icustay_id
  UNION ALL
  SELECT
    sum(amount) as amount, icustay_id
  FROM inputevents_mv
  WHERE itemid IN (
    227072  -- PACU FFP Intake
  )
  AND amount > 0
  GROUP BY icustay_id
),
cumulative AS (
  SELECT
    sum(amount) over (PARTITION BY icustay_id ORDER BY charttime DESC) AS amount
    , amountuom
    , icustay_id
    , charttime
    , lag(charttime) over (PARTITION BY icustay_id ORDER BY charttime ASC) - charttime AS delta
  FROM raw_ffp
)
-- We consider any transfusions started within 1 hr of the last one
-- to be part of the same event
SELECT
    cm.icustay_id
  , cm.charttime
  , cm.amount - CASE
      WHEN ROW_NUMBER() OVER w = 1 THEN 0
      ELSE lag(cm.amount) OVER w
    END AS amount
  , cm.amount + CASE
      WHEN pre.amount IS NULL THEN 0
      ELSE pre.amount
    END AS totalamount
  , cm.amountuom
FROM cumulative AS cm
LEFT JOIN pre_icu_ffp AS pre
  USING (icustay_id)
WHERE delta IS NULL OR delta < CAST('-1 hour' AS INTERVAL)
WINDOW w AS (PARTITION BY cm.icustay_id ORDER BY cm.charttime DESC)
ORDER BY icustay_id, charttime;
