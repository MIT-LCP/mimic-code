-- Calculate duration of mechanical ventilation.
-- Some useful cases for debugging:
--  stay_id = 30019660 has a tracheostomy placed in the ICU
--  stay_id = 30000117 has explicit documentation of extubation
WITH vs AS
(
    select
    stay_id, charttime
    -- case statement determining whether it is an instance of mech vent
    , MAX(CASE
        WHEN ventilator_mode IS NOT NULL THEN 1
      ELSE NULL END
    ) as MechVent
    , MAX(COALESCE(extubated, 0)) AS Extubated
  FROM `physionet-data.mimic_derived.ventilator_setting`
  GROUP BY stay_id, charttime
)
, vd0 AS
(
  select
    stay_id
    -- this carries over the previous charttime which had a mechanical ventilation event
    , case
        when MechVent = 1 then
          LAG(charttime, 1) OVER (partition by stay_id, MechVent order by charttime)
        else null
      end as charttime_lag
    -- carry forward our extubated flag
    -- need the extubated row to be included in the current mechvent partition,
    -- so that the endtime is set to the time that extubated is charted
    -- to do this, we use lag(extubated) to set mechvent = 0
    , LAG(Extubated,1)
      OVER
      (
        partition by stay_id
        order by charttime
      ) as ExtubatedLag
    , charttime
    , MechVent
    , Extubated
  from vs
)
, vd1 as
(
  select
      stay_id
      , charttime_lag
      , charttime
      , MechVent
      , Extubated

      -- calculate the time since the last event
      -- since charttime_lag is NULL for non-mechvent rows, this is only present on MechVent=1 rows
      , DATETIME_DIFF(charttime, charttime_lag, MINUTE)/60 as ventduration

      -- now we determine if the current mech vent event is a "new", i.e. they've just been intubated
      , case
          -- if there was an extubation flag on the previously charted row,
          -- then this row is a new ventilation event
          WHEN ExtubatedLag = 1 THEN 1
          -- we want to include the row with the extubation in the current mechvent event
          -- this makes our endtime of that event == the time of extubation
          WHEN Extubated = 1 THEN 0
          -- if we have specified MechVent = 0, then the settings indicated *not* mech vent
          -- thus, they must have been extubated previous to this time
          when MechVent = 0 then 1
          -- if there has been 8 hours since the last mech vent documentation,
          -- then we assume they were extubated earlier
          when CHARTTIME > DATETIME_ADD(charttime_lag, INTERVAL 8 HOUR)
            then 1
        else 0
        end as newvent
  -- use the staging table with only vent settings from chart events
  FROM vd0 ventsettings
)
, vd2 as
(
  select vd1.*
  -- create a cumulative sum of the instances of new ventilation
  -- this results in a monotonic integer assigned to each instance of ventilation
  , case when MechVent=1 or Extubated = 1 then
      SUM( newvent )
      OVER ( partition by stay_id order by charttime )
    else null end
    as ventnum
  --- now we convert CHARTTIME of ventilator settings into durations
  from vd1
)
-- create the durations for each mechanical ventilation instance
select stay_id
  -- regenerate ventnum so it's sequential
  , ROW_NUMBER() over (partition by stay_id order by ventnum) as ventnum
  , min(charttime) as starttime
  , max(charttime) as endtime
from vd2
group by stay_id, vd2.ventnum
having min(charttime) != max(charttime)
-- patient had to be mechanically ventilated at least once
-- i.e. max(mechvent) should be 1
-- this excludes a frequent situation of NIV/oxygen before intub
-- in these cases, ventnum=0 and max(mechvent)=0, so they are ignored
and MAX(mechvent) = 1;