-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ventilation_durations; CREATE TABLE mimiciii_derived.ventilation_durations AS
WITH vd0 AS (
  SELECT
    icustay_id,
    CASE
      WHEN MechVent = 1
      THEN LAG(CHARTTIME, 1) OVER (PARTITION BY icustay_id, MechVent ORDER BY charttime NULLS FIRST)
      ELSE NULL
    END AS charttime_lag,
    charttime,
    MechVent,
    OxygenTherapy,
    Extubated,
    SelfExtubated
  FROM mimiciii_derived.ventilation_classification
), vd1 AS (
  SELECT
    icustay_id,
    charttime_lag,
    charttime,
    MechVent,
    OxygenTherapy,
    Extubated,
    SelfExtubated,
    CASE
      WHEN MechVent = 1
      THEN DATE_DIFF('MINUTE', charttime_lag, CHARTTIME) / 60
      ELSE NULL
    END AS ventduration,
    LAG(Extubated, 1) OVER (
      PARTITION BY icustay_id, CASE WHEN MechVent = 1 OR Extubated = 1 THEN 1 ELSE 0 END
      ORDER BY charttime NULLS FIRST, extubated NULLS FIRST
    ) AS ExtubatedLag,
    CASE
      WHEN LAG(Extubated, 1) OVER (
        PARTITION BY icustay_id, CASE WHEN MechVent = 1 OR Extubated = 1 THEN 1 ELSE 0 END
        ORDER BY charttime NULLS FIRST, extubated NULLS FIRST
      ) = 1
      THEN 1
      WHEN MechVent = 0 AND OxygenTherapy = 1
      THEN 1
      WHEN CHARTTIME > charttime_lag + INTERVAL '8' HOUR
      THEN 1
      ELSE 0
    END AS newvent
  FROM vd0 AS ventsettings
), vd2 AS (
  SELECT
    vd1.*,
    CASE
      WHEN MechVent = 1 OR Extubated = 1
      THEN SUM(newvent) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST)
      ELSE NULL
    END AS ventnum
  FROM vd1
)
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY ventnum NULLS FIRST) AS ventnum,
  MIN(charttime) AS starttime,
  MAX(charttime) AS endtime,
  DATE_DIFF('MINUTE', MIN(charttime), MAX(charttime)) / 60 AS duration_hours
FROM vd2
GROUP BY
  icustay_id,
  vd2.ventnum
HAVING
  MIN(charttime) <> MAX(charttime) AND MAX(mechvent) = 1
ORDER BY
  icustay_id NULLS FIRST,
  ventnum NULLS FIRST