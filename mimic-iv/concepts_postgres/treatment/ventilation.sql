-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.ventilation; CREATE TABLE mimiciv_derived.ventilation AS
/* create the durations for each ventilation instance */
/* Classify oxygen devices and ventilator modes into six clinical categories. */ /* Categories include.. */ /*  Invasive oxygen delivery types: */ /*      Tracheostomy (with or without positive pressure ventilation) */ /*      InvasiveVent (positive pressure ventilation via endotracheal tube, */ /*          could be oro/nasotracheal or tracheostomy) */ /*  Non invasive oxygen delivery types (ref doi:10.1001/jama.2020.9524): */ /*      NonInvasiveVent (non-invasive positive pressure ventilation) */ /*      HFNC (high flow nasal oxygen / cannula) */ /*      SupplementalOxygen (all other non-rebreather, */ /*          facemask, face tent, nasal prongs...) */ /*  No oxygen device: */ /*      None */ /* When conflicting settings occur (rare), the priority is: */ /*  trach > mech vent > NIV > high flow > o2 */ /* Some useful cases for debugging: */ /*  stay_id = 30019660 has a tracheostomy placed in the ICU */ /*  stay_id = 30000117 has explicit documentation of extubation */ /* first we collect all times which have relevant documentation */
WITH tm AS (
  SELECT
    stay_id,
    charttime
  FROM mimiciv_derived.ventilator_setting
  UNION
  SELECT
    stay_id,
    charttime
  FROM mimiciv_derived.oxygen_delivery
), vs AS (
  SELECT
    tm.stay_id,
    tm.charttime, /* source data columns, here for debug */
    o2_delivery_device_1,
    COALESCE(ventilator_mode, ventilator_mode_hamilton) AS vent_mode, /* case statement determining the type of intervention */ /* done in order of priority: trach > mech vent > NIV > high flow > o2 */
    CASE
      WHEN o2_delivery_device_1 IN ('Tracheostomy tube' /* 1135 observations for T-Piece */ /* could be either InvasiveVent or Tracheostomy, so omit */ /* 'T-piece', */, 'Trach mask ' /* 16435 observations */)
      THEN 'Tracheostomy'
      WHEN o2_delivery_device_1 IN ('Endotracheal tube')
      OR ventilator_mode IN ('(S) CMV', 'APRV', 'APRV/Biphasic+ApnPress', 'APRV/Biphasic+ApnVol', 'APV (cmv)', 'Ambient', 'Apnea Ventilation', 'CMV', 'CMV/ASSIST', 'CMV/ASSIST/AutoFlow', 'CMV/AutoFlow', 'CPAP/PPS', 'CPAP/PSV', 'CPAP/PSV+Apn TCPL', 'CPAP/PSV+ApnPres', 'CPAP/PSV+ApnVol', 'MMV', 'MMV/AutoFlow', 'MMV/PSV', 'MMV/PSV/AutoFlow', 'P-CMV', 'PCV+', 'PCV+/PSV', 'PCV+Assist', 'PRES/AC', 'PRVC/AC', 'PRVC/SIMV', 'PSV/SBT', 'SIMV', 'SIMV/AutoFlow', 'SIMV/PRES', 'SIMV/PSV', 'SIMV/PSV/AutoFlow', 'SIMV/VOL', 'SYNCHRON MASTER', 'SYNCHRON SLAVE', 'VOL/AC')
      OR ventilator_mode_hamilton IN ('APRV', 'APV (cmv)', 'Ambient', '(S) CMV', 'P-CMV', 'SIMV', 'APV (simv)', 'P-SIMV', 'VS', 'ASV')
      THEN 'InvasiveVent'
      WHEN o2_delivery_device_1 IN ('Bipap mask ' /* 8997 observations */, 'CPAP mask ' /* 5568 observations */)
      OR ventilator_mode_hamilton IN ('DuoPaP', 'NIV', 'NIV-ST')
      THEN 'NonInvasiveVent'
      WHEN o2_delivery_device_1 IN ('High flow nasal cannula' /* 925 observations */)
      THEN 'HFNC'
      WHEN o2_delivery_device_1 IN ('Non-rebreather' /* 5182 observations */, 'Face tent' /* 24601 observations */, 'Aerosol-cool' /* 24560 observations */, 'Venti mask ' /* 1947 observations */, 'Medium conc mask ' /* 1888 observations */, 'Ultrasonic neb' /* 9 observations */, 'Vapomist' /* 3 observations */, 'Oxymizer' /* 1301 observations */, 'High flow neb' /* 10785 observations */, 'Nasal cannula')
      THEN 'SupplementalOxygen'
      WHEN o2_delivery_device_1 IN ('None')
      THEN 'None'
      ELSE NULL
    END AS ventilation_status
  FROM tm
  LEFT JOIN mimiciv_derived.ventilator_setting AS vs
    ON tm.stay_id = vs.stay_id AND tm.charttime = vs.charttime
  LEFT JOIN mimiciv_derived.oxygen_delivery AS od
    ON tm.stay_id = od.stay_id AND tm.charttime = od.charttime
), vd0 AS (
  SELECT
    stay_id,
    charttime, /* source data columns, here for debug */ /* , o2_delivery_device_1 */ /* , vent_mode */ /* carry over the previous charttime which had the same state */
    LAG(charttime, 1) OVER (PARTITION BY stay_id, ventilation_status ORDER BY charttime NULLS FIRST) AS charttime_lag, /* bring back the next charttime, regardless of the state */ /* this will be used as the end time for state transitions */
    LEAD(charttime, 1) OVER w AS charttime_lead,
    ventilation_status,
    LAG(ventilation_status, 1) OVER w AS ventilation_status_lag
  FROM vs
  WHERE
    NOT ventilation_status IS NULL
  WINDOW w AS (PARTITION BY stay_id ORDER BY charttime NULLS FIRST)
), vd1 AS (
  SELECT
    stay_id,
    charttime,
    charttime_lag,
    charttime_lead,
    ventilation_status, /* source data columns, here for debug */ /* , o2_delivery_device_1 */ /* , vent_mode */ /* calculate the time since the last event */
    CAST(EXTRACT(EPOCH FROM charttime - charttime_lag) / 60.0 AS DOUBLE PRECISION) / 60 AS ventduration, /* now we determine if the current ventilation status is "new", */ /* or continuing the previous event */
    CASE
      WHEN ventilation_status_lag IS NULL
      THEN 1
      WHEN EXTRACT(EPOCH FROM charttime - charttime_lag) / 3600.0 >= 14
      THEN 1
      WHEN ventilation_status_lag <> ventilation_status
      THEN 1
      ELSE 0
    END AS new_ventilation_event
  FROM vd0
), vd2 AS (
  SELECT
    vd1.stay_id,
    vd1.charttime,
    vd1.charttime_lead,
    vd1.ventilation_status,
    ventduration,
    new_ventilation_event, /* create a cumulative sum of the instances of new ventilation */ /* this results in a monotonically increasing integer assigned */ /* to each instance of ventilation */
    SUM(new_ventilation_event) OVER (PARTITION BY stay_id ORDER BY charttime NULLS FIRST) AS vent_seq
  FROM vd1
)
SELECT
  stay_id,
  MIN(charttime) AS starttime, /* for the end time of the ventilation event, the time of the *next* setting */ /* i.e. if we go NIV -> O2, the end time of NIV is the first row */ /* with a documented O2 device */ /* ... unless it's been over 14 hours, */ /* in which case it's the last row with a documented NIV. */
  MAX(
    CASE
      WHEN charttime_lead IS NULL
      OR EXTRACT(EPOCH FROM charttime_lead - charttime) / 3600.0 >= 14
      THEN charttime
      ELSE charttime_lead
    END
  ) AS endtime, /* all rows with the same vent_num will have the same ventilation_status */ /* for efficiency, we use an aggregate here, */ /* but we could equally well group by this column */
  MAX(ventilation_status) AS ventilation_status
FROM vd2
GROUP BY
  stay_id,
  vent_seq
HAVING
  MIN(charttime) <> MAX(charttime)