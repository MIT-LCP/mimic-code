-- determines if patients received any dialysis during their stay

-- Some example aggregate queries which summarize the data here..
-- This query estimates 6.7% of ICU patients received RRT.
    -- select count(rrt.icustay_id) as numobs
    -- , sum(rrt) as numrrt
    -- , sum(case when rrt=1 then 1 else 0 end)*100.0 / count(rrt.icustay_id)
    -- as percent_rrt
    -- from rrt
    -- inner join icustays ie on rrt.icustay_id = ie.icustay_id
    -- inner join patients p
    -- on rrt.subject_id = p.subject_id
    -- and p.dob < ie.intime - interval '1' year
    -- inner join admissions adm
    -- on rrt.hadm_id = adm.hadm_id;

-- This query estimates that 4.6% of first ICU stays received RRT.
    -- select
    --   count(rrt.icustay_id) as numobs
    --   , sum(rrt) as numrrt
    --   , sum(case when rrt=1 then 1 else 0 end)*100.0 / count(rrt.icustay_id)
    -- as percent_rrt
    -- from
    -- (
    -- select ie.icustay_id, rrt.rrt
    --   , ROW_NUMBER() over (partition by ie.subject_id order by ie.intime) rn
    -- from rrt
    -- inner join icustays ie
    --   on rrt.icustay_id = ie.icustay_id
    -- inner join patients p
    --   on rrt.subject_id = p.subject_id
    -- and p.dob < ie.intime - interval '1' year
    -- inner join admissions adm
    --   on rrt.hadm_id = adm.hadm_id
    -- ) rrt
    -- where rn = 1;

with cv as
(
  select ie.icustay_id
    , max(
        case
          when ce.itemid in (152,148,149,146,147,151,150) and value is not null then 1
          when ce.itemid in (229,235,241,247,253,259,265,271) and value = 'Dialysis Line' then 1
          when ce.itemid = 582 and value in ('CAVH Start','CAVH D/C','CVVHD Start','CVVHD D/C','Hemodialysis st','Hemodialysis end') then 1
        else 0 end
        ) as RRT
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.chartevents` ce
    on ie.icustay_id = ce.icustay_id
    and ce.itemid in
    (
       152 -- "Dialysis Type";61449
      ,148 -- "Dialysis Access Site";60335
      ,149 -- "Dialysis Access Type";60030
      ,146 -- "Dialysate Flow ml/hr";57445
      ,147 -- "Dialysate Infusing";56605
      ,151 -- "Dialysis Site Appear";37345
      ,150 -- "Dialysis Machine";27472
      ,229 -- INV Line#1 [Type]
      ,235 -- INV Line#2 [Type]
      ,241 -- INV Line#3 [Type]
      ,247 -- INV Line#4 [Type]
      ,253 -- INV Line#5 [Type]
      ,259 -- INV Line#6 [Type]
      ,265 -- INV Line#7 [Type]
      ,271 -- INV Line#8 [Type]
      ,582 -- Procedures
    )
    and ce.value is not null
    and ce.charttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  where ie.dbsource = 'carevue'
  group by ie.icustay_id
)
, mv_ce as
(
  select ie.icustay_id
    , 1 as RRT
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.chartevents` ce
    on ie.icustay_id = ce.icustay_id
    and ce.charttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    and itemid in
    (
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
    )
    and valuenum > 0 -- also ensures it's not null
  group by ie.icustay_id
)
, mv_ie as
(
  select ie.icustay_id
    , 1 as RRT
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.inputevents_mv` tt
    on ie.icustay_id = tt.icustay_id
    and tt.starttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    and itemid in
    (
        227536 --	KCl (CRRT)	Medications	inputevents_mv	Solution
      , 227525 --	Calcium Gluconate (CRRT)	Medications	inputevents_mv	Solution
    )
    and amount > 0 -- also ensures it's not null
  group by ie.icustay_id
)
, mv_de as
(
  select ie.icustay_id
    , 1 as RRT
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  inner join `physionet-data.mimiciii_clinical.datetimeevents` tt
    on ie.icustay_id = tt.icustay_id
    and tt.charttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    and itemid in
    (
      -- TODO: unsure how to handle "Last dialysis"
      --  225128 -- | Last dialysis                                     | Adm History/FHPA        | datetimeevents     | Date time
        225318 -- | Dialysis Catheter Cap Change                      | Access Lines - Invasive | datetimeevents     | Date time
      , 225319 -- | Dialysis Catheter Change over Wire Date           | Access Lines - Invasive | datetimeevents     | Date time
      , 225321 -- | Dialysis Catheter Dressing Change                 | Access Lines - Invasive | datetimeevents     | Date time
      , 225322 -- | Dialysis Catheter Insertion Date                  | Access Lines - Invasive | datetimeevents     | Date time
      , 225324 -- | Dialysis CatheterTubing Change                    | Access Lines - Invasive | datetimeevents     | Date time
    )
  group by ie.icustay_id
)
, mv_pe as
(
    select ie.icustay_id
      , 1 as RRT
    FROM `physionet-data.mimiciii_clinical.icustays` ie
    inner join `physionet-data.mimiciii_clinical.procedureevents_mv` tt
      on ie.icustay_id = tt.icustay_id
      and tt.starttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
      and itemid in
      (
          225441 -- | Hemodialysis                                      | 4-Procedures            | procedureevents_mv | Process
        , 225802 -- | Dialysis - CRRT                                   | Dialysis                | procedureevents_mv | Process
        , 225803 -- | Dialysis - CVVHD                                  | Dialysis                | procedureevents_mv | Process
        , 225805 -- | Peritoneal Dialysis                               | Dialysis                | procedureevents_mv | Process
        , 224270 -- | Dialysis Catheter                                 | Access Lines - Invasive | procedureevents_mv | Process
        , 225809 -- | Dialysis - CVVHDF                                 | Dialysis                | procedureevents_mv | Process
        , 225955 -- | Dialysis - SCUF                                   | Dialysis                | procedureevents_mv | Process
        , 225436 -- | CRRT Filter Change               | Dialysis | procedureevents_mv | Process
      )
    group by ie.icustay_id
)
select ie.subject_id, ie.hadm_id, ie.icustay_id
  , case
      when cv.RRT = 1 then 1
      when mv_ce.RRT = 1 then 1
      when mv_ie.RRT = 1 then 1
      when mv_de.RRT = 1 then 1
      when mv_pe.RRT = 1 then 1
      else 0
    end as rrt
FROM `physionet-data.mimiciii_clinical.icustays` ie
left join cv
  on ie.icustay_id = cv.icustay_id
left join mv_ce
  on ie.icustay_id = mv_ce.icustay_id
left join mv_ie
  on ie.icustay_id = mv_ie.icustay_id
left join mv_de
  on ie.icustay_id = mv_de.icustay_id
left join mv_pe
  on ie.icustay_id = mv_pe.icustay_id
order by ie.icustay_id;
