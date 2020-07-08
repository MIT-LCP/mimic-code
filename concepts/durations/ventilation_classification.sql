-- Identify The presence of a mechanical ventilation using settings
WITH t0 AS
(
  SELECT
    icustay_id, charttime, ce.itemid, d.label, value
    -- Invasive ventilation ? It means intubated and receiving ventilation by the ETT or by a tracheostomy tube
    , MAX(
      CASE
        -- 720 - Ventilator Mode CareVue
        WHEN ce.itemid = 720 AND value IN ('Assist Control', 'SIMV+PS', 'SIMV', 'CMV', 'Pressure Control', 'TCPCV') THEN 1
        -- 223848 - Ventilator Type MetaVision (HFO means high frequency oscillatory ventilation (HFOV) or high flow oxygen ?)
        -- After searching on google, it seems to be HFOV, so invasive ventilation
        WHEN ce.itemid = 223848 AND value = 'Sensor Medic (HFO)' THEN 1
        -- 223849 - Ventilator mode MetaVision
        WHEN ce.itemid = 223849 AND value IN ('SYNCHRON MASTER', 'SYNCHRON SLAVE', 'PSV/SBT', 'SIMV', 'CMV/ASSIST/AutoFlow', 'CMV', 'MMV',
        'APRV', 'CMV/ASSIST', 'SIMV/VOL', 'SIMV/PSV', 'PRVC/AC', 'MMV/PSV/AutoFlow', 'SIMV/AutoFlow', 'SIMV/PRES', 'MMV/PSV',
        'SIMV/PSV/AutoFlow', 'PRVC/SIMV', 'MMV/AutoFlow', 'VOL/AC', 'CMV/AutoFlow', 'PRES/AC', 'PCV+Assist') THEN 1
        -- respiratory support (used for neonates)
        WHEN ce.itemid = 3605 AND value IN ('None') THEN 0
        WHEN ce.itemid = 3605 AND value IN ('ConventionalVent', 'HighFreq Vent') THEN 1
        -- 467 - O2 delivery device CareVue
        WHEN ce.itemid = 467 AND value IN ('Ventilator', 'T-Piece', 'TranstrachealCat') THEN 1
        -- 468 - 02 delivery device #2 Carevue
        WHEN ce.itemid = 468 AND value IN ('T-Piece', 'TranstrachealCat') THEN 1
        -- 226732 - O2 delivery device(s) Metavision
        WHEN ce.itemid = 226732 AND value IN ('T-piece', 'Endotracheal tube', 'Tracheostomy tube') THEN 1
        -- 640 - Significant Events
        WHEN ce.itemid = 640 AND value = 'Intubated' THEN 1
        -- TCPCV settings
        WHEN ce.itemid IN (223,667,668,669,670,671,672) THEN 1
        -- ETT mark (cm) & position change
        WHEN ce.itemid IN (
          157, 158, 3398, 3399, 3400, 3401, 3402, 3403, 3404
          , 1852, 8382, 225585, 224391, 224392, 224415, 227809
          , 227810, 224832, 223840, 223837, 223838
          ) THEN 1
        -- 40 - Airway type
        WHEN ce.itemid = 40 AND value IN ('Endotracheal', 'Nasotracheal', 'Double Lumen ETT', 'Nasal Trumpet') THEN 1
        
        ELSE 0
      END
      ) AS mechvent
    
    
    
    -- Non invasive ventilation ? It means BiPAP of CPAP administered via a mask
      , MAX (
      CASE
        -- Item 720 is only Invasive or BothPossible
        WHEN ce.itemid = 223848 AND value IN ('BiPAP/CPAP', 'Respironics BiPAP') THEN 1
        -- Item 223849 is only Invasive or BothPossible
        WHEN ce.itemid IN (467, 468) AND value IN ('Bipap Mask', 'CPAP Mask') THEN 1
        WHEN ce.itemid = 226732 AND value IN ('Bipap mask ', 'CPAP mask ') THEN 1
        WHEN ce.itemid = 3605 AND value IN ('None') THEN 0
        -- Bipap
        WHEN ce.itemid IN (63, 64, 65, 66, 67, 68, 1040, 6060, 5850, 227577, 227578, 227579, 227580, 227581, 227582) THEN 1
        -- CPAP
        WHEN ce.itemid IN (1457, 3111, 6875) THEN 1
        -- Autoset/CPAP
        WHEN ce.itemid = 227583 AND ce.value NOT IN ('Off') THEN 1
        -- CPAP mask or CPAP
        WHEN ce.itemid IN (2866, 1914) AND ce.value NOT IN ('off', 'OFF', '0FF') THEN 1
        ELSE 0
      END
    ) AS niv
    
    
    
    -- These parameters could class in Invasive or Non invasive ventilation (BothPossible / choiceventilation)
    -- When a parameter is BothPossible, value is set to 0. Else, it is set to NULL.
    ,CASE
      WHEN ce.itemid = 720 AND value IN ('Pressure Support', 'CPAP', 'CPAP+PS') THEN 1
      -- respiratory support (used for neonates)
      WHEN ce.itemid = 3605 AND value IN ('None') THEN 0
      WHEN ce.itemid = 3605 AND value IN ('CPAP') THEN 1
      WHEN ce.itemid IN (223848, 722) AND value IN ('Drager', 'Avea', 'PB 7200', 'Other', '7200A', 'Servo 900c') THEN 1
      WHEN ce.itemid = 223849 AND value IN ('CPAP/PSV+ApnVol', 'PCV+', 'APRV/Biphasic+ApnVol', 'PCV+/PSV', 'APRV/Biphasic+ApnPress',
        'CPAP/PSV+Apn TCPL', 'CPAP/PSV+ApnPres', 'CPAP/PSV', 'CPAP', 'Apnea Ventilation', 'CPAP/PPS') THEN 1
      -- Item 467 is only Invasive, NonInvasive or Oxygenation
      -- Item 468 is only Invasive, NonInvasive or Oxygenation
      -- Item 226732 is only Invasive, NonInvasive or Oxygenation
      WHEN ce.itemid IN (
        445, 448, 449, 450, 224687 -- Minute volume
        , 224684, 683 -- Tidal volume (Set)
        , 224685, 682 -- Tidal volume (Observed)
        , 224686, 684, 654, 3050, 3083 -- Tidal volume (Spontaneous)
        , 639, 681 -- Tidal volume (misc)
        ,218,436,535,543,444,459,224697,224695,224696,224746,224747,227187 -- High/Low/Peak Insp. Pressure / Mean airway pressure / Neg Insp Force / Plateau pressure / Transpulmonary pressure
        ,221,1,1211,1655,2000,226873,224738,224419 -- Insp & Exp times / ratios
        ,5865,5866,224707,224709,224705,224706 -- APRV pressures
        ,60,437,505,506,686,220339,224700 -- PEEP & auto-PEEP
        ,3459 -- High pressure relief
        ,501,502,503,224702 -- PCV Vt / pressure / level
        ,224701 -- PSV level
      ) THEN 1
      
      ELSE 0
    END AS choiceventilation
    
    
    -- Oxygenation therapy ?
    , MAX(
      CASE
        WHEN ce.itemid = 226732 AND value IN (
          'Nasal cannula', 'Face tent', 'High flow neb',
          'Non-rebreather', 'Venti mask ',  'Medium conc mask ',
          'High flow nasal cannula', 'Ultrasonic neb',
          'Vapomist', 'Trach mask '
          ) THEN 1 
        WHEN ce.itemid = 467 AND value IN (
          'Cannula', 'Nasal Cannula', 'Face Tent', 'Trach Mask',
          'Hi Flow Neb', 'Non-Rebreather', 'Venti Mask',
          'Medium Conc Mask', 'Vapotherm', 'Hood', 'Hut',
          'Heated Neb', 'Ultrasonic Neb'
          ) THEN 1
        WHEN ce.itemid = 468 AND value IN (
          'Venti Mask', 'Nasal Cannula', 'Non-Rebreather', 'Face Tent',
          'Heated Neb', 'Trach Mask', 'Medium Conc Mask',
          'Hi Flow Neb'
          ) THEN 1
        WHEN ce.itemid = 469 AND value IN (
          'Nasal Cannula', 'Face Tent', 'Trach Mask'
          ) THEN 1	
        -- respiratory support (used for neonates)
        WHEN ce.itemid = 3605 AND value IN ('None') THEN 0
        WHEN ce.itemid = 3605 AND value IN ('Nasal Cannula', 'Oxygen Hood') THEN 1
        -- 227287 - O2 flow (additional cannula) Metavision
        WHEN ce.itemid = 227287 THEN 1
        -- 223834 - O2 flow Metavision		
        WHEN ce.itemid = 223834 THEN 1
        -- 470 - O2 flow Carevue
        WHEN ce.itemid = 470 THEN 1
        -- 471 - O2 flow (lpm) #2 Carevue
        WHEN ce.itemid = 471 THEN 1
        ELSE 0
      END
      ) AS OxygenTherapy
    
    
    -- Tracheostomy ? Could be with invasive ventilation, non-invasive ventilation and Oxygenation
    , MAX(
      CASE
      WHEN ce.itemid = 226732 AND (value = 'Tracheostomy tube' OR value = 'Trach mask ') THEN 1
      WHEN ce.itemid = 467 AND value = 'Trach Mask' THEN 1
      WHEN ce.itemid = 468 AND value = 'Trach Mask' THEN 1
      WHEN ce.itemid = 469 AND value = 'Trach Mask' THEN 1
      WHEN ce.itemid = 40 AND value = 'Tracheostomy' THEN 1
      WHEN ce.itemid IN (691, 224829, 224830, 224831, 227130, 687, 647, 940, 4603, 970, 1022, 8138) THEN 1
      ELSE 0
      END
    )
    AS Tracheostomy
    
    
    -- Extubation ?
    , MAX(
      CASE
        WHEN ce.itemid = 640 AND value IN ('Extubated', 'Self Extubation') THEN 1
        -- Use 43851 ETT out ? Not used for the moment.
        ELSE 0
      END
        )
      AS Extubated
      
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  LEFT JOIN `physionet-data.mimiciii_clinical.d_items` d
    ON d.itemid = ce.itemid
  WHERE ce.value IS NOT NULL
  AND ce.icustay_id IS NOT NULL
  AND COALESCE(ce.error, 0) = 0
  AND ce.itemid IN
  (
      720, 223849 -- ventilator mode (PCV, etc)
      , 722, 223848 -- ventilator type (Drager, etc)
      ,640
      ,467
      ,468
      ,469
      ,470
      ,471
      ,227287
      ,226732
      ,223834
      , 3605 -- respiratory support
      ,445, 448, 449, 450, 224687
      ,639, 654, 681, 682, 683, 684,224685,224684,224686
      , 3050, 3083
      ,218,436,535,444,224697,224695,224696,224746,224747
      ,221,1,1211,1655,2000,226873,224738,224419,227187
      ,543
      ,5865,5866,224707,224709,224705,224706
      ,60,437,505,506,686,220339,224700
      ,3459
      ,501,502,503,224702
      ,223,667,668,669,670,671,672
      ,224701
      ,157, 158, 3398, 3399, 3400, 3401, 3402, 3403, 3404, 1852, 8382, 225585, 224391, 224392, 224415, 227809, 227810, 224832, 223840, 225277
      ,223837, 223838
      ,225494
      ,63, 64, 65, 66, 67, 68, 1040, 6060, 5850, 227577, 227578, 227579, 227580, 227581, 227582
      ,1457, 3111, 1914, 2866, 6875, 227583
      , 40
      ,691, 224829, 224830, 224831, 227130, 687, 647, 940, 4603, 970, 1022, 8138
      -- 721 Ventilator number, not useful
      -- We do not include alarm settings as they do not imply active ventilation
      -- , 650 -- (Spon Minute VE L/min)
      -- , 1032 -- (Hi/minute/vol/alarm)
      -- , 1038 -- (Hi/minute/vols alarm)
      -- , 1055 -- (Hi/Minute/vol/alarm)
      -- , 1104 -- (HI/Minute/vol/alarm)
      -- , 1121 -- ( HI/Minute/Vol/Alarm)
      -- , 1340, 1486, 1600 -- high minute volume
      -- Compliance is automatically calculated as Tidal Volume / (Peak Inspiratory Pressure - PEEP)
      -- https://github.com/MIT-LCP/mimic-code/issues/437
      -- As the measures are redundant, we ignore them.
      -- , 131, 132

      -- below itemids are in d_items but do not have any documented data
      --, 226429, 228067, 228068, 228069, 228070, 228071
      --, 225586, 225587, 225588, 225590, 225593
      -- , 225307 -- Oral ETT
      -- , 225308 -- Nasal ETT
      -- , 225277 -- ETT position
      -- , 225278 -- ETT route
      -- , 225494  -- NIV mask
  )
  AND value NOT IN
  (
    
    -- Other / none etc
    'Other/Remarks', 'Other', 'None'
    -- Deleted cause aerolisation sometimes during mechanical ventilation
    , 'Aerosol-cool', 'Aerosol-Cool'
    -- Deleted cause not under ventilation if ventilator is in stanby mode
    , 'Standby'
  )
  GROUP BY icustay_id, charttime, d.label, value, ce.itemid

  UNION DISTINCT

  SELECT
    icustay_id, starttime as charttime, pmv.itemid, d.label, CAST(value AS STRING) AS value
    , 0 AS mechvent
    , 0 AS niv
    , 0 AS choiceventilation
    , 0 AS Tracheostomy
    , 0 AS OxygenTherapy
    , 1 AS Extubated
  FROM `physionet-data.mimiciii_clinical.procedureevents_mv` pmv
  LEFT JOIN `physionet-data.mimiciii_clinical.d_items` d
    ON d.itemid = pmv.itemid
  WHERE pmv.icustay_id IS NOT NULL
  AND pmv.itemid IN
  (
      227194 -- "Extubation"
    , 225468 -- "Unplanned Extubation (patient initiated)"
    , 225477 -- "Unplanned Extubation (non patient initiated)"
  )
)
SELECT 
    icustay_id
    , charttime
    , itemid
    , label
    , value
    , mechvent
    , niv
    , choiceventilation
    , Tracheostomy
    , OxygenTherapy
    , Extubated
FROM t0
-- filter rows where we have no information about vent status
-- e.g. a row regarding fluid bolus from the Significant Events itemid (640)
WHERE mechvent > 0
OR niv > 0
OR choiceventilation > 0
OR tracheostomy > 0
OR oxygentherapy > 0
OR extubated > 0;