-- --------------------------------------------------------
-- Title: Retrieves instances of RBC transfusions
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------


drop materialized view if exists rbc_transfusion cascade; 
create materialized view rbc_transfusion as

with raw_rbc as (
  select amount
    , amountuom
    , icustay_id
    , charttime as tsp
  from inputevents_cv
  where itemid in (
      30179,  -- PRBC's
      30001,  -- Packed RBC's
      30004,  -- Washed PRBC's
    )
    and amount > 0

  union

  select amount
    , amountuom
    , icustay_id
    , starttime as tsp
  from inputevents_mv
  where itemid in (
      225168   -- Packed Red Blood Cells
    )
    and amount > 0
),

pre_icu_rbc as (
  select sum(amount) as amount, icustay_id
  from inputevents_cv
  where itemid in (
      42324,  -- er prbc
      42588,  -- VICU PRBC
      42239,  -- CC7 PRBC
      46407,  -- ED PRBC
      46612,  -- E.R. prbc
      46124,  -- er in prbc
      42740   -- prbc in er
    )
    and amount > 0
  group by icustay_id
),

cumulative_rbc as (
  select sum(amount) over (partition by icustay_id order by tsp desc) as amount
    , amountuom
    , icustay_id
    , tsp
    , lag(tsp) over (partition by icustay_id order by tsp) - tsp as delta
  from raw_rbc
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
from cumulative_rbc as cum
left join pre_icu_rbc as pre
    using (icustay_id)
where delta is null or delta < '-1 hour'::interval
order by icustay_id, tsp;
