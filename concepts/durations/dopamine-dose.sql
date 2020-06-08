-- This query extracts dose+durations of dopamine administration

-- Get drug administration data from CareVue first
with vasocv1 as
(
  select
    icustay_id, charttime
    -- case statement determining whether the ITEMID is an instance of vasopressor usage
    , max(case when itemid in (30043,30307) then 1 else 0 end) as vaso -- dopamine

    -- the 'stopped' column indicates if a vasopressor has been disconnected
    , max(case when itemid in (30043,30307) and (stopped = 'Stopped' OR stopped like 'D/C%') then 1
          else 0 end) as vaso_stopped

    , max(case when itemid in (30043,30307) and rate is not null then 1 else 0 end) as vaso_null
    , max(case when itemid in (30043,30307) then rate else null end) as vaso_rate
    , max(case when itemid in (30043,30307) then amount else null end) as vaso_amount

  FROM `physionet-data.mimiciii_clinical.inputevents_cv`
  where itemid in
  (
        30043,30307 -- dopamine
  )
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
    -- , (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, vaso order by charttime))) AS delta

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
          LAG(vaso_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, vaso, vaso_null
          order by charttime
          )
          is null
          then 1

        -- you often get a string of 0s
        -- we decide not to set these as 1, just because it makes vasonum sequential
        when vaso_rate = 0 and
          LAG(vaso_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, vaso
          order by charttime
          )
          = 0
          then 0

        -- sometimes you get a string of NULL, associated with 0 volumes
        -- same reason as before, we decide not to set these as 1
        -- vaso_prevrate_ifnull is equal to the previous value *iff* the current value is null
        when vaso_prevrate_ifnull = 0 and
          LAG(vaso_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, vaso
          order by charttime
          )
          = 0
          then 0

        -- If the last recorded rate was 0, newvaso = 1
        when LAG(vaso_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, vaso
          order by charttime
          ) = 0
          then 1

        -- If the last recorded vaso was D/C'd, newvaso = 1
        when
          LAG(vaso_stopped,1)
          OVER
          (
          partition by icustay_id, vaso
          order by charttime
          )
          = 1 then 1

        -- ** not sure if the below is needed
        --when (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, vaso order by charttime))) > (interval '4 hours') then 1
      else null
      end as vaso_start

FROM
  vasocv3
)
-- propagate start/stop flags forward in time
, vasocv5 as
(
  select v.*
    , SUM(vaso_start) OVER (partition by icustay_id, vaso order by charttime) as vaso_first
FROM
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
        when LEAD(CHARTTIME,1)
          OVER
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
--     , vaso_stopped
--     , vaso_start
--     , vaso_first
--     , vaso_stop
-- from vasocv6 order by icustay_id, charttime;

, vasocv7 as
(
select
  icustay_id
  , charttime as starttime
  , lead(charttime) OVER (partition by icustay_id, vaso_first order by charttime) as endtime
  , vaso, vaso_rate, vaso_amount, vaso_stop, vaso_start, vaso_first
from vasocv6
where
  vaso_first is not null -- bogus data
and
  vaso_first != 0 -- sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered
and
  icustay_id is not null -- there are data for "floating" admissions, we don't worry about these
)
-- table of start/stop times for event
, vasocv8 as
(
  select
    icustay_id
    , starttime, endtime
    , vaso, vaso_rate, vaso_amount, vaso_stop, vaso_start, vaso_first
  from vasocv7
  where endtime is not null
  and vaso_rate > 0
  and starttime != endtime
)
-- collapse these start/stop times down if the rate doesn't change
, vasocv9 as
(
  select
    icustay_id
    , starttime, endtime
    , case
        when LAG(endtime) OVER (partition by icustay_id order by starttime, endtime) = starttime
        AND  LAG(vaso_rate) OVER (partition by icustay_id order by starttime, endtime) = vaso_rate
        THEN 0
      else 1
    end as vaso_groups
    , vaso, vaso_rate, vaso_amount, vaso_stop, vaso_start, vaso_first
  from vasocv8
  where endtime is not null
  and vaso_rate > 0
  and starttime != endtime
)
, vasocv10 as
(
  select
    icustay_id
    , starttime, endtime
    , vaso_groups
    , SUM(vaso_groups) OVER (partition by icustay_id order by starttime, endtime) as vaso_groups_sum
    , vaso, vaso_rate, vaso_amount, vaso_stop, vaso_start, vaso_first
  from vasocv9
)
, vasocv as
(
  select icustay_id
  , min(starttime) as starttime
  , max(endtime) as endtime
  , vaso_groups_sum
  , vaso_rate
  , sum(vaso_amount) as vaso_amount
  from vasocv10
  group by icustay_id, vaso_groups_sum, vaso_rate
)
-- now we extract the associated data for metavision patients
, vasomv as
(
  select
    icustay_id, linkorderid
    , rate as vaso_rate
    , amount as vaso_amount
    , starttime
    , endtime
  from `physionet-data.mimiciii_clinical.inputevents_mv`
  where itemid = 221662 -- dopamine
  and statusdescription != 'Rewritten' -- only valid orders
)
-- now assign this data to every hour of the patient's stay
-- vaso_amount for carevue is not accurate
SELECT icustay_id
  , starttime, endtime
  , vaso_rate, vaso_amount
from vasocv
UNION ALL
SELECT icustay_id
  , starttime, endtime
  , vaso_rate, vaso_amount
from vasomv
order by icustay_id, starttime;
