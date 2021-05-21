-- Create a table tracking patient fluid balance
-- A net output of fluid is represented as a negative value
-- Create 1 row per administration start, with the rate
-- Create 1 row per administration end, with the negative rate
-- Afterwards we can cumulatively sum over rows to aggregate different start/end times
-- TODO: preadmission intake
WITH fm AS
(
    SELECT label, itemid, fl_mp.group as grp, preadmission
    FROM `physionet-data.mimiciii_derived.fluid_map` fl_mp
    WHERE fl_mp.group IN (
        'Blood Product',
        'Colloid',
        'Crystalloid',
        'Dialysis - Input',
        'Dialysis - Output',
        'Drain',
        'General Intake',
        'General Output',
        'Irrigant',
        'Oral',
        'Urine Output',
        'Nutrition'
    )
)
-- get rates from metavision
, mv AS (
    SELECT
        mv.icustay_id,
        -- SMOOTHING STEP: if a bolus, we assume given over 1 hour
        -- this is a very conservative overestimate, to prevent unrealistic jumps in fluid balance
        CASE
          WHEN mv.starttime = DATETIME_SUB(mv.endtime, interval 1 minute)
           AND mv.rate IS NULL
          THEN DATETIME_SUB(mv.endtime, interval 1 hour)
        ELSE mv.starttime end as starttime,
        mv.endtime,
        fm.grp, fm.preadmission,
        -- convert all amounts into milliliters
        CASE
            WHEN mv.amountuom = 'uL' THEN mv.amount / 1000.0
            WHEN mv.amountuom = 'L' THEN mv.amount * 1000.0
            WHEN mv.amountuom in ('ml','mL') THEN mv.amount
        ELSE null END AS amount
    FROM `physionet-data.mimiciii_clinical.inputevents_mv` mv
    INNER JOIN fm
      ON mv.itemid = fm.itemid
    WHERE mv.statusdescription != 'Rewritten'
      AND mv.amount > 0 -- remove negative and 0 values.
      AND mv.amountuom in ('uL', 'L', 'ml', 'mL')
)
-- collapse values charted at the same time
-- frequently occurs for drains/pre-admission output/general output
, oe_stg AS (
  SELECT
      o.icustay_id,
      o.itemid,
      o.charttime,
      SUM(o.value) as amount
  FROM `physionet-data.mimiciii_clinical.outputevents` o
  WHERE itemid IN (select itemid from fm)
    AND COALESCE(CAST(o.iserror AS INT64), 0) = 0
  GROUP BY icustay_id, itemid, charttime
)
, oe AS (
  SELECT
      o.icustay_id,
      COALESCE(LAG(o.charttime) OVER
      (
        PARTITION BY o.icustay_id, o.itemid ORDER BY o.charttime
      ), DATETIME_SUB(o.charttime, interval 1 hour)) as starttime,
      o.charttime as endtime,
      fm.grp, fm.preadmission,
      o.amount
  FROM oe_stg o
  INNER JOIN fm
    ON o.itemid = fm.itemid
)
, cv_stg AS (
  SELECT
      cv.icustay_id,
      cv.itemid,
      cv.charttime,
      cv.linkorderid,
      -- convert all amounts into milliliters
      SUM(
      CASE
          WHEN cv.amountuom = 'uL' THEN cv.amount / 1000.0
          WHEN cv.amountuom = 'L' THEN cv.amount * 1000.0
          WHEN cv.amountuom in ('ml','mL') THEN cv.amount
      ELSE null END) AS amount
  FROM `physionet-data.mimiciii_clinical.inputevents_cv` cv
  WHERE itemid IN (select itemid from fm)
    AND cv.amount > 0 -- remove negative and 0 values.
    AND cv.amountuom in ('uL', 'L', 'ml', 'mL')
  GROUP BY icustay_id, itemid, charttime, linkorderid
)
, cv AS (
  SELECT
      cv.icustay_id,
      COALESCE(LAG(cv.charttime) OVER
        (
          PARTITION BY cv.linkorderid, cv.itemid ORDER BY cv.charttime
        ), DATETIME_SUB(cv.charttime, interval 1 hour)) as starttime,
      cv.charttime as endtime,
      fm.grp, fm.preadmission,
      cv.amount
  FROM cv_stg cv
  INNER JOIN fm
    ON cv.itemid = fm.itemid
)
, ce AS
(
  SELECT
    ce.icustay_id,
    DATETIME_SUB(ce.charttime, interval 1 hour) as starttime,
    ce.charttime as endtime,
    fm.grp, fm.preadmission,
    -- convert all amounts into milliliters
    CASE
        -- hemodialysis output - fix negation as necessary
        WHEN ce.itemid = 226499 THEN
          CASE
            WHEN ce.valuenum < 0  THEN -1.0*ce.valuenum
            WHEN ce.valuenum < 10 THEN ce.valuenum * 1000.0
            ELSE ce.valuenum
          END
        WHEN ce.valueuom = 'uL' THEN ce.valuenum / 1000.0
        WHEN ce.valueuom = 'L'  THEN ce.valuenum * 1000.0
        WHEN ce.valueuom in ('ml','mL') THEN ce.valuenum
    ELSE null END AS amount
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  INNER JOIN fm
     ON ce.itemid = fm.itemid
  WHERE ce.itemid IN (select itemid from fm)
    -- exclude itemid dealt with below
    AND ce.itemid != 224191
    AND ce.valuenum IS NOT NULL
    AND coalesce(ce.error, 0) = 0
)
, ce_hrly AS
(
  SELECT
      c.icustay_id,
      COALESCE(LAG(c.charttime) OVER
        (
          PARTITION BY hadm_id ORDER BY c.charttime
        ), DATETIME_SUB(c.charttime, interval 1 hour)) as starttime,
      c.charttime as endtime,
      fm.grp, fm.preadmission,
      -- there are some single digit values, but can't guarantee these are L
      (CASE
          WHEN c.valuenum < 0 THEN -1.0*c.valuenum
      ELSE c.valuenum END) AS rate_per_hour
  FROM `physionet-data.mimiciii_clinical.chartevents` c
  INNER JOIN fm
    ON c.itemid = fm.itemid
  WHERE c.itemid = 224191
  AND c.valuenum IS NOT NULL
  AND coalesce(c.error, 0) = 0
)
-- union above tables
, t1 as
(
  SELECT
    icustay_id, starttime, endtime,
    grp, preadmission,
    amount
  FROM cv
  UNION ALL
  SELECT
    icustay_id, starttime, endtime,
    grp, preadmission,
    amount
  FROM mv
  UNION ALL
  SELECT
    icustay_id, starttime, endtime,
    grp, preadmission,
    amount
  FROM oe
  UNION ALL
  SELECT
    icustay_id, starttime, endtime,
    grp, preadmission,
    amount
  FROM ce
  UNION ALL
  SELECT
    icustay_id, starttime, endtime,
    grp, preadmission,
    (rate_per_hour)*(DATETIME_DIFF(endtime, starttime, second)/60.0/60.0) as amount
  FROM ce_hrly
)
, t2 AS
(
-- Calculate a rate per second for each administration
-- Necessary as bolus administrations are not given with a rate
-- Ignore preadmission intake for now
SELECT
icustay_id, starttime, endtime,
grp,
CASE
    WHEN grp in ('Blood Product', 'Blood Factor') THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_blood_product,
CASE
    WHEN grp = 'Colloid' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_colloid,
CASE
    WHEN grp = 'Crystalloid' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_crystalloid,
CASE
    WHEN grp = 'Dialysis - Input' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_dialysis_input,
CASE
    WHEN grp = 'Dialysis - Output' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_dialysis_output,
CASE
    WHEN grp = 'Drain' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_drain,
CASE
    WHEN grp = 'Irrigant' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_irrigant,
CASE
    WHEN grp = 'Oral' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_oral,
CASE
    WHEN grp = 'General Intake' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_general_intake,
CASE
    WHEN grp = 'Nutrition' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_nutrition,
CASE
    WHEN grp = 'General Output' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_general_output,
CASE
    WHEN grp = 'Urine Output' THEN amount / DATETIME_DIFF(endtime, starttime, second)
    ELSE 0
END AS rate_uo
FROM t1
WHERE preadmission IS NULL
AND amount != 0
AND amount IS NOT NULL
)
, fluid_balance_staging AS
(
    SELECT
        icustay_id, charttime,
        -- Cumulatively sum rate over the window
        SUM(rate_all) OVER W AS rate_all,
        SUM(rate_blood_product) OVER W AS rate_blood_product,
        SUM(rate_colloid) OVER W AS rate_colloid,
        SUM(rate_crystalloid) OVER W AS rate_crystalloid,
        SUM(rate_dialysis_input) OVER W AS rate_dialysis_input,
        SUM(rate_dialysis_output) OVER W AS rate_dialysis_output,
        SUM(rate_drain) OVER W AS rate_drain,
        SUM(rate_irrigant) OVER W AS rate_irrigant,
        SUM(rate_oral) OVER W AS rate_oral,
        SUM(rate_general_intake) OVER W AS rate_general_intake,
        SUM(rate_general_output) OVER W AS rate_general_output,
        SUM(rate_nutrition) OVER W AS rate_nutrition,
        SUM(rate_uo) OVER W AS rate_uo,
        -- The end of the current row == the start of the next row
        -- This may generate rows with rate of 0 (no ongoing administration)
        -- These are filtered out later when we require rate > 0
        LEAD(charttime) OVER W AS charttime_lead,
        DATETIME_DIFF(LEAD(charttime) OVER W, charttime, second) as leadtime_seconds,
        ROW_NUMBER() OVER W AS rn
    FROM 
    (
    SELECT
        icustay_id, starttime as charttime, grp,
        rate_blood_product + rate_oral + rate_colloid + rate_crystalloid
            + rate_nutrition
            + rate_dialysis_input - rate_dialysis_output
            + rate_general_intake - rate_general_output
            - rate_uo - rate_drain
            AS rate_all,
        rate_blood_product,
        rate_colloid,
        rate_crystalloid,
        rate_dialysis_input,
        rate_dialysis_output,
        rate_drain,
        rate_irrigant,
        rate_oral,
        rate_general_intake,
        rate_general_output,
        rate_nutrition,
        rate_uo
    FROM t2
    UNION ALL
    SELECT
        icustay_id, endtime as charttime, grp
        , -1*(rate_blood_product + rate_oral + rate_colloid + rate_crystalloid
                + rate_nutrition
                + rate_dialysis_input - rate_dialysis_output
                + rate_general_intake - rate_general_output
                - rate_uo - rate_drain)
            AS rate_all,
        -1*rate_blood_product as rate_blood_product,
        -1*rate_colloid as rate_colloid,
        -1*rate_crystalloid as rate_crystalloid,
        -1*rate_dialysis_input as rate_dialysis_input,
        -1*rate_dialysis_output as rate_dialysis_output,
        -1*rate_drain as rate_drain,
        -1*rate_irrigant as rate_irrigant,
        -1*rate_oral as rate_oral,
        -1*rate_general_intake AS rate_general_intake,
        -1*rate_general_output AS rate_general_output,
        -1*rate_nutrition AS rate_nutrition,
        -1*rate_uo AS rate_uo
    FROM t2
    ) t3
    WINDOW W AS (PARTITION BY icustay_id ORDER BY charttime)
)
SELECT
    icustay_id,
    charttime as starttime,
    charttime_lead as endtime,
    -- Convert from rate/second to rate/hour
    ROUND((
        rate_blood_product + rate_oral + rate_colloid + rate_crystalloid
      + rate_nutrition
      + rate_dialysis_input - rate_dialysis_output
      + rate_general_intake - rate_general_output
      - rate_uo - rate_drain
    ) * 60 * 60, 4) as rate_all,
    ROUND((
        rate_blood_product + rate_oral + rate_colloid + rate_crystalloid
      + rate_nutrition
      + rate_dialysis_input - rate_dialysis_output
      + rate_general_intake - rate_general_output
    ) * 60 * 60, 4) as rate_in,
    ROUND((
        rate_dialysis_output + rate_general_output + rate_uo + rate_drain
    ) * 60 * 60, 4) as rate_out
    
    -- original rates, converted to per hour (rather than per second)
    ROUND((rate_blood_product * 60 * 60), 4) as rate_blood_product,
    ROUND((rate_colloid * 60 * 60), 4) as rate_colloid,
    ROUND((rate_crystalloid * 60 * 60), 4) as rate_crystalloid,
    ROUND((rate_dialysis_input * 60 * 60), 4) as rate_dialysis_input,
    ROUND((rate_dialysis_output * 60 * 60), 4) as rate_dialysis_output,
    ROUND((rate_drain * 60 * 60), 4) as rate_drain,
    ROUND((rate_irrigant * 60 * 60), 4) as rate_irrigant,
    ROUND((rate_oral * 60 * 60), 4) as rate_oral,
    ROUND((rate_general_intake * 60 * 60), 4) AS rate_general_intake,
    ROUND((rate_general_output * 60 * 60), 4) AS rate_general_output,
    ROUND((rate_nutrition * 60 * 60), 4) AS rate_nutrition,
    ROUND((rate_uo * 60 * 60), 4) AS rate_uo,
    
    -- Calculate amount
    ROUND((rate_all * leadtime_seconds), 4) as amount_all,
    ROUND((rate_blood_product * leadtime_seconds), 4) as amount_blood_product,
    ROUND((rate_colloid * leadtime_seconds), 4) as amount_colloid,
    ROUND((rate_crystalloid * leadtime_seconds), 4) as amount_crystalloid,
    ROUND((rate_dialysis_input * leadtime_seconds), 4) as amount_dialysis_input,
    ROUND((rate_dialysis_output * leadtime_seconds), 4) as amount_dialysis_output,
    ROUND((rate_drain * leadtime_seconds), 4) as amount_drain,
    ROUND((rate_irrigant * leadtime_seconds), 4) as amount_irrigant,
    ROUND((rate_oral * leadtime_seconds), 4) as amount_oral,
    ROUND((rate_general_intake * leadtime_seconds), 4) AS amount_general_intake,
    ROUND((rate_general_output * leadtime_seconds), 4) AS amount_general_output,
    ROUND((rate_nutrition * leadtime_seconds), 4) AS amount_nutrition,
    ROUND((rate_uo * leadtime_seconds), 4) AS amount_uo

from fluid_balance_staging t4
-- require there to be an ongoing administration
WHERE
  -- ABS(ROUND((rate_all * 60 * 60)::NUMERIC, 4)) > 0
  -- AND
  charttime != charttime_lead
;