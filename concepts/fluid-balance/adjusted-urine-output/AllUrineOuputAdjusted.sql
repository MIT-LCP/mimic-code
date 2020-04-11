-- This is urine-output adjustment corrected to 1 hour intervals, on the hour.
-- This adjustment is meant to be used for AKI calculation and other research purposes.
-- Each ICUSTAY_ID has "T_PLUS" column that represent the hourly intervals from the begining to the end of
-- his urine outputevents.

-- The problem with regular urine-outputs in outputevents: measurements are:
--  (1) At diffrent time on the clock, you can have two measurements at one hour interval (e.g. 00:01, 00:59).
--  (2) With diffrent time interval between them.
-- Since urine collection is done per unit of time from the last measurment, every value should be corrected
-- for the time length it represent.

-- The solution is summing up:
--  1st sample in the interval - is multiplied by the portion of time inside the interval to the full length of time.
--  1st sample of the NEXT interval  - is multiplied by the portion of time inside the interval to the full length of time.
--  Other samples in the interval - simply added.

CREATE OR REPLACE TABLE `Tables.AllUrineOutputsAdjusted` 
AS

WITH uo AS (
-- relevant urine-ouput columns
  SELECT ICUSTAY_ID, CHARTTIME, VALUE, 
  --   CIS method
   If(oe.itemid < 50000, "CareVue", "MetaVision") as CIS
  FROM `mimic-iii-256413.Tables.AllUrineOutputs` oe
  
    WHERE oe.ICUSTAY_ID  in (SELECT ICUSTAY_ID FROM `Tables.ICUSTAY_IDs`)
--   ALTERNATIVE: pick specific icustay_id or iterate array of icustay_id. can limit array iteration
--   WHERE oe.ICUSTAY_ID  in (299993)
--   WHERE oe.ICUSTAY_ID  in (SELECT ICUSTAY_ID FROM `Tables.ICUSTAY_IDs` LIMIT 10)

  GROUP BY ICUSTAY_ID, CHARTTIME, VALUE, oe.itemid
  ORDER BY ICUSTAY_ID, charttime asc
), 
RAW_ARRAY_OF_TIMES AS (
-- array of numbers that represent total hours measured for specific icustay_id + start-time rounded up
  SELECT ICUSTAY_ID, GENERATE_ARRAY(1, DATETIME_DIFF(max(uo.charttime), min(uo.charttime), hour), 1) ary, 
    DATETIME_TRUNC(min(uo.charttime), HOUR)  start_time_rounded_up
  FROM uo
  GROUP BY ICUSTAY_ID
),
LISTED_ARRAY_OF_TIMES AS (
  SELECT * FROM RAW_ARRAY_OF_TIMES CROSS JOIN UNNEST(ary) as T_PLUS
  ORDER BY ICUSTAY_ID, T_PLUS
),
TIMES_WITH_INTERVALS AS (
-- total hours list + absolute time intervals
  SELECT laot.ICUSTAY_ID, laot.T_PLUS, laot.START_TIME_ROUNDED_UP,
    DATETIME_ADD(start_time_rounded_up, INTERVAL T_PLUS HOUR) as TIME_INTERVAL_STARTS,
    DATETIME_ADD(start_time_rounded_up, INTERVAL T_PLUS + 1 HOUR) as TIME_INTERVAL_FINISH,
  FROM LISTED_ARRAY_OF_TIMES laot
  GROUP BY laot.T_PLUS, laot.ICUSTAY_ID, laot.START_TIME_ROUNDED_UP, TIME_INTERVAL_STARTS, TIME_INTERVAL_FINISH
  ORDER BY laot.ICUSTAY_ID, laot.T_PLUS
),
INTERVALS_WITH_TIMES_AND_UO AS (
-- count how many urine-output chart-events for every hourly interval, specify datetime. 
-- also adds last datetime event before the interval + first event after: datetime and value
---- ALL THE MINIMAL NEEDS FOR THE ADJUSTED CALCULATION IS PRESENT. ----
  SELECT twi.ICUSTAY_ID, T_PLUS, START_TIME_ROUNDED_UP, TIME_INTERVAL_STARTS, TIME_INTERVAL_FINISH,
    COUNT(case when (uo.charttime BETWEEN twi.TIME_INTERVAL_STARTS AND twi.TIME_INTERVAL_FINISH) AND 
      (uo.ICUSTAY_ID = twi.ICUSTAY_ID) then uo.charttime end) 
      AS NUMBER_OF_OUTPUTS_IN_INTERVAL,
    ARRAY_AGG(case when (uo.charttime BETWEEN twi.TIME_INTERVAL_STARTS AND twi.TIME_INTERVAL_FINISH) AND 
      (uo.ICUSTAY_ID = twi.ICUSTAY_ID) then uo.charttime end IGNORE NULLS ORDER BY uo.charttime)
      AS ARRAY_OF_TIMES_IN_INTERVALL,
    ARRAY_AGG(case when (uo.charttime BETWEEN twi.TIME_INTERVAL_STARTS AND twi.TIME_INTERVAL_FINISH) AND 
      (uo.ICUSTAY_ID = twi.ICUSTAY_ID) then uo.value end IGNORE NULLS ORDER BY uo.charttime) 
      AS ARRAY_OF_UO,
    ARRAY_REVERSE(ARRAY_AGG(case when (uo.charttime <= twi.TIME_INTERVAL_STARTS) AND 
      (uo.ICUSTAY_ID = twi.ICUSTAY_ID) then uo.charttime end IGNORE NULLS ORDER BY uo.charttime))[OFFSET(0)] 
      AS TIME_BEFORE,
    ARRAY_AGG(case when (uo.charttime > twi.TIME_INTERVAL_FINISH) AND 
      (uo.ICUSTAY_ID = twi.ICUSTAY_ID) then uo.charttime end IGNORE NULLS ORDER BY uo.charttime)[OFFSET(0)] 
      AS TIME_AFTER,
    ARRAY_AGG(case when (uo.charttime > twi.TIME_INTERVAL_FINISH) 
      AND (uo.ICUSTAY_ID = twi.ICUSTAY_ID) then uo.value end IGNORE NULLS ORDER BY uo.charttime)[OFFSET(0)] 
      AS UO_AFTER,
  FROM TIMES_WITH_INTERVALS twi 
    LEFT JOIN uo
    ON uo.ICUSTAY_ID = twi.ICUSTAY_ID
  GROUP BY twi.ICUSTAY_ID, T_PLUS, START_TIME_ROUNDED_UP, TIME_INTERVAL_STARTS, TIME_INTERVAL_FINISH
  ORDER BY twi.ICUSTAY_ID, T_PLUS
),
CALCULATION_BOARD1 AS (
-- calculations step 1
  SELECT ICUSTAY_ID, T_PLUS, START_TIME_ROUNDED_UP, TIME_INTERVAL_STARTS, TIME_INTERVAL_FINISH, NUMBER_OF_OUTPUTS_IN_INTERVAL, ARRAY_OF_TIMES_IN_INTERVALL, ARRAY_OF_UO,
    IFNULL((SELECT SUM(s) FROM UNNEST(ARRAY_OF_UO) s), (0)) SIMPLE_SUM,
    TIME_BEFORE,
    IFNULL((DATETIME_DIFF(ARRAY_OF_TIMES_IN_INTERVALL[OFFSET(0)], TIME_INTERVAL_STARTS, minute)), (0)) MINUTES_BEFORE_INTERVAL,
    IFNULL((DATETIME_DIFF(ARRAY_OF_TIMES_IN_INTERVALL[OFFSET(0)], TIME_BEFORE, minute)), (null)) MINUTES_BEFORE_TOTAL,
    TIME_AFTER,
    UO_AFTER,
    IFNULL((DATETIME_DIFF(TIME_INTERVAL_FINISH, ARRAY_REVERSE(ARRAY_OF_TIMES_IN_INTERVALL)[OFFSET(0)], minute)), (60)) MINUTES_AFTER_INTERVAL,
    IFNULL((DATETIME_DIFF(TIME_AFTER, ARRAY_REVERSE(ARRAY_OF_TIMES_IN_INTERVALL)[OFFSET(0)], minute)), (
      DATETIME_DIFF(TIME_AFTER, TIME_BEFORE, minute))
    ) MINUTES_AFTER_TOTAL,
  FROM INTERVALS_WITH_TIMES_AND_UO
  ORDER BY ICUSTAY_ID, T_PLUS
),
CALCULATION_BOARD2 AS (
-- calculations step 2
  SELECT *,
    (CASE WHEN (MINUTES_BEFORE_TOTAL IS NULL) OR (MINUTES_BEFORE_TOTAL = 0) THEN 0 ELSE 
      MINUTES_BEFORE_INTERVAL / MINUTES_BEFORE_TOTAL
    END) FIRST_UO_PORTION,
    (CASE WHEN (MINUTES_AFTER_TOTAL IS NULL) OR (MINUTES_AFTER_TOTAL = 0) THEN 0 ELSE 
      MINUTES_AFTER_INTERVAL / MINUTES_AFTER_TOTAL
    END) AFTER_UO_PORTION
  FROM CALCULATION_BOARD1
  ORDER BY ICUSTAY_ID, T_PLUS
),
FINAL_CALC AS (
-- calculations step 3 (FINAL)
-- all the steps for all the calculation present for quality chck
  SELECT *,
    CAST(
      IF (((NUMBER_OF_OUTPUTS_IN_INTERVAL = 0) AND (((MINUTES_BEFORE_TOTAL IS NULL) OR (MINUTES_BEFORE_TOTAL > 120)) AND ((MINUTES_AFTER_TOTAL IS NULL) OR (MINUTES_AFTER_TOTAL > 240)))),
      NULL,    
        (IFNULL((SELECT SUM(s) FROM UNNEST(ARRAY_OF_UO) s), (0))) - (IFNULL((ARRAY_OF_UO[OFFSET(0)]), (0))) +
        ((IFNULL((ARRAY_OF_UO[OFFSET(0)]), (0))) * (IFNULL(FIRST_UO_PORTION, 0))) +
        ((IFNULL(UO_AFTER, 0)) * (IFNULL(AFTER_UO_PORTION, 0)))
      )
    AS INT64) ADJUSTED_SUM
  FROM CALCULATION_BOARD2
  ORDER BY ICUSTAY_ID, T_PLUS
),
SUMMARY AS (
-- minimal summary
  SELECT ICUSTAY_ID, T_PLUS, TIME_INTERVAL_STARTS, TIME_INTERVAL_FINISH, SIMPLE_SUM, ADJUSTED_SUM
  FROM FINAL_CALC
  ORDER BY ICUSTAY_ID, T_PLUS
)

SELECT * FROM SUMMARY
ORDER BY ICUSTAY_ID, T_PLUS

