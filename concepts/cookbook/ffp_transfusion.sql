-- --------------------------------------------------------
-- Title: Retrieves instances of FFP transfusions
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------


drop materialized view if exists ffp_transfusion cascade; 
create materialized view ffp_transfusion as

with raw_ffp as (
  select amount
    , amountuom
    , icustay_id
    , charttime as tsp
  from inputevents_cv
  where itemid in (
      30005,  -- Fresh Frozen Plasma
      30180,  -- Fresh Froz Plasma
      44172,  -- FFP GTT         
      44236,  -- E.R. FFP        
      46410,  -- angio FFP
      46418,  -- ER ffp
      46684,  -- ER FFP
      44819,  -- FFP ON FARR 2
      46530,  -- Floor FFP       
      44044,  -- FFP Drip
      46122,  -- ER in FFP
      45669,  -- ED FFP
      42323   -- er ffp
    )
    and amount > 0

  union

  select amount
    , amountuom
    , icustay_id
    , starttime as tsp
  from inputevents_mv
  where itemid in (
      220970   -- Fresh Frozen Plasma
    )
    and amount > 0
),

cumulative_ffp as (
  select sum(amount) over (partition by icustay_id order by tsp desc) as amount
    , amountuom
    , icustay_id
    , tsp
    , lag(tsp) over (partition by icustay_id order by tsp) - tsp as delta
  from raw_ffp
)

-- We consider any transfusions started within 1 hr of the last one
-- to be part of the same event
select amount - case
      when row_number() over (partition by icustay_id order by tsp desc) = 1 then 0
      else lag(amount) over (partition by icustay_id order by tsp desc) 
    end as amount
  , amountuom
  , icustay_id
  , tsp
from cumulative_ffp
where delta is null or delta < '-1 hour'::interval
order by icustay_id, tsp;
