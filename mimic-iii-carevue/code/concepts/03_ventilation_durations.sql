drop table if exists ventilation_durations; create table ventilation_durations as 
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

-- See the ventilation_classification.sql query for step 1 of the above.
-- This query has the logic for converting events into durations.
with vd0 as
(
  select
    icustay_id
    -- this carries over the previous charttime which had a mechanical ventilation event
    , case
        when mechvent=1 then
          lag(charttime, 1) over (partition by icustay_id, MechVent order by charttime)
        else null
      end as charttime_lag
    , charttime
    , mechvent
    , oxygentherapy
    , extubated
    , selfextubated
  from ventilation_classification
)
, vd1 as
(
  select
    icustay_id
    , charttime_lag
    , charttime
    , mechvent
    , oxygentherapy
    , extubated
    , selfextubated

    -- if this is a mechanical ventilation event, we calculate the time since the last event
    , case
        -- if the current observation indicates mechanical ventilation is present
        -- calculate the time since the last vent event
        when mechvent=1 then
          round((cast(extract(epoch from (charttime - charttime_lag))/(60*60) as numeric)), 8)
        else null
      end as ventduration

    , lag(extubated,1) over (partition by icustay_id, case when mechvent=1 or extubated=1 then 1 else 0 end order by charttime) as extubatedlag

      -- now we determine if the current mech vent event is a "new", i.e. they've just been intubated
    , case
        -- if there is an extubation flag, we mark any subsequent ventilation as a new ventilation event
        --when Extubated = 1 then 0 -- extubation is *not* a new ventilation event, the *subsequent* row is
        when
          lag(extubated,1) over (partition by icustay_id, case when mechvent=1 or extubated=1 then 1 else 0 end order by charttime)= 1 then 1
        -- if patient has initiated oxygen therapy, and is not currently vented, start a newvent
        when mechvent = 0 and oxygentherapy = 1 then 1
        -- if there is less than 8 hours between vent settings, we do not treat this as a new ventilation event
        when charttime > charttime_lag + interval '8 hour' then 1
        else 0
        end as newvent
  -- use the staging table with only vent settings from chart events
  from vd0 ventsettings
)
, vd2 as
(
  select vd1.*
  -- create a cumulative sum of the instances of new ventilation
  -- this results in a monotonic integer assigned to each instance of ventilation
  , case when mechvent=1 or extubated = 1 then
      sum( newvent )
      over ( partition by icustay_id order by charttime )
    else null end as ventnum
  --- now we convert charttime of ventilator settings into durations
  from vd1
)
-- create the durations for each mechanical ventilation instance
select 
  icustay_id
  -- regenerate ventnum so it's sequential
  , row_number() over (partition by icustay_id order by ventnum) as ventnum
  , min(charttime) as starttime
  , max(charttime) as endtime
  , round((cast(extract(epoch from (max(charttime) - min(charttime)))/(60*60) as numeric)), 8) as duration_hours
from vd2
group by icustay_id, vd2.ventnum
having min(charttime) != max(charttime)
-- patient had to be mechanically ventilated at least once
-- i.e. max(mechvent) should be 1
-- this excludes a frequent situation of NIV/oxygen before intub
-- in these cases, ventnum=0 and max(mechvent)=0, so they are ignored
and max(mechvent) = 1
order by icustay_id, ventnum;