DROP TABLE IF EXISTS `physionet-data.mimic_derived.ventdurations`;
CREATE TABLE IF NOT EXISTS `physionet-data.mimic_derived.ventdurations` as
with vd0 as
(
  select
    stay_id
    -- this carries over the previous charttime which had a mechanical ventilation event
    , case
        when MechVent=1 then
          LAG(charttime, 1) OVER (partition by stay_id, MechVent order by charttime)
        else null
      end as charttime_lag
    , charttime
    , MechVent
    , OxygenTherapy
    , Extubated
    , SelfExtubated
  from `physionet-data.mimic_derived.ventsettings`
)
, vd1 as
(
  select
      stay_id
      , charttime_lag
      , charttime
      , MechVent
      , OxygenTherapy
      , Extubated
      , SelfExtubated

      -- if this is a mechanical ventilation event, we calculate the time since the last event
      , case
          -- if the current observation indicates mechanical ventilation is present
          -- calculate the time since the last vent event
          when MechVent=1 then
            DATETIME_DIFF(charttime, charttime_lag, HOUR)
          else null
        end as ventduration

      , LAG(Extubated,1)
      OVER
      (
      partition by stay_id, case when MechVent=1 or Extubated=1 then 1 else 0 end
      order by charttime
      ) as ExtubatedLag

      -- now we determine if the current mech vent event is a "new", i.e. they've just been intubated
      , case
        -- if there is an extubation flag, we mark any subsequent ventilation as a new ventilation event
          --when Extubated = 1 then 0 -- extubation is *not* a new ventilation event, the *subsequent* row is
          when
            LAG(Extubated,1)
            OVER
            (
            partition by stay_id, case when MechVent=1 or Extubated=1 then 1 else 0 end
            order by charttime
            )
            = 1 then 1
          -- if patient has initiated oxygen therapy, and is not currently vented, start a newvent
          when MechVent = 0 and OxygenTherapy = 1 then 1
            -- if there is less than 8 hours between vent settings, we do not treat this as a new ventilation event
          when DATETIME_DIFF(charttime, charttime_lag, HOUR) > 8
            then 1
        else 0
        end as newvent
  -- use the staging table with only vent settings from chart events
  FROM vd0 `physionet-data.mimic_derived.ventsettings`
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
  , ROW_NUMBER() over (partition by stay_id order by ventnum) as vent_seq
  , min(charttime) as starttime
  , max(charttime) as endtime
  , DATETIME_DIFF(max(charttime), min(charttime), SECOND) / 60 / 60 AS duration_hours
from vd2
group by stay_id, ventnum
having min(charttime) != max(charttime)
-- patient had to be mechanically ventilated at least once
-- i.e. max(mechvent) should be 1
-- this excludes a frequent situation of NIV/oxygen before intub
-- in these cases, ventnum=0 and max(mechvent)=0, so they are ignored
and max(MechVent) = 1
;