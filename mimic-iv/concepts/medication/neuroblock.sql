-- This query extracts dose+durations of neuromuscular blocking agents
SELECT
    stay_id, orderid
    , rate AS drug_rate
    , amount AS drug_amount
    , starttime
    , endtime
FROM `physionet-data.mimiciv_icu.inputevents`
WHERE itemid IN
    (
        222062 -- Vecuronium (664 rows, 154 infusion rows)
        , 221555 -- Cisatracurium (9334 rows, 8970 infusion rows)
    )
    AND rate IS NOT NULL -- only continuous infusions
