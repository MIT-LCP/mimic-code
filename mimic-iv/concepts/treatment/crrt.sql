WITH crrt_settings AS (
    SELECT ce.stay_id, ce.charttime
        , CASE WHEN ce.itemid = 227290 THEN ce.value END AS crrt_mode
        , CASE
            WHEN ce.itemid = 224149 THEN ce.valuenum ELSE NULL
        END AS accesspressure
        -- (ml/min)
        , CASE
            WHEN ce.itemid = 224144 THEN ce.valuenum ELSE NULL
        END AS bloodflow
        -- (ACD-A)
        , CASE WHEN ce.itemid = 228004 THEN ce.valuenum ELSE NULL END AS citrate
        , CASE
            WHEN ce.itemid = 225183 THEN ce.valuenum ELSE NULL
        END AS currentgoal
        , CASE
            WHEN ce.itemid = 225977 THEN ce.value ELSE NULL
        END AS dialysatefluid
        , CASE
            WHEN ce.itemid = 224154 THEN ce.valuenum ELSE NULL
        END AS dialysaterate
        , CASE
            WHEN ce.itemid = 224151 THEN ce.valuenum ELSE NULL
        END AS effluentpressure
        , CASE
            WHEN ce.itemid = 224150 THEN ce.valuenum ELSE NULL
        END AS filterpressure
        -- (units/mL)
        , CASE
            WHEN ce.itemid = 225958 THEN ce.value ELSE NULL
        END AS heparinconcentration
        -- (per hour)
        , CASE
            WHEN ce.itemid = 224145 THEN ce.valuenum ELSE NULL
        END AS heparindose
        -- below may not account for drug infusion,
        -- hyperalimentation, and/or anticoagulants infused
        , CASE
            WHEN ce.itemid = 224191 THEN ce.valuenum ELSE NULL
        END AS hourlypatientfluidremoval
        , CASE
            WHEN ce.itemid = 228005 THEN ce.valuenum ELSE NULL
        END AS prefilterreplacementrate
        , CASE
            WHEN ce.itemid = 228006 THEN ce.valuenum ELSE NULL
        END AS postfilterreplacementrate
        , CASE
            WHEN ce.itemid = 225976 THEN ce.value ELSE NULL
        END AS replacementfluid
        , CASE
            WHEN ce.itemid = 224153 THEN ce.valuenum ELSE NULL
        END AS replacementrate
        , CASE
            WHEN ce.itemid = 224152 THEN ce.valuenum ELSE NULL
        END AS returnpressure
        , CASE
            WHEN ce.itemid = 226457 THEN ce.valuenum
        END AS ultrafiltrateoutput
        -- separate system integrity into sub components
        -- need to do this as 224146 has multiple unique values
        -- for a single charttime
        -- e.g. "Clots Present" and "Active" at same time
        , CASE
            WHEN ce.itemid = 224146
                AND ce.value IN (
                    'Active', 'Initiated', 'Reinitiated', 'New Filter'
                )
                THEN 1
            WHEN ce.itemid = 224146
                AND ce.value IN ('Recirculating', 'Discontinued')
                THEN 0
            ELSE NULL END AS system_active
        , CASE
            WHEN ce.itemid = 224146
                AND ce.value IN ('Clots Present', 'Clots Present')
                THEN 1
            WHEN ce.itemid = 224146
                AND ce.value IN ('No Clot Present', 'No Clot Present')
                THEN 0
            ELSE NULL END AS clots
        , CASE
            WHEN ce.itemid = 224146
                AND ce.value IN ('Clots Increasing', 'Clot Increasing')
                THEN 1
            ELSE NULL END AS clots_increasing
        , CASE
            WHEN ce.itemid = 224146
                AND ce.value IN ('Clotted')
                THEN 1
            ELSE NULL END AS clotted
    FROM `physionet-data.mimiciv_icu.chartevents` ce
    WHERE ce.itemid IN
        (
            -- MetaVision ITEMIDs
            227290 -- CRRT Mode
            , 224146 -- System Integrity
            -- 225956,  -- Reason for CRRT Filter Change
            -- above itemid is one of: Clotted, Line Changed, Procedure
            -- only ~200 rows, not super useful
            , 224149 -- Access Pressure
            , 224144 -- Blood Flow (ml/min)
            , 228004 -- Citrate (ACD-A)
            , 225183 -- Current Goal
            , 225977 -- Dialysate Fluid
            , 224154 -- Dialysate Rate
            , 224151 -- Effluent Pressure
            , 224150 -- Filter Pressure
            , 225958 -- Heparin Concentration (units/mL)
            , 224145 -- Heparin Dose (per hour)
            , 224191 -- Hourly Patient Fluid Removal
            , 228005 -- PBP (Prefilter) Replacement Rate
            , 228006 -- Post Filter Replacement Rate
            , 225976 -- Replacement Fluid
            , 224153 -- Replacement Rate
            , 224152 -- Return Pressure
            , 226457  -- Ultrafiltrate Output
        )
        AND ce.value IS NOT NULL
)

-- use MAX() to collapse to a single row
-- there is only ever 1 row for unique combinations of stay_id/charttime/itemid
SELECT stay_id
    , charttime
    , MAX(crrt_mode) AS crrt_mode
    , MAX(accesspressure) AS access_pressure
    , MAX(bloodflow) AS blood_flow
    , MAX(citrate) AS citrate
    , MAX(currentgoal) AS current_goal
    , MAX(dialysatefluid) AS dialysate_fluid
    , MAX(dialysaterate) AS dialysate_rate
    , MAX(effluentpressure) AS effluent_pressure
    , MAX(filterpressure) AS filter_pressure
    , MAX(heparinconcentration) AS heparin_concentration
    , MAX(heparindose) AS heparin_dose
    , MAX(hourlypatientfluidremoval) AS hourly_patient_fluid_removal
    , MAX(prefilterreplacementrate) AS prefilter_replacement_rate
    , MAX(postfilterreplacementrate) AS postfilter_replacement_rate
    , MAX(replacementfluid) AS replacement_fluid
    , MAX(replacementrate) AS replacement_rate
    , MAX(returnpressure) AS return_pressure
    , MAX(ultrafiltrateoutput) AS ultrafiltrate_output
    , MAX(system_active) AS system_active
    , MAX(clots) AS clots
    , MAX(clots_increasing) AS clots_increasing
    , MAX(clotted) AS clotted
FROM crrt_settings
GROUP BY stay_id, charttime
