-- Creates a table with stay_id / time / dialysis type (if present)

WITH ce AS (
    SELECT ce.stay_id
        , ce.charttime
        -- when ce.itemid in (152,148,149,146,147,151,150)
        -- and value is not null then 1
        -- when ce.itemid in (229,235,241,247,253,259,265,271)
        -- and value = 'Dialysis Line' then 1
        -- when ce.itemid = 466 and value = 'Dialysis RN' then 1
        -- when ce.itemid = 927 and value = 'Dialysis Solutions' then 1
        -- when ce.itemid = 6250 and value = 'dialys' then 1
        -- when ce.
        -- when ce.itemid = 582 and value in ('CAVH Start','CAVH D/C',
        -- 'CVVHD Start','CVVHD D/C',
        -- 'Hemodialysis st','Hemodialysis end') then 1
        , CASE
        -- metavision itemids

            -- checkboxes
            WHEN ce.itemid IN
                (
                    226118 -- | Dialysis Catheter placed in outside facility
                    , 227357 -- | Dialysis Catheter Dressing Occlusive
                    , 225725 -- | Dialysis Catheter Tip Cultured
                ) THEN 1
            -- numeric data
            WHEN ce.itemid IN
                (
                    -- | Hemodialysis Output 
                    226499
                    -- | Dialysate Rate
                    , 224154
                    -- | Dwell Time (Peritoneal Dialysis)
                    , 225810
                    -- | Medication Added Amount  #1 (Peritoneal Dialysis)
                    , 225959
                    -- | Medication Added Amount  #2 (Peritoneal Dialysis)
                    , 227639
                    , 225183 -- | Current Goal
                    , 227438 -- | Volume not removed
                    , 224191 -- | Hourly Patient Fluid Removal
                    , 225806 -- | Volume In (PD)
                    , 225807 -- | Volume Out (PD)
                    , 228004 -- | Citrate (ACD-A)
                    , 228005 -- | PBP (Prefilter) Replacement Rate
                    , 228006 -- | Post Filter Replacement Rate
                    , 224144 -- | Blood Flow (ml/min)
                    , 224145 -- | Heparin Dose (per hour)
                    , 224149 -- | Access Pressure
                    , 224150 -- | Filter Pressure
                    , 224151 -- | Effluent Pressure
                    , 224152 -- | Return Pressure
                    , 224153 -- | Replacement Rate
                    , 224404 -- | ART Lumen Volume
                    , 224406 -- | VEN Lumen Volume
                    , 226457 -- | Ultrafiltrate Output
                ) THEN 1

            -- text fields
            WHEN ce.itemid IN
                (
                    224135 -- | Dialysis Access Site
                    , 224139 -- | Dialysis Site Appearance
                    , 224146 -- | System Integrity
                    -- | Dialysis Catheter Site Appear
                    , 225323
                    -- | Dialysis Catheter Discontinued
                    , 225740
                    -- | Dialysis Catheter Dressing Type
                    , 225776
                    -- | Peritoneal Dialysis Fluid Appearance
                    , 225951
                    -- | Medication Added #1 (Peritoneal Dialysis)
                    , 225952
                    , 225953 -- | Solution (Peritoneal Dialysis)
                    , 225954 -- | Dialysis Access Type
                    , 225956 -- | Reason for CRRT Filter Change
                    , 225958 -- | Heparin Concentration (units/mL)
                    -- | Medication Added Units #1 (Peritoneal Dialysis)
                    , 225961
                    , 225963 -- | Peritoneal Dialysis Catheter Type
                    , 225965 -- | Peritoneal Dialysis Catheter Status
                    , 225976 -- | Replacement Fluid
                    , 225977 -- | Dialysate Fluid
                    -- | Dialysis Catheter Type | Access Lines - Invasive
                    , 227124
                    , 227290 -- | CRRT mode
                    -- | Medication Added #2 (Peritoneal Dialysis)
                    , 227638
                    -- | Medication Added Units #2 (Peritoneal Dialysis)
                    , 227640
                    -- | Dialysis Catheter Placement Confirmed by X-ray
                    , 227753
                ) THEN 1
            ELSE 0 END
        AS dialysis_present
        , CASE
            WHEN ce.itemid = 225965 -- Peritoneal Dialysis Catheter Status
                 AND value = 'In use' THEN 1
            WHEN ce.itemid IN
                (
                    226499 -- | Hemodialysis Output
                    , 224154 -- | Dialysate Rate
                    , 225183 -- | Current Goal
                    , 227438 -- | Volume not removed
                    , 224191 -- | Hourly Patient Fluid Removal
                    , 225806 -- | Volume In (PD)
                    , 225807 -- | Volume Out (PD)
                    , 228004 -- | Citrate (ACD-A)
                    , 228005 -- | PBP (Prefilter) Replacement Rat
                    , 228006 -- | Post Filter Replacement Rate
                    , 224144 -- | Blood Flow (ml/min)
                    , 224145 -- | Heparin Dose (per hour)
                    , 224153 -- | Replacement Rate
                    , 226457 -- | Ultrafiltrate Output
                ) THEN 1
            ELSE 0 END
        AS dialysis_active
        , CASE
            -- dialysis mode
            -- we try to set dialysis mode to one of:
            --   CVVH
            --   CVVHD
            --   CVVHDF
            --   SCUF
            --   Peritoneal
            --   IHD
            -- these are the modes in itemid 227290
            WHEN ce.itemid = 227290 THEN value
            -- itemids which imply a certain dialysis mode
            -- peritoneal dialysis
            WHEN ce.itemid IN
                (
                    225810 -- | Dwell Time (Peritoneal Dialysis)
                    , 225806 -- | Volume In (PD)
                    , 225807 -- | Volume Out (PD)
                    -- | Dwell Time (Peritoneal Dialysis)
                    , 225810
                    -- | Medication Added Amount  #2 (Peritoneal Dialysis)
                    , 227639
                    -- | Medication Added Amount  #1 (Peritoneal Dialysis)
                    , 225959
                    -- | Peritoneal Dialysis Fluid Appearance
                    , 225951
                    -- | Medication Added #1 (Peritoneal Dialysis)
                    , 225952
                    -- | Medication Added Units #1 (Peritoneal Dialysis)
                    , 225961
                    , 225953 -- | Solution (Peritoneal Dialysis)
                    , 225963 -- | Peritoneal Dialysis Catheter Type
                    , 225965 -- | Peritoneal Dialysis Catheter Status
                    -- | Medication Added #2 (Peritoneal Dialysis)
                    , 227638
                    -- | Medication Added Units #2 (Peritoneal Dialysis)
                    , 227640
                )
                THEN 'Peritoneal'
            WHEN ce.itemid = 226499
                 THEN 'IHD'
            ELSE NULL END AS dialysis_type
    FROM `physionet-data.mimiciv_icu.chartevents` ce
    WHERE ce.itemid IN
        (
            -- === MetaVision itemids === --
            -- Checkboxes
            226118 -- | Dialysis Catheter placed in outside facility
            , 227357 -- | Dialysis Catheter Dressing Occlusive
            , 225725 -- | Dialysis Catheter Tip Cultured

            -- Numeric values
            , 226499 -- | Hemodialysis Output
            , 224154 -- | Dialysate Rate
            , 225810 -- | Dwell Time (Peritoneal Dialysis)
            , 227639 -- | Medication Added Amount  #2 (Peritoneal Dialysis)
            , 225183 -- | Current Goal
            , 227438 -- | Volume not removed
            , 224191 -- | Hourly Patient Fluid Removal
            , 225806 -- | Volume In (PD)
            , 225807 -- | Volume Out (PD)
            , 228004 -- | Citrate (ACD-A)
            , 228005 -- | PBP (Prefilter) Replacement Rate
            , 228006 -- | Post Filter Replacement Rate
            , 224144 -- | Blood Flow (ml/min)
            , 224145 -- | Heparin Dose (per hour)
            , 224149 -- | Access Pressure
            , 224150 -- | Filter Pressure
            , 224151 -- | Effluent Pressure
            , 224152 -- | Return Pressure
            , 224153 -- | Replacement Rate
            , 224404 -- | ART Lumen Volume
            , 224406 -- | VEN Lumen Volume
            , 226457 -- | Ultrafiltrate Output
            , 225959 -- | Medication Added Amount  #1 (Peritoneal Dialysis)
            -- Text values
            , 224135 -- | Dialysis Access Site
            -- | Dialysis Site Appearance
            , 224139
            , 224146 -- | System Integrity
            , 225323 -- | Dialysis Catheter Site Appear
            , 225740 -- | Dialysis Catheter Discontinued
            , 225776 -- | Dialysis Catheter Dressing Type
            , 225951 -- | Peritoneal Dialysis Fluid Appearance
            , 225952 -- | Medication Added #1 (Peritoneal Dialysis)
            -- | Solution (Peritoneal Dialysis)
            , 225953
            , 225954 -- | Dialysis Access Type
            -- | Reason for CRRT Filter Change
            , 225956
            -- | Heparin Concentration (units/mL)
            , 225958
            , 225961 -- | Medication Added Units #1 (Peritoneal Dialysis)
            -- | Peritoneal Dialysis Catheter Type
            , 225963
            -- | Peritoneal Dialysis Catheter Status
            , 225965
            , 225976 -- | Replacement Fluid
            , 225977 -- | Dialysate Fluid
            , 227124 -- | Dialysis Catheter Type
            , 227290 -- | CRRT mode
            , 227638 -- | Medication Added #2 (Peritoneal Dialysis)
            , 227640 -- | Medication Added Units #2 (Peritoneal Dialysis)
            , 227753 -- | Dialysis Catheter Placement Confirmed by X-ray
        )
        AND ce.value IS NOT NULL
)

-- TODO:
--   charttime + dialysis_present + dialysis_active
--  for inputevents_cv, outputevents
--  for procedures_mv, left join and set the dialysis_type
-- , oe AS (
--     SELECT stay_id
--         , charttime
--         , 1 AS dialysis_present
--         , 0 AS dialysis_active
--         , NULL AS dialysis_type
--     FROM `physionet-data.mimiciv_icu.outputevents`
--     WHERE itemid IN
--         (
--             40386 -- hemodialysis
--         )
--         AND value > 0 -- also ensures it's not null
-- )

, mv_ranges AS (
    SELECT stay_id
        , starttime, endtime
        , 1 AS dialysis_present
        , 1 AS dialysis_active
        , 'CRRT' AS dialysis_type
    FROM `physionet-data.mimiciv_icu.inputevents`
    WHERE itemid IN
        (
            227536 --	KCl (CRRT)	Medications	inputevents_mv	Solution
            --	Calcium Gluconate (CRRT)	Medications	inputevents_mv	Solution
            , 227525
        )
        AND amount > 0 -- also ensures it's not null
    UNION DISTINCT
    SELECT stay_id
        , starttime, endtime
        , 1 AS dialysis_present
        , CASE
            WHEN itemid NOT IN (224270, 225436) THEN 1 ELSE 0
        END AS dialysis_active
        , CASE
            WHEN itemid = 225441 THEN 'IHD'
            -- CVVH (Continuous venovenous hemofiltration)
            WHEN itemid = 225802 THEN 'CRRT'
            -- CVVHD (Continuous venovenous hemodialysis)
            WHEN itemid = 225803 THEN 'CVVHD'
            WHEN itemid = 225805 THEN 'Peritoneal'
            -- CVVHDF (Continuous venovenous hemodiafiltration)
            WHEN itemid = 225809 THEN 'CVVHDF'
            -- SCUF (Slow continuous ultra filtration)
            WHEN itemid = 225955 THEN 'SCUF'
            ELSE NULL END AS dialysis_type
    FROM `physionet-data.mimiciv_icu.procedureevents`
    WHERE itemid IN
        (
            225441 -- | Hemodialysis
            , 225802 -- | Dialysis - CRRT
            , 225803 -- | Dialysis - CVVHD
            , 225805 -- | Peritoneal Dialysis
            , 224270 -- | Dialysis Catheter
            , 225809 -- | Dialysis - CVVHDF
            , 225955 -- | Dialysis - SCUF
            , 225436 -- | CRRT Filter Change
        )
        AND value IS NOT NULL
)

-- union together the charttime tables;
-- append times from mv_ranges to guarantee they exist
, stg0 AS (
    SELECT
        stay_id, charttime, dialysis_present, dialysis_active, dialysis_type
    FROM ce
    WHERE dialysis_present = 1
    UNION DISTINCT
    --   SELECT
    --     stay_id, charttime, dialysis_present, dialysis_active, dialysis_type
    --   FROM oe
    --   WHERE dialysis_present = 1
    --   UNION DISTINCT
    SELECT
        stay_id
        , starttime AS charttime
        , dialysis_present
        , dialysis_active
        , dialysis_type
    FROM mv_ranges
)

SELECT
    stg0.stay_id
    , charttime
    , COALESCE(mv.dialysis_present, stg0.dialysis_present) AS dialysis_present
    , COALESCE(mv.dialysis_active, stg0.dialysis_active) AS dialysis_active
    , COALESCE(mv.dialysis_type, stg0.dialysis_type) AS dialysis_type
FROM stg0
LEFT JOIN mv_ranges mv
    ON stg0.stay_id = mv.stay_id
        AND stg0.charttime >= mv.starttime
        AND stg0.charttime <= mv.endtime
;
