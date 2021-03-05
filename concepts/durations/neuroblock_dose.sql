-- This query extracts dose+durations of neuromuscular blocking agents
-- Note: we assume that injections will be filtered for carevue as they will have starttime = stopttime.

-- Get drug administration data from CareVue and MetaVision
-- metavision is simple and only requires one temporary table
with drugmv as
(
  select
      icustay_id, orderid
    , rate as vaso_rate
    , amount as vaso_amount
    , starttime
    , endtime
  from inputevents_mv
  where itemid in
  (
      222062 -- Vecuronium (664 rows, 154 infusion rows)
    , 221555 -- Cisatracurium (9334 rows, 8970 infusion rows)
  )
  and statusdescription != 'Rewritten' -- only valid orders
  and rate is not null -- only continuous infusions
)
, drugcv1 as
(
  select
    icustay_id, charttime
    -- where clause below ensures all rows are instance of the drug
    , 1 as drug

    -- the 'stopped' column indicates if a drug has been disconnected
    , max(case when stopped in ('Stopped','D/C''d') then 1 else 0 end) as drug_stopped

    -- we only include continuous infusions, therefore expect a rate
    , max(case
            -- for "free form" entries (itemid >= 40000) rate is not available
            when itemid >= 40000 and amount is not null then 1
            when itemid <  40000 and rate is not null then 1
          else 0 end) as drug_null
    , max(case
            -- for "free form" entries (itemid >= 40000) rate is not available
            when itemid >= 40000 then coalesce(rate, amount)
          else rate end) as drug_rate
    , max(amount) as drug_amount
  from inputevents_cv
  where itemid in
  (
      30114 -- Cisatracurium (63994 rows)
    , 30138	-- Vecuronium	 (5160 rows)
    , 30113 -- Atracurium  (1163 rows)
    -- Below rows are less frequent ad-hoc documentation, but worth including!
    , 42174	-- nimbex cc/hr (207 rows)
    , 42385	-- Cisatracurium gtt (156 rows)
    , 41916	-- NIMBEX	inputevents_cv (136 rows)
    , 42100	-- cistatracurium	(132 rows)
    , 42045	-- nimbex mcg/kg/min (78 rows)
    , 42246 -- CISATRICARIUM CC/HR (70 rows)
    , 42291	-- NIMBEX CC/HR (48 rows)
    , 42590	-- nimbex	inputevents_cv (38 rows)
    , 42284	-- CISATRACURIUM DRIP (9 rows)
    , 45096	-- Vecuronium drip (2 rows)
  )
  group by icustay_id, charttime
  UNION
  -- add data from chartevents
  select
    icustay_id, charttime
    -- where clause below ensures all rows are instance of the drug
    , 1 as drug

    -- the 'stopped' column indicates if a drug has been disconnected
    , max(case when stopped in ('Stopped','D/C''d') then 1 else 0 end) as drug_stopped
    , max(case when valuenum <= 10 then 0 else 1 end) as drug_null

    -- educated guess!
    , max(case when valuenum <= 10 then valuenum else null end) as drug_rate
    , max(case when valuenum  > 10 then valuenum else null end) as drug_amount
  from chartevents
  where itemid in
  (
      1856 -- Vecuronium mcg/min  (8 rows)
    , 2164 -- NIMBEX MG/KG/HR  (243 rows)
    , 2548 -- nimbex mg/kg/hr  (103 rows)
    , 2285 -- nimbex mcg/kg/min  (85 rows)
    , 2290 -- nimbex mcg/kg/m  (32 rows)
    , 2670 -- nimbex  (38 rows)
    , 2546 -- CISATRACURIUMMG/KG/H  (7 rows)
    , 1098 -- cisatracurium mg/kg  (36 rows)
    , 2390 -- cisatracurium mg/hr  (15 rows)
    , 2511 -- CISATRACURIUM GTT  (4 rows)
    , 1028 -- Cisatracurium  (208 rows)
    , 1858 -- cisatracurium  (351 rows)
  )
  group by icustay_id, charttime

)
, drugcv2 as
(
  select v.*
    , sum(drug_null) over (partition by icustay_id order by charttime) as drug_partition
  from
    drugcv1 v
)
, drugcv3 as
(
  select v.*
    , first_value(drug_rate) over (partition by icustay_id, drug_partition order by charttime) as drug_prevrate_ifnull
  from
    drugcv2 v
)
, drugcv4 as
(
select
    icustay_id
    , charttime
    -- , (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, drug order by charttime))) AS delta

    , drug
    , drug_rate
    , drug_amount
    , drug_stopped
    , drug_prevrate_ifnull

    -- We define start time here
    , case
        when drug = 0 then null

        -- if this is the first instance of the drug
        when drug_rate > 0 and
          LAG(drug_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, drug, drug_null
          order by charttime
          )
          is null
          then 1

        -- you often get a string of 0s
        -- we decide not to set these as 1, just because it makes drugnum sequential
        when drug_rate = 0 and
          LAG(drug_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, drug
          order by charttime
          )
          = 0
          then 0

        -- sometimes you get a string of NULL, associated with 0 volumes
        -- same reason as before, we decide not to set these as 1
        -- drug_prevrate_ifnull is equal to the previous value *iff* the current value is null
        when drug_prevrate_ifnull = 0 and
          LAG(drug_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, drug
          order by charttime
          )
          = 0
          then 0

        -- If the last recorded rate was 0, newdrug = 1
        when LAG(drug_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, drug
          order by charttime
          ) = 0
          then 1

        -- If the last recorded drug was D/C'd, newdrug = 1
        when
          LAG(drug_stopped,1)
          OVER
          (
          partition by icustay_id, drug
          order by charttime
          )
          = 1 then 1

        when (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, drug order by charttime))) > (interval '8 hours') then 1
      else null
      end as drug_start

FROM
  drugcv3
)
-- propagate start/stop flags forward in time
, drugcv5 as
(
  select v.*
    , SUM(drug_start) OVER (partition by icustay_id, drug order by charttime) as drug_first
FROM
  drugcv4 v
)
, drugcv6 as
(
  select v.*
    -- We define end time here
    , case
        when drug = 0
          then null

        -- If the recorded drug was D/C'd, this is an end time
        when drug_stopped = 1
          then drug_first

        -- If the rate is zero, this is the end time
        when drug_rate = 0
          then drug_first

        -- the last row in the table is always a potential end time
        -- this captures patients who die/are discharged while on drug
        -- in principle, this could add an extra end time for the drug
        -- however, since we later group on drug_start, any extra end times are ignored
        when LEAD(CHARTTIME,1)
          OVER
          (
          partition by icustay_id, drug
          order by charttime
          ) is null
          then drug_first

        else null
        end as drug_stop
    from drugcv5 v
)

-- -- if you want to look at the results of the table before grouping:
-- select
--   icustay_id, charttime, drug, drug_rate, drug_amount
--     , drug_stopped
--     , drug_start
--     , drug_first
--     , drug_stop
-- from drugcv6 order by icustay_id, charttime;

, drugcv7 as
(
select
  icustay_id
  , charttime as starttime
  , lead(charttime) OVER (partition by icustay_id, drug_first order by charttime) as endtime
  , drug, drug_rate, drug_amount, drug_stop, drug_start, drug_first
from drugcv6
where
  drug_first is not null -- bogus data
and
  drug_first != 0 -- sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered
and
  icustay_id is not null -- there are data for "floating" admissions, we don't worry about these
)
-- table of start/stop times for event
, drugcv8 as
(
  select
    icustay_id
    , starttime, endtime
    , drug, drug_rate, drug_amount, drug_stop, drug_start, drug_first
  from drugcv7
  where endtime is not null
  and drug_rate > 0
  and starttime != endtime
)
-- collapse these start/stop times down if the rate doesn't change
, drugcv9 as
(
  select
    icustay_id
    , starttime, endtime
    , case
        when LAG(endtime) OVER (partition by icustay_id order by starttime, endtime) = starttime
        AND  LAG(drug_rate) OVER (partition by icustay_id order by starttime, endtime) = drug_rate
        THEN 0
      else 1
    end as drug_groups
    , drug, drug_rate, drug_amount, drug_stop, drug_start, drug_first
  from drugcv8
  where endtime is not null
  and drug_rate > 0
  and starttime != endtime
)
, drugcv10 as
(
  select
    icustay_id
    , starttime, endtime
    , drug_groups
    , SUM(drug_groups) OVER (partition by icustay_id order by starttime, endtime) as drug_groups_sum
    , drug, drug_rate, drug_amount, drug_stop, drug_start, drug_first
  from drugcv9
)
, drugcv as
(
  select icustay_id
  , min(starttime) as starttime
  , max(endtime) as endtime
  , drug_groups_sum
  , drug_rate
  , sum(drug_amount) as drug_amount
  from drugcv10
  group by icustay_id, drug_groups_sum, drug_rate
)
-- now assign this data to every hour of the patient's stay
-- drug_amount for carevue is not accurate
SELECT icustay_id
  , starttime, endtime
  , drug_rate, drug_amount
from drugcv
UNION
SELECT icustay_id
  , starttime, endtime
  , drug_rate, drug_amount
from drugmv
order by icustay_id, starttime;
