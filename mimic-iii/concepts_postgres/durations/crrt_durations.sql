-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.crrt_durations; CREATE TABLE mimiciii_derived.crrt_durations AS
WITH crrt_settings AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    MAX(
      CASE
        WHEN ce.itemid IN (
          224149, /* Access Pressure */
          224144, /* Blood Flow (ml/min) */
          228004, /* Citrate (ACD-A) */
          225183, /* Current Goal */
          225977, /* Dialysate Fluid */
          224154, /* Dialysate Rate */
          224151, /* Effluent Pressure */
          224150, /* Filter Pressure */
          225958, /* Heparin Concentration (units/mL) */
          224145, /* Heparin Dose (per hour) */
          224191, /* Hourly Patient Fluid Removal */
          228005, /* PBP (Prefilter) Replacement Rate */
          228006, /* Post Filter Replacement Rate */
          225976, /* Replacement Fluid */
          224153, /* Replacement Rate */
          224152, /* Return Pressure */
          226457 /* Ultrafiltrate Output */
        )
        THEN 1
        WHEN ce.itemid IN (
          29, /* Access mmHg */
          173, /* Effluent Press mmHg */
          192, /* Filter Pressure mmHg */
          624, /* Return Pressure mmHg */
          79, /* Blood Flow ml/min */
          142, /* Current Goal */
          146, /* Dialysate Flow ml/hr */
          611, /* Replace Rate ml/hr */
          5683 /* Hourly PFR */
        )
        THEN 1
        WHEN ce.itemid = 665
        AND value IN ('Active', 'Clot Increasing', 'Clots Present', 'No Clot Present')
        THEN 1
        WHEN ce.itemid = 147 AND value = 'Yes'
        THEN 1
        ELSE 0
      END
    ) AS RRT, /* Below indicates that a new instance of CRRT has started */
    MAX(
      CASE
        WHEN ce.itemid = 224146 AND value IN ('New Filter', 'Reinitiated')
        THEN 1
        WHEN ce.itemid = 665 AND value IN ('Initiated')
        THEN 1
        ELSE 0
      END
    ) AS RRT_start, /* Below indicates that the current instance of CRRT has ended */
    MAX(
      CASE
        WHEN ce.itemid = 224146 AND value IN ('Discontinued', 'Recirculating')
        THEN 1
        WHEN ce.itemid = 665 AND (
          value = 'Clotted' OR value LIKE 'DC%'
        )
        THEN 1
        WHEN ce.itemid = 225956
        THEN 1
        ELSE 0
      END
    ) AS RRT_end
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.itemid IN (
      224146, /* MetaVision ITEMIDs */ /* Below require special handling */ /* System Integrity */
      225956, /* Reason for CRRT Filter Change */
      224149, /* Below are settings which indicate CRRT is started/continuing */ /* Access Pressure */
      224144, /* Blood Flow (ml/min) */
      228004, /* Citrate (ACD-A) */
      225183, /* Current Goal */
      225977, /* Dialysate Fluid */
      224154, /* Dialysate Rate */
      224151, /* Effluent Pressure */
      224150, /* Filter Pressure */
      225958, /* Heparin Concentration (units/mL) */
      224145, /* Heparin Dose (per hour) */
      224191, /* Hourly Patient Fluid Removal */
      228005, /* PBP (Prefilter) Replacement Rate */
      228006, /* Post Filter Replacement Rate */
      225976, /* Replacement Fluid */
      224153, /* Replacement Rate */
      224152, /* Return Pressure */
      226457, /* Ultrafiltrate Output */
      665, /* CareVue ITEMIDs */ /* Below require special handling */ /* System integrity */
      147, /* Dialysate Infusing */
      612, /* Replace.Fluid Infuse */
      29, /* Below are settings which indicate CRRT is started/continuing */ /* Access mmHg */
      173, /* Effluent Press mmHg */
      192, /* Filter Pressure mmHg */
      624, /* Return Pressure mmHg */
      142, /* Current Goal */
      79, /* Blood Flow ml/min */
      146, /* Dialysate Flow ml/hr */
      611, /* Replace Rate ml/hr */
      5683 /* Hourly PFR */
    )
    AND NOT ce.value IS NULL
    AND COALESCE(ce.valuenum, 1) <> 0 /* non-zero rates/values */
  GROUP BY
    icustay_id,
    charttime
), vd_lag /* create various lagged variables for future query */ AS (
  SELECT
    icustay_id, /* this carries over the previous charttime */
    LAG(CHARTTIME, 1) OVER W AS charttime_prev_row,
    charttime,
    RRT,
    RRT_start,
    RRT_end,
    LAG(RRT_end, 1) OVER W AS rrt_ended_prev_row
  FROM crrt_settings
  WINDOW w AS (
    PARTITION BY icustay_id, CASE WHEN RRT = 1 OR RRT_end = 1 THEN 1 ELSE 0 END
    ORDER BY charttime NULLS FIRST
  )
), vd1 AS (
  SELECT
    icustay_id,
    charttime,
    RRT,
    RRT_start,
    RRT_end, /* now we determine if the current event is a new instantiation */
    CASE
      WHEN RRT_start = 1
      THEN 1
      WHEN RRT_end = 1
      THEN 0
      WHEN rrt_ended_prev_row = 1
      THEN 1
      WHEN CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', charttime) - DATE_TRUNC('hour', charttime_prev_row)) / 3600 AS BIGINT) <= 2
      THEN 0
      ELSE 1
    END AS NewCRRT
  /* use the temp table with only settings FROM `physionet-data.mimiciii_clinical.chartevents` */
  FROM vd_lag
), vd2 AS (
  SELECT
    vd1.*, /* create a cumulative sum of the instances of new CRRT */ /* this results in a monotonically increasing integer assigned to each CRRT */
    CASE
      WHEN RRT_start = 1 OR RRT = 1 OR RRT_end = 1
      THEN SUM(NewCRRT) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST)
      ELSE NULL
    END AS num
  /* - now we convert CHARTTIME of CRRT settings into durations */
  FROM vd1
  /* now we can isolate to just rows with settings */ /* (before we had rows with start/end flags) */ /* this removes any null values for NewCRRT */
  WHERE
    RRT_start = 1 OR RRT = 1 OR RRT_end = 1
), fin /* create the durations for each CRRT instance */ AS (
  SELECT
    icustay_id,
    num,
    MIN(charttime) AS starttime,
    MAX(charttime) AS endtime,
    CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', MAX(charttime)) - DATE_TRUNC('hour', MIN(charttime))) / 3600 AS BIGINT) AS duration_hours
  /* add durations */
  FROM vd2
  GROUP BY
    icustay_id,
    num
  HAVING
    MIN(charttime) <> MAX(charttime)
)
SELECT
  icustay_id,
  ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS num,
  starttime,
  endtime,
  duration_hours
FROM fin
ORDER BY
  icustay_id NULLS FIRST,
  num NULLS FIRST