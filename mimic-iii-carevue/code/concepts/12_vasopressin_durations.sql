drop table if exists vasopressin_durations; create table vasopressin_durations as 
-- This query extracts durations of vasopressin administration
-- Consecutive administrations are numbered 1, 2, ...
-- Total time on the drug can be calculated from this table by grouping using icustay_id

-- Get drug administration data from CareVue first
with vasocv1 as
(
  select
    icustay_id, charttime
    -- case statement determining whether the itemid is an instance of vasopressor usage
    , max(case when itemid = 30051 then 1 else 0 end) as vaso -- vasopressin

    -- the 'stopped' column indicates if a vasopressor has been disconnected
    , max(case when itemid = 30051 and (stopped = 'Stopped' or stopped like 'D/C%') then 1
          else 0 end) as vaso_stopped

    , max(case when itemid = 30051 and rate is not null then 1 else 0 end) as vaso_null
    , max(case when itemid = 30051 then rate else null end) as vaso_rate
    , max(case when itemid = 30051 then amount else null end) as vaso_amount

  from inputevents_cv
  where itemid = 30051 -- vasopressin
  group by icustay_id, charttime
)

, vasocv2 as
(
  select v.*
    , sum(vaso_null) over (partition by icustay_id order by charttime) as vaso_partition
  from
    vasocv1 v
)

, vasocv3 as
(
  select v.*
    , first_value(vaso_rate) over (partition by icustay_id, vaso_partition order by charttime) as vaso_prevrate_ifnull
  from
    vasocv2 v
)

, vasocv4 as
(
  select
    icustay_id
    , charttime
    -- , (charttime - (lag(charttime, 1) over (partition by icustay_id, vaso order by charttime))) as delta

    , vaso
    , vaso_rate
    , vaso_amount
    , vaso_stopped
    , vaso_prevrate_ifnull

    -- We define start time here
    , case
        when vaso = 0 then null

        -- if this is the first instance of the vasoactive drug
        when vaso_rate > 0 and
          lag(vaso_prevrate_ifnull,1)
          over
          (
          partition by icustay_id, vaso, vaso_null
          order by charttime
          )
          is null
          then 1

        -- you often get a string of 0s
        -- we decide not to set these as 1, just because it makes vasonum sequential
        when vaso_rate = 0 and
          lag(vaso_prevrate_ifnull,1)
          over
          (
          partition by icustay_id, vaso
          order by charttime
          )
          = 0
          then 0

        -- sometimes you get a string of null, associated with 0 volumes
        -- same reason as before, we decide not to set these as 1
        -- vaso_prevrate_ifnull is equal to the previous value *iff* the current value is null
        when vaso_prevrate_ifnull = 0 and
          lag(vaso_prevrate_ifnull,1)
          over
          (
          partition by icustay_id, vaso
          order by charttime
          )
          = 0
          then 0

        -- If the last recorded rate was 0, newvaso = 1
        when lag(vaso_prevrate_ifnull,1)
          over
          (
          partition by icustay_id, vaso
          order by charttime
          ) = 0
          then 1

        -- If the last recorded vaso was D/C'd, newvaso = 1
        when
          lag(vaso_stopped,1)
          over
          (
          partition by icustay_id, vaso
          order by charttime
          )
          = 1 then 1

        -- ** not sure if the below is needed
        --when (charttime - (lag(charttime, 1) over (partition by icustay_id, vaso order by charttime))) > (interval '4 hours') then 1
      else null
      end as vaso_start
  from
    vasocv3
)
-- propagate start/stop flags forward in time

, vasocv5 as
(
  select v.*
    , sum(vaso_start) over (partition by icustay_id, vaso order by charttime) as vaso_first
  from
    vasocv4 v
)

, vasocv6 as
(
  select v.*
    -- We define end time here
    , case
        when vaso = 0
          then null

        -- If the recorded vaso was D/C'd, this is an end time
        when vaso_stopped = 1
          then vaso_first

        -- If the rate is zero, this is the end time
        when vaso_rate = 0
          then vaso_first

        -- the last row in the table is always a potential end time
        -- this captures patients who die/are discharged while on vasopressors
        -- in principle, this could add an extra end time for the vasopressor
        -- however, since we later group on vaso_start, any extra end times are ignored
        when lead(charttime,1)
          over
          (
          partition by icustay_id, vaso
          order by charttime
          ) is null
          then vaso_first

        else null
        end as vaso_stop
  from vasocv5 v
)

-- -- if you want to look at the results of the table before grouping:
-- select
--   icustay_id, charttime, vaso, vaso_rate, vaso_amount
--     , case when vaso_stopped = 1 then 'Y' else '' end as stopped
--     , vaso_start
--     , vaso_first
--     , vaso_stop
-- from vasocv6 order by charttime;

, vasocv as
(
  -- below groups together vasopressor administrations into groups
  select
    icustay_id
    -- the first non-null rate is considered the starttime
    , min(case when vaso_rate is not null then charttime else null end) as starttime
    -- the *first* time the first/last flags agree is the stop time for this duration
    , min(case when vaso_first = vaso_stop then charttime else null end) as endtime
  from vasocv6
  where
    vaso_first is not null -- bogus data
  and
    vaso_first != 0 -- sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered
  and
    icustay_id is not null -- there are data for "floating" admissions, we don't worry about these
  group by icustay_id, vaso_first
  having -- ensure start time is not the same as end time
    min(charttime) != min(case when vaso_first = vaso_stop then charttime else null end)
  and
    max(vaso_rate) > 0 -- if the rate was always 0 or null, we consider it not a real drug delivery
)

select
  icustay_id
  -- generate a sequential integer for convenience
  , row_number() over (partition by icustay_id order by starttime) as vasonum
  , starttime, endtime
  , round((cast(extract(epoch from (endtime - starttime))/(60*60) as numeric)), 8) as duration_hours
  -- add durations
from
  vasocv
order by icustay_id, vasonum;