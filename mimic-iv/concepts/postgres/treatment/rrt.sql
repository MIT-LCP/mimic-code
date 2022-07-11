-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS rrt; CREATE TABLE rrt AS 
-- Creates a table with stay_id / time / dialysis type (if present)

with ce as
(
  select ce.stay_id
    , ce.charttime
          -- when ce.itemid in (152,148,149,146,147,151,150) and value is not null then 1
          -- when ce.itemid in (229,235,241,247,253,259,265,271) and value = 'Dialysis Line' then 1
          -- when ce.itemid = 466 and value = 'Dialysis RN' then 1
          -- when ce.itemid = 927 and value = 'Dialysis Solutions' then 1
          -- when ce.itemid = 6250 and value = 'dialys' then 1
          -- when ce.
          -- when ce.itemid = 582 and value in ('CAVH Start','CAVH D/C','CVVHD Start','CVVHD D/C','Hemodialysis st','Hemodialysis end') then 1
    , CASE
        -- metavision itemids

        -- checkboxes
        WHEN ce.itemid IN
        (
            226118 -- | Dialysis Catheter placed in outside facility      | Access Lines - Invasive | chartevents        | Checkbox
          , 227357 -- | Dialysis Catheter Dressing Occlusive              | Access Lines - Invasive | chartevents        | Checkbox
          , 225725 -- | Dialysis Catheter Tip Cultured                    | Access Lines - Invasive | chartevents        | Checkbox
        ) THEN 1
        -- numeric data
        WHEN ce.itemid IN
        (
            226499 -- | Hemodialysis Output                               | Dialysis
          , 224154 -- | Dialysate Rate                                    | Dialysis
          , 225810 -- | Dwell Time (Peritoneal Dialysis)                  | Dialysis
          , 225959 -- | Medication Added Amount  #1 (Peritoneal Dialysis) | Dialysis
          , 227639 -- | Medication Added Amount  #2 (Peritoneal Dialysis) | Dialysis
          , 225183 -- | Current Goal                     | Dialysis
          , 227438 -- | Volume not removed               | Dialysis
          , 224191 -- | Hourly Patient Fluid Removal     | Dialysis
          , 225806 -- | Volume In (PD)                   | Dialysis
          , 225807 -- | Volume Out (PD)                  | Dialysis
          , 228004 -- | Citrate (ACD-A)                  | Dialysis
          , 228005 -- | PBP (Prefilter) Replacement Rate | Dialysis
          , 228006 -- | Post Filter Replacement Rate     | Dialysis
          , 224144 -- | Blood Flow (ml/min)              | Dialysis
          , 224145 -- | Heparin Dose (per hour)          | Dialysis
          , 224149 -- | Access Pressure                  | Dialysis
          , 224150 -- | Filter Pressure                  | Dialysis
          , 224151 -- | Effluent Pressure                | Dialysis
          , 224152 -- | Return Pressure                  | Dialysis
          , 224153 -- | Replacement Rate                 | Dialysis
          , 224404 -- | ART Lumen Volume                 | Dialysis
          , 224406 -- | VEN Lumen Volume                 | Dialysis
          , 226457 -- | Ultrafiltrate Output             | Dialysis
        ) THEN 1

        -- text fields
        WHEN ce.itemid IN
        (
            224135 -- | Dialysis Access Site | Dialysis
          , 224139 -- | Dialysis Site Appearance | Dialysis
          , 224146 -- | System Integrity | Dialysis
          , 225323 -- | Dialysis Catheter Site Appear | Access Lines - Invasive
          , 225740 -- | Dialysis Catheter Discontinued | Access Lines - Invasive
          , 225776 -- | Dialysis Catheter Dressing Type | Access Lines - Invasive
          , 225951 -- | Peritoneal Dialysis Fluid Appearance | Dialysis
          , 225952 -- | Medication Added #1 (Peritoneal Dialysis) | Dialysis
          , 225953 -- | Solution (Peritoneal Dialysis) | Dialysis
          , 225954 -- | Dialysis Access Type | Dialysis
          , 225956 -- | Reason for CRRT Filter Change | Dialysis
          , 225958 -- | Heparin Concentration (units/mL) | Dialysis
          , 225961 -- | Medication Added Units #1 (Peritoneal Dialysis) | Dialysis
          , 225963 -- | Peritoneal Dialysis Catheter Type | Dialysis
          , 225965 -- | Peritoneal Dialysis Catheter Status | Dialysis
          , 225976 -- | Replacement Fluid | Dialysis
          , 225977 -- | Dialysate Fluid | Dialysis
          , 227124 -- | Dialysis Catheter Type | Access Lines - Invasive
          , 227290 -- | CRRT mode | Dialysis
          , 227638 -- | Medication Added #2 (Peritoneal Dialysis) | Dialysis
          , 227640 -- | Medication Added Units #2 (Peritoneal Dialysis) | Dialysis
          , 227753 -- | Dialysis Catheter Placement Confirmed by X-ray | Access Lines - Invasive
        ) THEN 1
      ELSE 0 END
      AS dialysis_present
    , CASE
        WHEN ce.itemid = 225965 -- Peritoneal Dialysis Catheter Status
          AND value = 'In use' THEN 1
        WHEN ce.itemid IN
        (
            226499 -- | Hemodialysis Output              | Dialysis
          , 224154 -- | Dialysate Rate                   | Dialysis
          , 225183 -- | Current Goal                     | Dialysis
          , 227438 -- | Volume not removed               | Dialysis
          , 224191 -- | Hourly Patient Fluid Removal     | Dialysis
          , 225806 -- | Volume In (PD)                   | Dialysis
          , 225807 -- | Volume Out (PD)                  | Dialysis
          , 228004 -- | Citrate (ACD-A)                  | Dialysis
          , 228005 -- | PBP (Prefilter) Replacement Rate | Dialysis
          , 228006 -- | Post Filter Replacement Rate     | Dialysis
          , 224144 -- | Blood Flow (ml/min)              | Dialysis
          , 224145 -- | Heparin Dose (per hour)          | Dialysis
          , 224153 -- | Replacement Rate                 | Dialysis
          , 226457 -- | Ultrafiltrate Output             | Dialysis
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
            225810 -- | Dwell Time (Peritoneal Dialysis) | Dialysis
          , 225806 -- | Volume In (PD)                   | Dialysis
          , 225807 -- | Volume Out (PD)                  | Dialysis
          , 225810 -- | Dwell Time (Peritoneal Dialysis)                  | Dialysis
          , 227639 -- | Medication Added Amount  #2 (Peritoneal Dialysis) | Dialysis
          , 225959 -- | Medication Added Amount  #1 (Peritoneal Dialysis) | Dialysis
          , 225951 -- | Peritoneal Dialysis Fluid Appearance | Dialysis
          , 225952 -- | Medication Added #1 (Peritoneal Dialysis) | Dialysis
          , 225961 -- | Medication Added Units #1 (Peritoneal Dialysis) | Dialysis
          , 225953 -- | Solution (Peritoneal Dialysis) | Dialysis
          , 225963 -- | Peritoneal Dialysis Catheter Type | Dialysis
          , 225965 -- | Peritoneal Dialysis Catheter Status | Dialysis
          , 227638 -- | Medication Added #2 (Peritoneal Dialysis) | Dialysis
          , 227640 -- | Medication Added Units #2 (Peritoneal Dialysis) | Dialysis
        )
          THEN 'Peritoneal'
        WHEN ce.itemid = 226499
          THEN 'IHD'
      ELSE NULL END as dialysis_type
  from mimiciv_icu.chartevents ce
  WHERE ce.itemid in
  (
    -- === MetaVision itemids === --
  
    -- Checkboxes
      226118 -- | Dialysis Catheter placed in outside facility      | Access Lines - Invasive | chartevents        | Checkbox
    , 227357 -- | Dialysis Catheter Dressing Occlusive              | Access Lines - Invasive | chartevents        | Checkbox
    , 225725 -- | Dialysis Catheter Tip Cultured                    | Access Lines - Invasive | chartevents        | Checkbox

    -- Numeric values
    , 226499 -- | Hemodialysis Output                               | Dialysis                | chartevents        | Numeric
    , 224154 -- | Dialysate Rate                                    | Dialysis                | chartevents        | Numeric
    , 225810 -- | Dwell Time (Peritoneal Dialysis)                  | Dialysis                | chartevents        | Numeric
    , 227639 -- | Medication Added Amount  #2 (Peritoneal Dialysis) | Dialysis                | chartevents        | Numeric
    , 225183 -- | Current Goal                     | Dialysis | chartevents        | Numeric
    , 227438 -- | Volume not removed               | Dialysis | chartevents        | Numeric
    , 224191 -- | Hourly Patient Fluid Removal     | Dialysis | chartevents        | Numeric
    , 225806 -- | Volume In (PD)                   | Dialysis | chartevents        | Numeric
    , 225807 -- | Volume Out (PD)                  | Dialysis | chartevents        | Numeric
    , 228004 -- | Citrate (ACD-A)                  | Dialysis | chartevents        | Numeric
    , 228005 -- | PBP (Prefilter) Replacement Rate | Dialysis | chartevents        | Numeric
    , 228006 -- | Post Filter Replacement Rate     | Dialysis | chartevents        | Numeric
    , 224144 -- | Blood Flow (ml/min)              | Dialysis | chartevents        | Numeric
    , 224145 -- | Heparin Dose (per hour)          | Dialysis | chartevents        | Numeric
    , 224149 -- | Access Pressure                  | Dialysis | chartevents        | Numeric
    , 224150 -- | Filter Pressure                  | Dialysis | chartevents        | Numeric
    , 224151 -- | Effluent Pressure                | Dialysis | chartevents        | Numeric
    , 224152 -- | Return Pressure                  | Dialysis | chartevents        | Numeric
    , 224153 -- | Replacement Rate                 | Dialysis | chartevents        | Numeric
    , 224404 -- | ART Lumen Volume                 | Dialysis | chartevents        | Numeric
    , 224406 -- | VEN Lumen Volume                 | Dialysis | chartevents        | Numeric
    , 226457 -- | Ultrafiltrate Output             | Dialysis | chartevents        | Numeric
    , 225959 -- | Medication Added Amount  #1 (Peritoneal Dialysis) | Dialysis | chartevents | Numeric
    -- Text values
    , 224135 -- | Dialysis Access Site | Dialysis | chartevents | Text
    , 224139 -- | Dialysis Site Appearance | Dialysis | chartevents | Text
    , 224146 -- | System Integrity | Dialysis | chartevents | Text
    , 225323 -- | Dialysis Catheter Site Appear | Access Lines - Invasive | chartevents | Text
    , 225740 -- | Dialysis Catheter Discontinued | Access Lines - Invasive | chartevents | Text
    , 225776 -- | Dialysis Catheter Dressing Type | Access Lines - Invasive | chartevents | Text
    , 225951 -- | Peritoneal Dialysis Fluid Appearance | Dialysis | chartevents | Text
    , 225952 -- | Medication Added #1 (Peritoneal Dialysis) | Dialysis | chartevents | Text
    , 225953 -- | Solution (Peritoneal Dialysis) | Dialysis | chartevents | Text
    , 225954 -- | Dialysis Access Type | Dialysis | chartevents | Text
    , 225956 -- | Reason for CRRT Filter Change | Dialysis | chartevents | Text
    , 225958 -- | Heparin Concentration (units/mL) | Dialysis | chartevents | Text
    , 225961 -- | Medication Added Units #1 (Peritoneal Dialysis) | Dialysis | chartevents | Text
    , 225963 -- | Peritoneal Dialysis Catheter Type | Dialysis | chartevents | Text
    , 225965 -- | Peritoneal Dialysis Catheter Status | Dialysis | chartevents | Text
    , 225976 -- | Replacement Fluid | Dialysis | chartevents | Text
    , 225977 -- | Dialysate Fluid | Dialysis | chartevents | Text
    , 227124 -- | Dialysis Catheter Type | Access Lines - Invasive | chartevents | Text
    , 227290 -- | CRRT mode | Dialysis | chartevents | Text
    , 227638 -- | Medication Added #2 (Peritoneal Dialysis) | Dialysis | chartevents | Text
    , 227640 -- | Medication Added Units #2 (Peritoneal Dialysis) | Dialysis | chartevents | Text
    , 227753 -- | Dialysis Catheter Placement Confirmed by X-ray | Access Lines - Invasive | chartevents | Text
  )
  AND ce.value IS NOT NULL
)
-- TODO:
--   charttime + dialysis_present + dialysis_active
--  for inputevents_cv, outputevents
--  for procedures_mv, left join and set the dialysis_type
, oe as
(
 select stay_id
    , charttime
    , 1 AS dialysis_present
    , 0 AS dialysis_active
    , NULL AS dialysis_type
 from mimiciv_icu.outputevents
 where itemid in
 (
       40386 -- hemodialysis
 )
 and value > 0 -- also ensures it's not null
)
, mv_ranges as
(
  select stay_id
    , starttime, endtime
    , 1 AS dialysis_present
    , 1 AS dialysis_active
    , 'CRRT' as dialysis_type
  from mimiciv_icu.inputevents
  where itemid in
  (
      227536 --	KCl (CRRT)	Medications	inputevents_mv	Solution
    , 227525 --	Calcium Gluconate (CRRT)	Medications	inputevents_mv	Solution
  )
  and amount > 0 -- also ensures it's not null
  UNION DISTINCT
  select stay_id
    , starttime, endtime
    , 1 AS dialysis_present
    , CASE WHEN itemid NOT IN (224270, 225436) THEN 1 ELSE 0 END AS dialysis_active
    , CASE
        WHEN itemid = 225441 THEN 'IHD'
        WHEN itemid = 225802 THEN 'CRRT'  -- CVVH (Continuous venovenous hemofiltration)
        WHEN itemid = 225803 THEN 'CVVHD' -- CVVHD (Continuous venovenous hemodialysis)
        WHEN itemid = 225805 THEN 'Peritoneal'
        WHEN itemid = 225809 THEN 'CVVHDF' -- CVVHDF (Continuous venovenous hemodiafiltration)
        WHEN itemid = 225955 THEN 'SCUF' -- SCUF (Slow continuous ultra filtration)
      ELSE NULL END as dialysis_type
  from mimiciv_icu.procedureevents
  where itemid in
  (
      225441 -- | Hemodialysis          | 4-Procedures              | procedureevents_mv | Process
    , 225802 -- | Dialysis - CRRT       | Dialysis                  | procedureevents_mv | Process
    , 225803 -- | Dialysis - CVVHD      | Dialysis                  | procedureevents_mv | Process
    , 225805 -- | Peritoneal Dialysis   | Dialysis                  | procedureevents_mv | Process
    , 224270 -- | Dialysis Catheter     | Access Lines - Invasive   | procedureevents_mv | Process
    , 225809 -- | Dialysis - CVVHDF     | Dialysis                  | procedureevents_mv | Process
    , 225955 -- | Dialysis - SCUF       | Dialysis                  | procedureevents_mv | Process
    , 225436 -- | CRRT Filter Change    | Dialysis                  | procedureevents_mv | Process
  )
  AND value IS NOT NULL
)
-- union together the charttime tables; append times from mv_ranges to guarantee they exist
, stg0 AS
(
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
    stay_id, starttime AS charttime, dialysis_present, dialysis_active, dialysis_type
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