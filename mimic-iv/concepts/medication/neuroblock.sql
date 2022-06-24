-- This query extracts dose+durations of neuromuscular blocking agents
select
    stay_id, orderid
  , rate as drug_rate
  , amount as drug_amount
  , starttime
  , endtime
from `physionet-data.mimiciv_icu.inputevents`
where itemid in
(
    222062 -- Vecuronium (664 rows, 154 infusion rows)
  , 221555 -- Cisatracurium (9334 rows, 8970 infusion rows)
)
and rate is not null -- only continuous infusions