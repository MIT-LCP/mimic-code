-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ventilation_durations; CREATE TABLE mimiciii_derived.ventilation_durations AS
/* This query extracts the duration of mechanical ventilation */ /* The main goal of the query is to aggregate sequential ventilator settings */ /* into single mechanical ventilation "events". The start and end time of these */ /* events can then be used for various purposes: calculating the total duration */ /* of mechanical ventilation, cross-checking values (e.g. PaO2:FiO2 on vent), etc */ /* The query's logic is roughly: */ /*    1) The presence of a mechanical ventilation setting starts a new ventilation event */ /*    2) Any instance of a setting in the next 8 hours continues the event */ /*    3) Certain elements end the current ventilation event */ /*        a) documented extubation ends the current ventilation */ /*        b) initiation of non-invasive vent and/or oxygen ends the current vent */ /* See the ventilation_classification.sql query for step 1 of the above. */ /* This query has the logic for converting events into durations. */
WITH vd0 AS (
  SELECT
    icustay_id, /* this carries over the previous charttime which had a mechanical ventilation event */
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
    SelfExtubated, /* if this is a mechanical ventilation event, we calculate the time since the last event */
    CASE
      WHEN MechVent = 1
      THEN CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('minute', CHARTTIME) - DATE_TRUNC('minute', charttime_lag)) / 60 AS BIGINT) AS DOUBLE PRECISION) / 60
      ELSE NULL
    END AS ventduration,
    LAG(Extubated, 1) OVER (
      PARTITION BY icustay_id, CASE WHEN MechVent = 1 OR Extubated = 1 THEN 1 ELSE 0 END
      ORDER BY charttime NULLS FIRST, extubated NULLS FIRST
    ) AS ExtubatedLag, /* now we determine if the current mech vent event is a "new", i.e. they've just been intubated */
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
  /* use the staging table with only vent settings from chart events */
  FROM vd0 AS ventsettings
), vd2 AS (
  SELECT
    vd1.*, /* create a cumulative sum of the instances of new ventilation */ /* this results in a monotonic integer assigned to each instance of ventilation */
    CASE
      WHEN MechVent = 1 OR Extubated = 1
      THEN SUM(newvent) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST)
      ELSE NULL
    END AS ventnum
  /* - now we convert CHARTTIME of ventilator settings into durations */
  FROM vd1
)
/* create the durations for each mechanical ventilation instance */
SELECT
  icustay_id, /* regenerate ventnum so it's sequential */
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY ventnum NULLS FIRST) AS ventnum,
  MIN(charttime) AS starttime,
  MAX(charttime) AS endtime,
  CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('minute', MAX(charttime)) - DATE_TRUNC('minute', MIN(charttime))) / 60 AS BIGINT) AS DOUBLE PRECISION) / 60 AS duration_hours
FROM vd2
GROUP BY
  icustay_id,
  vd2.ventnum
HAVING
  MIN(charttime) <> MAX(charttime)
  AND /* patient had to be mechanically ventilated at least once */ /* i.e. max(mechvent) should be 1 */ /* this excludes a frequent situation of NIV/oxygen before intub */ /* in these cases, ventnum=0 and max(mechvent)=0, so they are ignored */ MAX(mechvent) = 1
ORDER BY
  icustay_id NULLS FIRST,
  ventnum NULLS FIRST