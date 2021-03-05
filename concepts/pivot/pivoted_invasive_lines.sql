WITH stg0 AS
(
    SELECT 
        icustay_id
        , charttime
        , storetime
        , itemid
        -- create partition which separates the lines
        , CASE
            WHEN itemid IN (229, 8392) THEN 1
            WHEN itemid IN (235, 8393) THEN 2
            WHEN itemid IN (241, 8394) THEN 3
            WHEN itemid IN (247, 8395) THEN 4
            WHEN itemid IN (253, 8396) THEN 5
            WHEN itemid IN (259, 8397) THEN 6
            WHEN itemid IN (265, 8398) THEN 7
            WHEN itemid IN (271, 8399) THEN 8
          ELSE NULL END AS line_number
        , CASE WHEN itemid < 8000 THEN value ELSE NULL END AS line_type
        , CASE WHEN itemid > 8000 THEN value ELSE NULL END AS line_site
        -- the stopped column is always present for invasive lines
        , CASE 
              WHEN ce.stopped = 'D/C\'d' THEN 1
              WHEN ce.stopped = 'NotStopd' THEN 0
          ELSE NULL END AS line_dc
    FROM `physionet-data.mimiciii_clinical.chartevents` ce
    WHERE ce.itemid IN 
    (
      229 -- INV Line#1 [Type]
    , 235 -- INV Line#2 [Type]
    , 241 -- INV Line#3 [Type]
    , 247 -- INV Line#4 [Type]
    , 253 -- INV Line#5 [Type]
    , 259 -- INV Line#6 [Type]
    , 265 -- INV Line#7 [Type]
    , 271 -- INV Line#8 [Type]
    , 8392 -- INV Line#1 [Site]
    , 8393 -- INV Line#2 [Site]
    , 8394 -- INV Line#3 [Site]
    , 8395 -- INV Line#4 [Site]
    , 8396 -- INV Line#5 [Site]
    , 8397 -- INV Line#6 [Site]
    , 8398 -- INV Line#7 [Site]
    , 8399 -- INV Line#8 [Site]
    )
    AND icustay_id IS NOT NULL
    AND COALESCE(ce.error, 0) = 0
)
, stg0_rn AS
(
    SELECT 
        icustay_id
        , charttime
        , line_number
        , line_type, line_site, line_dc
        -- only keep the last documented value
        , ROW_NUMBER() OVER (PARTITION BY icustay_id, charttime, itemid ORDER BY storetime DESC) as rn_last_stored
    FROM stg0
)
, stg1 AS
(
    SELECT 
        icustay_id
        , charttime
        , line_number
        -- collapse line type/site into a single row
        -- MAX() always collapses a single value, due to where rn_last_stored = 1
        , MAX(line_type) as line_type
        , MAX(line_site) as line_site
        -- any disconnection at this charttime turns off the line
        , MAX(line_dc) AS line_dc
    FROM stg0_rn
    WHERE rn_last_stored = 1
    GROUP BY icustay_id, charttime, line_number
)
, stg2 AS
(
    SELECT 
        icustay_id
        , charttime
        , line_number
        , line_type, line_site
        , line_dc
        -- carry forward the line type
        , CASE
            -- if the previous line was D/C'd then it's a new line
            WHEN LAG(line_dc) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime) = 1 THEN 1
            -- if it's the same line as before, within 16 hours, continue the event
            WHEN LAG(line_type) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime) = line_type
            AND DATETIME_DIFF(
                charttime,
                LAG(charttime) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime),
                HOUR
                ) < 16 THEN 0
            -- otherwise, it's been more than 16 hours since the line was last documented
            -- (or it's the first documentation of this line)
            -- so we consider this a new event
            ELSE 1
        END AS rn_part
    FROM stg1
)
-- rn_part is 1 if it's a new event, and 0 if it's a continuation of the previous
-- so cumulatively summing it will result in a sequential integer which partitions
-- distinct line events. we can later group on this integer.
, stg3 AS
(
    SELECT
        icustay_id, charttime, line_number
        , line_type, line_site
        , line_dc
        , SUM(rn_part) OVER (PARTITION BY icustay_id, line_number ORDER BY charttime) as line_event
    FROM stg2
)
-- group by line_event to determine line start/stop times
, stg4 AS
(
    SELECT
        icustay_id, line_number
        , line_event
        , line_type, line_site
        , MIN(charttime) as starttime
        , MAX(charttime) as endtime
    FROM stg3
    -- filter out the D/C'd rows so they don't impact the starttime of future events
    WHERE line_dc = 0 
    GROUP BY icustay_id, line_number, line_event, line_type, line_site
)
-- metavision
, mv AS
(
    SELECT 
        icustay_id
        -- since metavision separates lines using itemid, we can use it as the line number
        , mv.itemid AS line_number
        , di.label AS line_type
        , mv.location AS line_site
        , starttime, endtime
    FROM `physionet-data.mimiciii_clinical.procedureevents_mv` mv
    INNER JOIN `physionet-data.mimiciii_clinical.d_items` di
      ON mv.itemid = di.itemid
    WHERE mv.itemid IN
    (
      227719 -- AVA Line
    , 225752 -- Arterial Line
    , 224269 -- CCO PAC
    , 224267 -- Cordis/Introducer
    , 224270 -- Dialysis Catheter
    , 224272 -- IABP line
    , 226124 -- ICP Catheter
    , 228169 -- Impella Line
    , 225202 -- Indwelling Port (PortaCath)
    , 228286 -- Intraosseous Device
    , 225204 -- Midline
    , 224263 -- Multi Lumen
    , 224560 -- PA Catheter
    , 224264 -- PICC Line
    , 225203 -- Pheresis Catheter
    , 224273 -- Presep Catheter
    , 225789 -- Sheath
    , 225761 -- Sheath Insertion
    , 228201 -- Tandem Heart Access Line
    , 228202 -- Tandem Heart Return Line
    , 224268 -- Trauma line
    , 225199 -- Triple Introducer
    , 225315 -- Tunneled (Hickman) Line
    , 225205 -- RIC
    )
    AND icustay_id IS NOT NULL
    AND statusdescription != 'Rewritten'
),
combined AS
(
    select 
        icustay_id
        , line_type, line_site
        , starttime
        , endtime
    FROM stg4
    UNION DISTINCT
    select 
        icustay_id
        , line_type, line_site
        , starttime
        , endtime
    FROM mv
)
-- as a final step, combine any similar terms together
-- this was comprehensive as of MIMIC-III v1.4
select 
    icustay_id
    , CASE
        WHEN line_type IN ('Arterial Line', 'A-Line') THEN 'Arterial'
        WHEN line_type IN ('CCO PA Line', 'CCO PAC') THEN 'Continuous Cardiac Output PA'
        WHEN line_type IN ('Dialysis Catheter', 'Dialysis Line') THEN 'Dialysis'
        WHEN line_type IN ('Hickman', 'Tunneled (Hickman) Line') THEN 'Hickman'
        WHEN line_type IN ('IABP', 'IABP line') THEN 'IABP'
        WHEN line_type IN ('Multi Lumen', 'Multi-lumen') THEN 'Multi Lumen'
        WHEN line_type IN ('PA Catheter', 'PA line') THEN 'PA'
        WHEN line_type IN ('PICC Line', 'PICC line') THEN 'PICC'
        WHEN line_type IN ('Pre-Sep Catheter', 'Presep Catheter') THEN 'Pre-Sep'
        WHEN line_type IN ('Trauma Line', 'Trauma line') THEN 'Trauma'
        WHEN line_type IN ('Triple Introducer', 'TripleIntroducer') THEN 'Triple Introducer'
        WHEN line_type IN ('Portacath', 'Indwelling Port (PortaCath)') THEN 'Portacath'
        -- AVA Line
        -- Camino Bolt
        -- Cordis/Introducer
        -- ICP Catheter
        -- Impella Line
        -- Intraosseous Device
        -- Introducer
        -- Lumbar Drain
        -- Midline
        -- Other/Remarks
        -- PacerIntroducer
        -- PermaCath
        -- Pheresis Catheter
        -- RIC
        -- Sheath
        -- Tandem Heart Access Line
        -- Tandem Heart Return Line
        -- Venous Access
        -- Ventriculostomy
    ELSE line_type END AS line_type
    , CASE
        WHEN line_site IN ('Left Antecub', 'Left Antecube') THEN 'Left Antecube'
        WHEN line_site IN ('Left Axilla', 'Left Axilla.') THEN 'Left Axilla'
        WHEN line_site IN ('Left Brachial', 'Left Brachial.') THEN 'Left Brachial'
        WHEN line_site IN ('Left Femoral', 'Left Femoral.') THEN 'Left Femoral'
        WHEN line_site IN ('Right Antecub', 'Right Antecube') THEN 'Right Antecube' 
        WHEN line_site IN ('Right Axilla', 'Right Axilla.') THEN 'Right Axilla' 
        WHEN line_site IN ('Right Brachial', 'Right Brachial.') THEN 'Right Brachial' 
        WHEN line_site IN ('Right Femoral', 'Right Femoral.') THEN 'Right Femoral' 
        -- 'Left Foot'
        -- 'Left IJ'
        -- 'Left Radial'
        -- 'Left Subclavian'
        -- 'Left Ulnar'
        -- 'Left Upper Arm'
        -- 'Right Foot'
        -- 'Right IJ'
        -- 'Right Radial'
        -- 'Right Side Head'
        -- 'Right Subclavian'
        -- 'Right Ulnar'
        -- 'Right Upper Arm'
        -- 'Transthoracic'
        -- 'Other/Remarks'
    ELSE line_site END AS line_site
    , starttime
    , endtime
FROM combined
ORDER BY icustay_id, starttime, line_type, line_site;