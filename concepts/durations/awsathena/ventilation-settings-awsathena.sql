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


-- First, create a temporary table to store relevant data from CHARTEVENTS.

CREATE TABLE DATABASE.ventsettings AS
select
  icustay_id, charttime
  -- case statement determining whether it is an instance of mech vent
  , max(
    case
      when itemid is null or value is null then 0 -- can't have null values
      when itemid = 720 and value != 'Other/Remarks' THEN 1  -- VentTypeRecorded
      when itemid = 223848 and value != 'Other' THEN 1
      when itemid = 223849 then 1 -- ventilator mode
      when itemid = 467 and value = 'Ventilator' THEN 1 -- O2 delivery device == ventilator
      when itemid in
        (
        445, 448, 449, 450, 1340, 1486, 1600, 224687 -- minute volume
        , 639, 654, 681, 682, 683, 684,224685,224684,224686 -- tidal volume
        , 218,436,535,444,459,224697,224695,224696,224746,224747 -- High/Low/Peak/Mean/Neg insp force ("RespPressure")
        , 221,1,1211,1655,2000,226873,224738,224419,224750,227187 -- Insp pressure
        , 543 -- PlateauPressure
        , 5865,5866,224707,224709,224705,224706 -- APRV pressure
        , 60,437,505,506,686,220339,224700 -- PEEP
        , 3459 -- high pressure relief
        , 501,502,503,224702 -- PCV
        , 223,667,668,669,670,671,672 -- TCPCV
        , 224701 -- PSVlevel
        )
        THEN 1
      else 0
    end
    ) as MechVent
    , max(
      case
        -- initiation of oxygen therapy indicates the ventilation has ended
        when itemid = 226732 and value in
        (
          'Nasal cannula', -- 153714 observations
          'Face tent', -- 24601 observations
          'Aerosol-cool', -- 24560 observations
          'Trach mask ', -- 16435 observations
          'High flow neb', -- 10785 observations
          'Non-rebreather', -- 5182 observations
          'Venti mask ', -- 1947 observations
          'Medium conc mask ', -- 1888 observations
          'T-piece', -- 1135 observations
          'High flow nasal cannula', -- 925 observations
          'Ultrasonic neb', -- 9 observations
          'Vapomist' -- 3 observations
        ) then 1
        when itemid = 467 and value in
        (
          'Cannula', -- 278252 observations
          'Nasal Cannula', -- 248299 observations
          -- 'None', -- 95498 observations
          'Face Tent', -- 35766 observations
          'Aerosol-Cool', -- 33919 observations
          'Trach Mask', -- 32655 observations
          'Hi Flow Neb', -- 14070 observations
          'Non-Rebreather', -- 10856 observations
          'Venti Mask', -- 4279 observations
          'Medium Conc Mask', -- 2114 observations
          'Vapotherm', -- 1655 observations
          'T-Piece', -- 779 observations
          'Hood', -- 670 observations
          'Hut', -- 150 observations
          'TranstrachealCat', -- 78 observations
          'Heated Neb', -- 37 observations
          'Ultrasonic Neb' -- 2 observations
        ) then 1
      else 0
      end
    ) as OxygenTherapy
    , max(
      case when itemid is null or value is null then 0
        -- extubated indicates ventilation event has ended
        when itemid = 640 and value = 'Extubated' then 1
        when itemid = 640 and value = 'Self Extubation' then 1
      else 0
      end
      )
      as Extubated
    , max(
      case when itemid is null or value is null then 0
        when itemid = 640 and value = 'Self Extubation' then 1
      else 0
      end
      )
      as SelfExtubated
from DATABASE.chartevents ce
where ce.value <> ''
-- exclude rows marked as error
and ce.error IS DISTINCT FROM 1
and itemid in
(
    -- the below are settings used to indicate ventilation
      720, 223849 -- vent mode
    , 223848 -- vent type
    , 445, 448, 449, 450, 1340, 1486, 1600, 224687 -- minute volume
    , 639, 654, 681, 682, 683, 684,224685,224684,224686 -- tidal volume
    , 218,436,535,444,224697,224695,224696,224746,224747 -- High/Low/Peak/Mean ("RespPressure")
    , 221,1,1211,1655,2000,226873,224738,224419,224750,227187 -- Insp pressure
    , 543 -- PlateauPressure
    , 5865,5866,224707,224709,224705,224706 -- APRV pressure
    , 60,437,505,506,686,220339,224700 -- PEEP
    , 3459 -- high pressure relief
    , 501,502,503,224702 -- PCV
    , 223,667,668,669,670,671,672 -- TCPCV
    , 224701 -- PSVlevel

    -- the below are settings used to indicate extubation
    , 640 -- extubated

    -- the below indicate oxygen/NIV, i.e. the end of a mechanical vent event
    , 468 -- O2 Delivery Device#2
    , 469 -- O2 Delivery Mode
    , 470 -- O2 Flow (lpm)
    , 471 -- O2 Flow (lpm) #2
    , 227287 -- O2 Flow (additional cannula)
    , 226732 -- O2 Delivery Device(s)
    , 223834 -- O2 Flow

    -- used in both oxygen + vent calculation
    , 467 -- O2 Delivery Device
)
group by icustay_id, charttime
UNION
-- add in the extubation flags from procedureevents_mv
-- note that we only need the start time for the extubation
-- (extubation is always charted as ending 1 minute after it started)
select
  icustay_id, starttime as charttime
  , 0 as MechVent
  , 0 as OxygenTherapy
  , 1 as Extubated
  , case when itemid = 225468 then 1 else 0 end as SelfExtubated
from DATABASE.procedureevents_mv
where itemid in
(
  227194 -- "Extubation"
, 225468 -- "Unplanned Extubation (patient-initiated)"
, 225477 -- "Unplanned Extubation (non-patient initiated)"
);