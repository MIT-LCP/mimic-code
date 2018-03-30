-- --------------------------------------------------------
-- Title: Retrieves instances of FFP transfusions
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- --------------------------------------------------------


drop materialized view if exists ffp_transfusion cascade; 
create materialized view ffp_transfusion as

select sum(amount) as amount
  , amountuom
  , icustay_id
  , min(charttime) as tsp
from inputevents_cv
where itemid in (
    30005,  -- Fresh Frozen Plasma
    30180,  -- Fresh Froz Plasma
    30103,  -- OR FFP          
    42185,  -- Pre admit FFP   
    44172,  -- FFP GTT         
    44236,  -- E.R. FFP        
    43009,  -- ffp pacu        
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
group by linkorderid, icustay_id, amountuom

union

select sum(amount) as amount
  , amountuom
  , icustay_id
  , min(starttime) as tsp
from inputevents_mv
where itemid in (
    227072,  -- PACU FFP Intake
    226367,  -- OR FFP Intake
    220970   -- Fresh Frozen Plasma
  )
  and amount > 0
group by linkorderid, icustay_id, amountuom;
