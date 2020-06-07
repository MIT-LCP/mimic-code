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
      30180   -- Fresh Froz Plasma
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

pre_icu_ffp as (
  select sum(amount) as amount, icustay_id
  from inputevents_cv
  where itemid in (
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
  group by icustay_id
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
select cum.amount - case
      when row_number() over (partition by cum.icustay_id order by cum.tsp desc) = 1 then 0
      else lag(cum.amount) over (partition by cum.icustay_id order by cum.tsp desc) 
    end as amount
  , cum.amount + case
      when pre.amount is null then 0
      else pre.amount
    end as totalamount
  , cum.amountuom
  , cum.icustay_id
  , cum.tsp
from cumulative_ffp as cum
left join pre_icu_ffp as pre
    using (icustay_id)
where delta is null or delta < '-1 hour'::interval
order by icustay_id, tsp;
