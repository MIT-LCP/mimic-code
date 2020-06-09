-- This query extracts the duration of mechanical ventilation
-- The main goal of the query is to aggregate sequential ventilator settings
-- into single mechanical ventilation "events". The start and end time of these
-- events can then be used for various purposes: calculating the total duration
-- of mechanical ventilation, cross-checking values (e.g. PaO2:FiO2 on vent), etc

-- The query's logic is roughly:
--    1) The presence of a mechanical ventilation setting starts a new ventilation event
--    2) Any instance of a setting in the next 8 hours continues the event
--    3) Certain elements end the current ventilation event
--        a) documented extubation ends the current ventilation
--        b) initiation of non-invasive vent and/or oxygen ends the current vent
-- The ventilation events are numbered consecutively by the `num` column.

-- Update 2020/06/09 (Boris Delange)
-- 1) Making a difference between invasive and non-invasive ventilation
-- (three categories of data for the ventilation events : invasive ventilation - non invasive ventilation - both are possible)
-- When we're not sure about a ventilation event between IV or NIV, we're counting the 12 next and 12 previous ventilation events
-- We're then modifying the event with the majority (IV or NIV)
-- 2) Deleting isolated events, like isolated Oxygenation events wich made false new ventilation events

-- First, create a temporary table to store relevant data from CHARTEVENTS.
DROP MATERIALIZED VIEW IF EXISTS ventsettings CASCADE;
CREATE MATERIALIZED VIEW ventsettings AS
WITH t0 AS
(
SELECT
	icustay_id, charttime, ce.itemid, d.label, CAST(value AS VARCHAR)
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
		  -- 467 - O2 delivery device CareVue
		  WHEN ce.itemid = 467 AND value IN ('Ventilator', 'T-Piece', 'TranstrachealCat') THEN 1
		  -- 468 - 02 delivery device #2 Carevue
		  WHEN ce.itemid = 468 AND value IN ('T-Piece', 'TranstrachealCat') THEN 1
		  -- 226732 - O2 delivery device(s) Metavision
		  WHEN ce.itemid = 226732 AND value IN ('T-piece', 'Endotracheal tube', 'Tracheostomy tube') THEN 1
		  -- 640 - Significant Events
		  WHEN ce.itemid = 640 AND value = 'Intubated' THEN 1
		  -- TCPCV settings
		  WHEN ce.itemid IN(223,667,668,669,670,671,672) THEN 1
		  -- ETT mark (cm) & position change
		  WHEN ce.itemid IN (157, 158, 3398, 3399, 3400, 3401, 3402, 3403, 3404, 1852, 8382, 225585, 224391, 224392, 224415, 227809, 227810, 224832, 223840, 225277
		  ,226429, 228067, 228068, 228069, 228070, 228071, 223837, 223838, 225278, 225307, 225308) THEN 1
		  -- Other intubation informations
		  WHEN ce.itemid  IN (225586, 225587, 225588, 225590, 225593) THEN 1
		  -- Compliance
		  WHEN ce.itemid IN (131, 132) THEN 1
		  -- 40 - Airway type
		  WHEN ce.itemid = 40 AND value IN ('Endotracheal', 'Nasotracheal', 'Double Lumen ETT', 'Nasal Trumpet') THEN 1
		  
		  ELSE 0
		END
    ) AS InvasiveVentilation
	
	
	
	-- Non invasive ventilation ? It means BiPAP of CPAP administered with a mask
    , MAX (
		CASE
			-- Item 720 is only Invasive or BothPossible
			WHEN ce.itemid = 223848 AND value IN ('BiPAP/CPAP', 'Respironics BiPAP') THEN 1
			-- Item 223849 is only Invasive or BothPossible
			WHEN ce.itemid IN (467, 468) AND value IN ('Bipap Mask', 'CPAP Mask') THEN 1
			WHEN ce.itemid = 226732 AND value IN ('Bipap mask ', 'CPAP mask ') THEN 1
			-- NIV Mask
			WHEN ce.itemid = 225494 THEN 1
			-- Bipap
			WHEN ce.itemid IN (63, 64, 65, 66, 67, 68, 1040, 6060, 5850, 227577, 227578, 227579, 227580, 227581, 227582, 227583) THEN 1
			-- CPAP
			WHEN ce.itemid IN (1457, 3111, 1914, 2866, 6875, 227583) THEN 1
			
			ELSE 0
		END
	) AS NonInvasiveVentilation
	
	
	
	-- These parameters could class in Invasive or Non invasive ventilation (BothPossible / ChoiceVentilation)
	-- When a parameter is BothPossible, value is set to 0. Else, it is set to NULL.
	,CASE
		WHEN ce.itemid = 720 AND value IN ('Pressure Support', 'CPAP', 'CPAP+PS') THEN 0
		WHEN ce.itemid = 223848 AND value IN ('Drager', 'Avea', 'PB 7200', 'Other') THEN 0
		WHEN ce.itemid = 223849 AND value IN ('CPAP/PSV+ApnVol', 'PCV+', 'APRV/Biphasic+ApnVol', 'PCV+/PSV', 'APRV/Biphasic+ApnPress',
			'CPAP/PSV+Apn TCPL', 'CPAP/PSV+ApnPres', 'CPAP/PSV', 'CPAP', 'Apnea Ventilation', 'CPAP/PPS') THEN 0
		-- Item 467 is only Invasive, NonInvasive or Oxygenation
		-- Item 468 is only Invasive, NonInvasive or Oxygenation
		-- Item 226732 is only Invasive, NonInvasive or Oxygenation
		WHEN ce.itemid IN(
			445, 448, 449, 450, 1340, 1486, 1600, 224687 -- Minute volume
			,639, 654, 681, 682, 683, 684,224685,224684,224686 -- Tidal volume
			,218,436,535,543,444,459,224697,224695,224696,224746,224747,227187 -- High/Low/Peak Insp. Pressure / Mean airway pressure / Neg Insp Force / Plateau pressure / Transpulmonary pressure
			,221,1,1211,1655,2000,226873,224738,224419 -- Insp & Exp times / ratios
			,5865,5866,224707,224709,224705,224706 -- APRV pressures
			,60,437,505,506,686,220339,224700 -- PEEP & auto-PEEP
			,3459 -- High pressure relief
			,501,502,503,224702 -- PCV Vt / pressure / level
			,224701 -- PSV level
		) THEN 0
		
		-- 721 & 722 Ventilator no & type, not useful
		
		ELSE NULL
	END AS ChoiceVentilation
	
	
	-- Oxygenation therapy ?
	, MAX(
		CASE
			WHEN ce.itemid = 226732 AND value IN ('Nasal cannula', 'Face tent', 'High flow neb', 'Non-rebreather', 'Venti mask ',  'Medium conc mask ',
				'High flow nasal cannula', 'Ultrasonic neb', 'Vapomist', 'Trach mask ') THEN 1 
			WHEN ce.itemid = 467 AND value IN ('Cannula', 'Nasal Cannula', 'Face Tent', 'Trach Mask', 'Hi Flow Neb', 'Non-Rebreather', 'Venti Mask',
				'Medium Conc Mask', 'Vapotherm', 'Hood', 'Hut', 'Heated Neb', 'Ultrasonic Neb') THEN 1
			WHEN ce.itemid = 468 AND value IN ('Venti Mask', 'Nasal Cannula', 'Non-Rebreather', 'Face Tent', 'Heated Neb', 'Trach Mask', 'Medium Conc Mask',
				'Hi Flow Neb') THEN 1
			WHEN ce.itemid = 469 AND value IN ('Nasal Cannula', 'Face Tent', 'Trach Mask') THEN 1	
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
    ) AS Oxygenation
	
	
	-- Tracheostomy ? Could be with invasive ventilation, non-invasive ventilation and Oxygenation
	, MAX(
		CASE
		WHEN ce.itemid = 226732 AND (value = 'Tracheostomy tube' OR value = 'Trach mask ') THEN 1
		WHEN ce.itemid = 467 AND value = 'Trach Mask' THEN 1
		WHEN ce.itemid = 468 AND value = 'Trach Mask' THEN 1
		WHEN ce.itemid = 469 AND value = 'Trach Mask' THEN 1
		WHEN ce.itemid = 40 AND value = 'Tracheostomy' THEN 1
		ELSE 0
		END
	)
	AS Tracheostomy
	
	
	-- Extubation ?
    , MAX(
		CASE
			WHEN ce.itemid = 640 AND value IN ('Extubated', 'Self Extubation') THEN 1
			WHEN ce.itemid IN (691, 224829, 224830, 224831, 227130, 687, 647, 940, 4603, 970, 1022, 8138) THEN 1
			-- Use 43851 ETT out ? Not used for the moment.
			ELSE 0
		END
      )
    AS Extubation
	  
	  
	-- Self-Extubation ? 
    , MAX(
		CASE
			WHEN ce.itemid = 640 and value = 'Self Extubation' then 1
		ELSE 0
      END
      )
    AS SelfExtubation
	  
FROM chartevents ce
LEFT JOIN d_items d ON d.itemid = ce.itemid
WHERE ce.value IS NOT NULL
AND ce.icustay_id IS NOT NULL
AND ce.error IS DISTINCT FROM 1
AND ce.itemid IN
(
    720, 223848
    ,223849
	,640
	,467
    ,468
    ,469
    ,470
    ,471
    ,227287
    ,226732
    ,223834
    ,445, 448, 449, 450, 1340, 1486, 1600, 224687
    ,639, 654, 681, 682, 683, 684,224685,224684,224686
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
	,226429, 228067, 228068, 228069, 228070, 228071, 223837, 223838, 225278, 225307, 225308
	,225586, 225587, 225588, 225590, 225593
	,225494
	,63, 64, 65, 66, 67, 68, 1040, 6060, 5850, 227577, 227578, 227579, 227580, 227581, 227582, 227583
	,1457, 3111, 1914, 2866, 6875, 227583
	,131, 132, 40
	,691, 224829, 224830, 224831, 227130, 687, 647, 940, 4603, 970, 1022, 8138
)
AND value NOT IN
(
	
	-- Other / none etc
	'Other/Remarks'
	,'Other'
	,'None'
	
	,'Aerosol-cool', 'Aerosol-Cool' -- Deleted cause aerolisation sometimes during mechanical ventilation
	,'Standby' -- Deleted cause not under ventilation if ventilator is in stanby mode
)
GROUP BY icustay_id, charttime, d.label, value, ce.itemid

UNION

SELECT
  icustay_id, starttime as charttime, pmv.itemid, d.label, CAST(value AS VARCHAR)
  , 0 AS InvasiveVentilation
  , 0 AS NonInvasiveVentilation
  , NULL AS ChoiceVentilation
  , 0 AS Tracheostomy
  , 0 AS Oxygenation
  , 1 AS Extubation
  , CASE WHEN pmv.itemid = 225468 THEN 1 ELSE 0 END AS SelfExtubation
FROM procedureevents_mv pmv
LEFT JOIN d_items d ON d.itemid = pmv.itemid
WHERE pmv.icustay_id IS NOT NULL
AND pmv.itemid IN(
	  227194 -- "Extubation"
	, 225468 -- "Unplanned Extubation (patient initiated)"
	, 225477 -- "Unplanned Extubation (non patient initiated)"
	)
	
	
)
SELECT ROW_NUMBER() OVER() AS rownb, icustay_id, charttime, itemid, label, value, Oxygenation, NonInvasiveVentilation, InvasiveVentilation, Tracheostomy, Extubation, SelfExtubation, ChoiceVentilation
, 0 AS NonReliability
FROM t0

ORDER BY icustay_id, charttime;

-- Result = SELECT 13122725



-- When there's not any NonInvasiveVentilation flag to 1 for an icustay_id, set all ChoiceVentilation to InvasiveVentilation
UPDATE wmvventsettings
SET InvasiveVentilation = (
CASE
	WHEN InvasiveVentilation = 1 THEN 1
	WHEN ChoiceVentilation = 0 THEN 1
	ELSE 0
END)
,ChoiceVentilation = NULL
WHERE icustay_id NOT IN (SELECT DISTINCT(icustay_id) FROM wmvventsettings WHERE NonInvasiveVentilation = 1 AND icustay_id IS NOT NULL);

-- Result = UPDATE 11945861. A big part of the job is already done with this !


-- A function to change the "ChangeVentilation" to InvasiveVentilation or NonInvasiveVentilation
-- Explanation :
-- If we are not sure about the ventilation (invasive or noninvasive), we check the previous and next InvasiveVentilation and NonInvasiveVentilation flags
-- If there's a majority of InvasiveVentilation, we change the "ChangeVentilation" flag to InvasiveVentilation, the same with the NonInvasiveVentilation

-- This function may be improved to be faster

CREATE OR REPLACE FUNCTION ChangeVentilation() RETURNS VOID
AS $$
DECLARE i int := 0;
BEGIN
WHILE i < 10 LOOP
		i := i + 1 ; 
	
	WITH m0 AS (
	SELECT rownb, InvasiveVentilation, NonInvasiveVentilation,
	CASE
		WHEN ChoiceVentilation = 0 THEN
			CASE
				-- A majority of InvasiveVentilation, change to InvasiveVentilation
				WHEN LAG(InvasiveVentilation, 1, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(InvasiveVentilation, 4, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(InvasiveVentilation, 7, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(InvasiveVentilation, 10, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) >
					 + LAG(NonInvasiveVentilation, 1, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(NonInvasiveVentilation, 4, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(NonInvasiveVentilation, 7, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(NonInvasiveVentilation, 10, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) THEN 1
				
				-- A majority of NonInvasiveVentilation, change to NonInvasiveVentilation
				WHEN LAG(InvasiveVentilation, 1, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(InvasiveVentilation, 4, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(InvasiveVentilation, 7, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(InvasiveVentilation, 10, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(InvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) <
					 + LAG(NonInvasiveVentilation, 1, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(NonInvasiveVentilation, 4, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(NonInvasiveVentilation, 7, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					 + LAG(NonInvasiveVentilation, 10, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(NonInvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) THEN 2

				ELSE CASE
					-- A majority of InvasiveVentilation, change to InvasiveVentilation
					WHEN LEAD(InvasiveVentilation, 1, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(InvasiveVentilation, 4, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(InvasiveVentilation, 7, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(InvasiveVentilation, 10, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) >
					LEAD(NonInvasiveVentilation, 1, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(NonInvasiveVentilation, 4, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(NonInvasiveVentilation, 7, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(NonInvasiveVentilation, 10, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) THEN 1
					
					-- A majority of NonInvasiveVentilation, change to NonInvasiveVentilation
					WHEN LEAD(InvasiveVentilation, 1, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(InvasiveVentilation, 4, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(InvasiveVentilation, 7, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(InvasiveVentilation, 10, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(InvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) <
					LEAD(NonInvasiveVentilation, 1, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 2, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 3, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(NonInvasiveVentilation, 4, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 5, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 6, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(NonInvasiveVentilation, 7, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 8, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 9, 0) OVER (PARTITION BY icustay_id ORDER BY charttime)
					+ LEAD(NonInvasiveVentilation, 10, 0)OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 11, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(NonInvasiveVentilation, 12, 0) OVER (PARTITION BY icustay_id ORDER BY charttime) THEN 2
					
					ELSE 0
				END
			END
		ELSE NULL
	END AS ChoiceVentilation
	FROM wmvventsettings
	WHERE icustay_id IN (SELECT DISTINCT(icustay_id) FROM wmvventsettings WHERE ChoiceVentilation IS NOT NULL)
	ORDER BY icustay_id, charttime
	)
	
	UPDATE wmvventsettings
	SET ChoiceVentilation =
	(CASE
		WHEN m0.ChoiceVentilation = 0 THEN 0
		WHEN m0.ChoiceVentilation = 1 THEN NULL
		WHEN m0.ChoiceVentilation = 2 THEN NULL
		ELSE NULL END)
	,NonInvasiveVentilation = 
	(CASE
		WHEN m0.NonInvasiveVentilation = 1 THEN 1
		WHEN m0.ChoiceVentilation = 2 THEN 1
		ELSE 0 END)
	,InvasiveVentilation =
	(CASE 
		WHEN m0.InvasiveVentilation = 1 THEN 1
		WHEN m0.ChoiceVentilation = 1 THEN 1
		ELSE 0 END)
	FROM m0
	WHERE wmvventsettings.rownb = m0.rownb;

END LOOP ; 
END;
$$
LANGUAGE plpgsql;


SELECT ChangeVentilation();
-- 10 loops
-- If we set more than 10 loops, the results are false / not reliable


-- An oxygen flag alone is often an error
-- So, we set a NonReliability flag to 1 if this is the case (sum of 2 lags and 2 leads inferior to 4)
-- After 10 loops, if there's some ChangeVentilation flags left, we change these flags to NonReliability
-- DELETE these lines from the table

WITH x0 AS(
SELECT rownb
,CASE
	WHEN Oxygenation = 1 THEN
		CASE WHEN LAG(Oxygenation, 1) OVER (PARTITION BY icustay_id ORDER BY charttime) + LAG(Oxygenation, 2) OVER (PARTITION BY icustay_id ORDER BY charttime)
		+ LEAD(Oxygenation, 1) OVER (PARTITION BY icustay_id ORDER BY charttime) + LEAD(Oxygenation, 2) OVER (PARTITION BY icustay_id ORDER BY charttime) < 4 THEN 1 ELSE 0 END
	WHEN ChoiceVentilation = 1 THEN 1
	WHEN 1 NOT IN (Oxygenation, NonInvasiveVentilation, InvasiveVentilation, Tracheostomy, Extubation, SelfExtubation) THEN 1
	ELSE 0
END AS NonReliability
FROM wmvventsettings
ORDER BY icustay_id, charttime
)

UPDATE wmvventsettings
SET NonReliability = x0.NonReliability
FROM x0
WHERE wmvventsettings.rownb = x0.rownb;

DELETE FROM wmvventsettings WHERE NonReliability = 1;


DROP TABLE IF EXISTS ventdurations CASCADE;
CREATE TABLE ventdurations AS
WITH vd0 AS
(
SELECT
	icustay_id
    ,CASE
        WHEN InvasiveVentilation = 1 THEN
			LAG(charttime, 1) OVER (PARTITION BY icustay_id ORDER BY charttime)
        ELSE NULL
    END AS charttime_lag_iv
	,CASE
        WHEN NonInvasiveVentilation = 1 THEN
			LAG(charttime, 1) OVER (PARTITION BY icustay_id ORDER BY charttime)
        ELSE NULL
    END AS charttime_lag_niv
    ,charttime
    ,InvasiveVentilation
	,NonInvasiveVentilation
    ,Oxygenation
    ,Extubation
    ,SelfExtubation
FROM ventsettings


)
, vd1 AS
(
SELECT
	icustay_id
	,charttime_lag_iv
	,charttime_lag_niv
	,charttime
	,InvasiveVentilation
	,NonInvasiveVentilation
	,Oxygenation
	,Extubation
	,SelfExtubation
    ,CASE
        WHEN InvasiveVentilation = 1 THEN charttime - charttime_lag_iv
        ELSE NULL
        END AS InvasiveVentDuration
	,CASE
        WHEN NonInvasiveVentilation = 1 THEN charttime - charttime_lag_niv
        ELSE NULL
        END AS NonInvasiveVentDuration
    ,LAG(Extubation, 1) OVER(PARTITION BY icustay_id ORDER BY charttime) as ExtubationLag
	,CASE
		WHEN LAG(Extubation, 1) OVER(PARTITION BY icustay_id ORDER BY charttime) = 1 THEN 1
		WHEN InvasiveVentilation = 0 AND Oxygenation = 1 THEN 1
		WHEN InvasiveVentilation = 0 AND NonInvasiveVentilation = 1 THEN 1
		WHEN (charttime - charttime_lag_iv) > INTERVAL '12' HOUR THEN 1
		ELSE 0
	END AS NewInvasiveVent
	,CASE
		WHEN NonInvasiveVentilation = 0 AND InvasiveVentilation = 1 THEN 1
		WHEN (charttime - charttime_lag_niv) > INTERVAL '24' HOUR THEN 1
		ELSE 0
	END AS NewNonInvasiveVent
FROM vd0
)
,vd2 AS
(
SELECT *
,CASE
	WHEN InvasiveVentilation = 1 OR Extubation = 1 THEN SUM(NewInvasiveVent) OVER (PARTITION BY icustay_id ORDER BY charttime)
	ELSE NULL
END AS NumInvasiveVent
,CASE
	WHEN NonInvasiveVentilation = 1 THEN SUM(NewNonInvasiveVent) OVER (PARTITION BY icustay_id ORDER BY charttime)
    ELSE NULL
END AS NumNonInvasiveVent
FROM vd1
)
,vd3 AS(
SELECT 0 AS hadm_id, 0 AS subject_id, icustay_id
	,ROW_NUMBER() over (PARTITION BY icustay_id ORDER BY NumInvasiveVent) AS NumInvasiveVent
	,0 AS NumNonInvasiveVent
	,MIN(charttime) AS starttime
	,MAX(charttime) AS endtime
	,NULL as WeaningSuccess
	,SelfExtubation
	,EXTRACT(EPOCH FROM MAX(charttime)-MIN(charttime))/60/60 AS VentHours
FROM vd2
GROUP BY icustay_id, NumInvasiveVent, SelfExtubation
HAVING MIN(charttime) != MAX(charttime)
AND EXTRACT(EPOCH FROM MAX(charttime)-MIN(charttime))/60/60 >= 12
AND MAX(InvasiveVentilation) = 1

UNION

SELECT 0 AS hadm_id, 0 AS subject_id, icustay_id
	,0 AS NumInvasiveVent
	,ROW_NUMBER() over (PARTITION BY icustay_id ORDER BY NumNonInvasiveVent) AS NumNonInvasiveVent
	,MIN(charttime) AS starttime
	,MAX(charttime) AS endtime
	,NULL as WeaningSuccess
	,SelfExtubation
	,EXTRACT(EPOCH FROM MAX(charttime)-MIN(charttime))/60/60 AS VentHours
FROM vd2
GROUP BY icustay_id, NumNonInvasiveVent, SelfExtubation
HAVING MIN(charttime) != MAX(charttime)
AND MAX(NonInvasiveVentilation) = 1

ORDER BY icustay_id, starttime
)
SELECT ROW_NUMBER() OVER () AS rownb, subject_id, hadm_id, icustay_id, NumInvasiveVent, NumNonInvasiveVent, StartTime, EndTime
,CAST(NULL AS VARCHAR) AS Method, WeaningSuccess, SelfExtubation, 0 AS Tracheostomy, VentHours
FROM vd3;

-- Set Tracheostomy to 1 when during the ICU stay there's some Tracheostomy
-- Not perfect, cause a patient may have a first invasive ventilation without tracheostomy and then a second with tracheostomy
-- So, it's just to exclude patients with a tracheostomy during the ICU stay
UPDATE ventdurations SET Tracheostomy = 1 WHERE icustay_id IN (SELECT DISTINCT(icustay_id) FROM wmvventsettings WHERE Tracheostomy = 1);



-- Method is how we know that a patient is extubated ?
-- With an extubation flag, it is often reliable. With Oxygenation or NIV flag, it is maybe a little less reliable.
-- Extubation flag set in second position, to change some 'Oxygenation or NIV flag' with an Extubation flag.

UPDATE ventdurations vd SET Method = 'Oxygenation or NIV flag'
FROM ventsettings vs
WHERE vd.icustay_id = vs.icustay_id
AND (vs.oxygenation = 1 OR vs.noninvasiveventilation = 1)
AND vs.charttime BETWEEN vd.endtime - INTERVAL '3' HOUR AND vd.endtime + INTERVAL '24' HOUR
;

UPDATE ventdurations vd SET Method = 'Extubation flag'
FROM ventsettings vs
WHERE vd.icustay_id = vs.icustay_id
AND vs.extubation = 1
AND vs.charttime BETWEEN vd.endtime - INTERVAL '3' HOUR AND vd.endtime + INTERVAL '24' HOUR
;
