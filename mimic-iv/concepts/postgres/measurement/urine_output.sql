-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS urine_output; CREATE TABLE urine_output AS 
select
  stay_id
  , charttime
  , sum(urineoutput) as urineoutput
from
(
    select
    -- patient identifiers
    oe.stay_id
    , oe.charttime
    -- volumes associated with urine output ITEMIDs
    -- note we consider input of GU irrigant as a negative volume
    -- GU irrigant volume in usually has a corresponding volume out
    -- so the net is often 0, despite large irrigant volumes
    , case
        when oe.itemid = 227488 and oe.value > 0 then -1*oe.value
        else oe.value
    end as urineoutput
    from mimiciv_icu.outputevents oe
    where itemid in
    (
    226559, -- Foley
    226560, -- Void
    226561, -- Condom Cath
    226584, -- Ileoconduit
    226563, -- Suprapubic
    226564, -- R Nephrostomy
    226565, -- L Nephrostomy
    226567, -- Straight Cath
    226557, -- R Ureteral Stent
    226558, -- L Ureteral Stent
    227488, -- GU Irrigant Volume In
    227489  -- GU Irrigant/Urine Volume Out
    )
) uo
group by stay_id, charttime
;
