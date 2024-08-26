-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.ventilation; CREATE TABLE mimiciv_derived.ventilation AS
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
    tm.charttime,
    o2_delivery_device_1,
    COALESCE(ventilator_mode, ventilator_mode_hamilton) AS vent_mode,
    CASE
      WHEN o2_delivery_device_1 IN ('Tracheostomy tube', 'Trach mask ')
      THEN 'Tracheostomy'
      WHEN o2_delivery_device_1 IN ('Endotracheal tube')
      OR ventilator_mode IN ('(S) CMV', 'APRV', 'APRV/Biphasic+ApnPress', 'APRV/Biphasic+ApnVol', 'APV (cmv)', 'Ambient', 'Apnea Ventilation', 'CMV', 'CMV/ASSIST', 'CMV/ASSIST/AutoFlow', 'CMV/AutoFlow', 'CPAP/PPS', 'CPAP/PSV', 'CPAP/PSV+Apn TCPL', 'CPAP/PSV+ApnPres', 'CPAP/PSV+ApnVol', 'MMV', 'MMV/AutoFlow', 'MMV/PSV', 'MMV/PSV/AutoFlow', 'P-CMV', 'PCV+', 'PCV+/PSV', 'PCV+Assist', 'PRES/AC', 'PRVC/AC', 'PRVC/SIMV', 'PSV/SBT', 'SIMV', 'SIMV/AutoFlow', 'SIMV/PRES', 'SIMV/PSV', 'SIMV/PSV/AutoFlow', 'SIMV/VOL', 'SYNCHRON MASTER', 'SYNCHRON SLAVE', 'VOL/AC')
      OR ventilator_mode_hamilton IN ('APRV', 'APV (cmv)', 'Ambient', '(S) CMV', 'P-CMV', 'SIMV', 'APV (simv)', 'P-SIMV', 'VS', 'ASV')
      THEN 'InvasiveVent'
      WHEN o2_delivery_device_1 IN ('Bipap mask ', 'CPAP mask ')
      OR ventilator_mode_hamilton IN ('DuoPaP', 'NIV', 'NIV-ST')
      THEN 'NonInvasiveVent'
      WHEN o2_delivery_device_1 IN ('High flow nasal cannula')
      THEN 'HFNC'
      WHEN o2_delivery_device_1 IN ('Non-rebreather', 'Face tent', 'Aerosol-cool', 'Venti mask ', 'Medium conc mask ', 'Ultrasonic neb', 'Vapomist', 'Oxymizer', 'High flow neb', 'Nasal cannula')
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
    charttime,
    LAG(charttime, 1) OVER (PARTITION BY stay_id, ventilation_status ORDER BY charttime NULLS FIRST) AS charttime_lag,
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
    ventilation_status,
    DATE_DIFF('microseconds', charttime_lag, charttime)/60000000.0 / 60 AS ventduration,
    CASE
      WHEN ventilation_status_lag IS NULL
      THEN 1
      WHEN DATE_DIFF('microseconds', charttime_lag, charttime)/3600000000.0 >= 14
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
    new_ventilation_event,
    SUM(new_ventilation_event) OVER (PARTITION BY stay_id ORDER BY charttime NULLS FIRST) AS vent_seq
  FROM vd1
)
SELECT
  stay_id,
  MIN(charttime) AS starttime,
  MAX(
    CASE
      WHEN charttime_lead IS NULL
      OR DATE_DIFF('microseconds', charttime, charttime_lead)/3600000000.0 >= 14
      THEN charttime
      ELSE charttime_lead
    END
  ) AS endtime,
  MAX(ventilation_status) AS ventilation_status
FROM vd2
GROUP BY
  stay_id,
  vent_seq
HAVING
  MIN(charttime) <> MAX(charttime)