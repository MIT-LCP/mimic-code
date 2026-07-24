-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.arterial_line_durations; CREATE TABLE mimiciii_derived.arterial_line_durations AS
WITH mv AS (
  SELECT
    pe.icustay_id,
    pe.starttime,
    pe.endtime,
    CASE
      WHEN itemid IN (225752, 224272)
      THEN 1
      WHEN pe.locationcategory = 'Invasive Arterial'
      THEN 1
      WHEN itemid = 225789 AND pe.locationcategory IS NULL
      THEN 1
      ELSE 0
    END AS arterial_line
  FROM mimiciii.procedureevents_mv AS pe
  WHERE
    pe.itemid IN (
      224263, /* Multi Lumen | None | 12 | Processes */ /* , 224264 -- PICC Line | None | 12 | Processes */
      224267, /* Cordis/Introducer | None | 12 | Processes */
      224268, /* Trauma line | None | 12 | Processes */
      225199, /* Triple Introducer | None | 12 | Processes */ /* , 225202 -- Indwelling Port (PortaCath) | None | 12 | Processes */ /* , 225203 -- Pheresis Catheter | None | 12 | Processes */ /* , 225315 -- Tunneled (Hickman) Line | None | 12 | Processes */
      225752, /* Arterial Line | None | 12 | Processes */
      225789, /* Sheath */
      224272 /* IABP Line */
    ) /* , 227719 -- AVA Line | None | 12 | Processes */ /* , 228286 -- Intraosseous Device | None | 12 | Processes */
), cv_grp AS (
  /* group type+site */
  SELECT
    ce.icustay_id,
    ce.charttime,
    MAX(CASE WHEN itemid = 229 THEN value ELSE NULL END) AS INV1_Type,
    MAX(CASE WHEN itemid = 8392 THEN value ELSE NULL END) AS INV1_Site,
    MAX(CASE WHEN itemid = 235 THEN value ELSE NULL END) AS INV2_Type,
    MAX(CASE WHEN itemid = 8393 THEN value ELSE NULL END) AS INV2_Site,
    MAX(CASE WHEN itemid = 241 THEN value ELSE NULL END) AS INV3_Type,
    MAX(CASE WHEN itemid = 8394 THEN value ELSE NULL END) AS INV3_Site,
    MAX(CASE WHEN itemid = 247 THEN value ELSE NULL END) AS INV4_Type,
    MAX(CASE WHEN itemid = 8395 THEN value ELSE NULL END) AS INV4_Site,
    MAX(CASE WHEN itemid = 253 THEN value ELSE NULL END) AS INV5_Type,
    MAX(CASE WHEN itemid = 8396 THEN value ELSE NULL END) AS INV5_Site,
    MAX(CASE WHEN itemid = 259 THEN value ELSE NULL END) AS INV6_Type,
    MAX(CASE WHEN itemid = 8397 THEN value ELSE NULL END) AS INV6_Site,
    MAX(CASE WHEN itemid = 265 THEN value ELSE NULL END) AS INV7_Type,
    MAX(CASE WHEN itemid = 8398 THEN value ELSE NULL END) AS INV7_Site,
    MAX(CASE WHEN itemid = 271 THEN value ELSE NULL END) AS INV8_Type,
    MAX(CASE WHEN itemid = 8399 THEN value ELSE NULL END) AS INV8_Site
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.itemid IN (
      229, /* INV Line#1 [Type] */
      235, /* INV Line#2 [Type] */
      241, /* INV Line#3 [Type] */
      247, /* INV Line#4 [Type] */
      253, /* INV Line#5 [Type] */
      259, /* INV Line#6 [Type] */
      265, /* INV Line#7 [Type] */
      271, /* INV Line#8 [Type] */
      8392, /* INV Line#1 [Site] */
      8393, /* INV Line#2 [Site] */
      8394, /* INV Line#3 [Site] */
      8395, /* INV Line#4 [Site] */
      8396, /* INV Line#5 [Site] */
      8397, /* INV Line#6 [Site] */
      8398, /* INV Line#7 [Site] */
      8399 /* INV Line#8 [Site] */
    )
    AND NOT ce.value IS NULL
  GROUP BY
    ce.icustay_id,
    ce.charttime
), cv /* types of invasive lines in carevue */ /*       value       | count */ /* ------------------+-------- */ /*  A-Line           | 460627 */ /*  Multi-lumen      | 345858 */ /*  PICC line        |  92285 */ /*  PA line          |  65702 */ /*  Dialysis Line    |  57579 */ /*  Introducer       |  36027 */ /*  CCO PA Line      |  24831 */ /*                   |  22369 */ /*  Trauma Line      |  15530 */ /*  Portacath        |  12927 */ /*  Ventriculostomy  |  10295 */ /*  Pre-Sep Catheter |   9678 */ /*  IABP             |   8819 */ /*  Other/Remarks    |   8725 */ /*  Midline          |   5067 */ /*  Venous Access    |   4278 */ /*  Hickman          |   3783 */ /*  PacerIntroducer  |   2663 */ /*  TripleIntroducer |   2262 */ /*  RIC              |   1625 */ /*  PermaCath        |   1066 */ /*  Camino Bolt      |    913 */ /*  Lumbar Drain     |    361 */ /* (23 rows) */ AS (
  SELECT DISTINCT
    icustay_id,
    charttime
  FROM cv_grp
  WHERE
    (
      inv1_type IN ('A-Line', 'IABP')
    )
    OR (
      inv2_type IN ('A-Line', 'IABP')
    )
    OR (
      inv3_type IN ('A-Line', 'IABP')
    )
    OR (
      inv4_type IN ('A-Line', 'IABP')
    )
    OR (
      inv5_type IN ('A-Line', 'IABP')
    )
    OR (
      inv6_type IN ('A-Line', 'IABP')
    )
    OR (
      inv7_type IN ('A-Line', 'IABP')
    )
    OR (
      inv8_type IN ('A-Line', 'IABP')
    )
), cv0 /* transform carevue data into durations */ AS (
  SELECT
    icustay_id, /* this carries over the previous charttime */
    LAG(CHARTTIME, 1) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS charttime_lag,
    charttime
  FROM cv
), cv1 AS (
  SELECT
    icustay_id,
    charttime,
    charttime_lag, /* if the current observation indicates a line is present */ /* calculate the time since the last charted line */
    CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', charttime) - DATE_TRUNC('hour', charttime_lag)) / 3600 AS BIGINT) AS arterial_line_duration, /* now we determine if the current line is "new" */ /* new == no documentation for 16 hours */
    CASE
      WHEN CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', charttime) - DATE_TRUNC('hour', charttime_lag)) / 3600 AS BIGINT) > 16
      THEN 1
      ELSE 0
    END AS arterial_line_new
  FROM cv0
), cv2 AS (
  SELECT
    cv1.*, /* create a cumulative sum of the instances of new events */ /* this results in a monotonic integer assigned to each new instance of a line */
    SUM(arterial_line_new) OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS arterial_line_rownum
  FROM cv1
), cv_dur /* create the durations for each line */ AS (
  SELECT
    icustay_id,
    arterial_line_rownum,
    MIN(charttime) AS starttime,
    MAX(charttime) AS endtime,
    CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', MAX(charttime)) - DATE_TRUNC('hour', MIN(charttime))) / 3600 AS BIGINT) AS duration_hours
  FROM cv2
  GROUP BY
    icustay_id,
    arterial_line_rownum
  HAVING
    MIN(charttime) <> MAX(charttime)
)
SELECT
  icustay_id, /* , arterial_line_rownum */
  starttime,
  endtime,
  duration_hours
FROM cv_dur
UNION ALL
/* TODO: collapse metavision durations if they overlap */
SELECT
  icustay_id, /* , ROW_NUMBER() over (PARTITION BY icustay_id ORDER BY starttime) as arterial_line_rownum */
  starttime,
  endtime,
  CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', endtime) - DATE_TRUNC('hour', starttime)) / 3600 AS BIGINT) AS duration_hours
FROM mv
WHERE
  arterial_line = 1
ORDER BY
  icustay_id NULLS FIRST,
  starttime NULLS FIRST