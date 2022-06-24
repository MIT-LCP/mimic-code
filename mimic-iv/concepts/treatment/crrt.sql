with crrt_settings as
(
  select ce.stay_id, ce.charttime
  , CASE WHEN ce.itemid = 227290 THEN ce.value END AS CRRT_mode
  , CASE WHEN ce.itemid = 224149 THEN ce.valuenum ELSE NULL END AS AccessPressure
  , CASE WHEN ce.itemid = 224144 THEN ce.valuenum ELSE NULL END AS BloodFlow -- (ml/min)
  , CASE WHEN ce.itemid = 228004 THEN ce.valuenum ELSE NULL END AS Citrate -- (ACD-A)
  , CASE WHEN ce.itemid = 225183 THEN ce.valuenum ELSE NULL END AS CurrentGoal
  , CASE WHEN ce.itemid = 225977 THEN ce.value ELSE NULL END AS DialysateFluid
  , CASE WHEN ce.itemid = 224154 THEN ce.valuenum ELSE NULL END AS DialysateRate
  , CASE WHEN ce.itemid = 224151 THEN ce.valuenum ELSE NULL END AS EffluentPressure
  , CASE WHEN ce.itemid = 224150 THEN ce.valuenum ELSE NULL END AS FilterPressure
  , CASE WHEN ce.itemid = 225958 THEN ce.value ELSE NULL END AS HeparinConcentration -- (units/mL)
  , CASE WHEN ce.itemid = 224145 THEN ce.valuenum ELSE NULL END AS HeparinDose -- (per hour)
  -- below may not account for drug infusion/hyperalimentation/anticoagulants infused
  , CASE WHEN ce.itemid = 224191 THEN ce.valuenum ELSE NULL END AS HourlyPatientFluidRemoval
  , CASE WHEN ce.itemid = 228005 THEN ce.valuenum ELSE NULL END AS PrefilterReplacementRate
  , CASE WHEN ce.itemid = 228006 THEN ce.valuenum ELSE NULL END AS PostFilterReplacementRate
  , CASE WHEN ce.itemid = 225976 THEN ce.value ELSE NULL END AS ReplacementFluid
  , CASE WHEN ce.itemid = 224153 THEN ce.valuenum ELSE NULL END AS ReplacementRate
  , CASE WHEN ce.itemid = 224152 THEN ce.valuenum ELSE NULL END AS ReturnPressure
  , CASE WHEN ce.itemid = 226457 THEN ce.valuenum END AS UltrafiltrateOutput
  -- separate system integrity into sub components
  -- need to do this as 224146 has multiple unique values for a single charttime
  -- e.g. "Clots Present" and "Active" at same time
  , CASE
        WHEN ce.itemid = 224146
        AND ce.value IN ('Active', 'Initiated', 'Reinitiated', 'New Filter')
            THEN 1
        WHEN ce.itemid = 224146
        AND ce.value IN ('Recirculating', 'Discontinued')
            THEN 0
    ELSE NULL END as system_active
  , CASE
        WHEN ce.itemid = 224146
        AND ce.value IN ('Clots Present', 'Clots Present')
            THEN 1
        WHEN ce.itemid = 224146
        AND ce.value IN ('No Clot Present', 'No Clot Present')
            THEN 0
    ELSE NULL END as clots
  , CASE 
        WHEN ce.itemid = 224146
        AND ce.value IN ('Clots Increasing', 'Clot Increasing')
            THEN 1
    ELSE NULL END as clots_increasing
  , CASE
        WHEN ce.itemid = 224146
        AND ce.value IN ('Clotted')
            THEN 1
    ELSE NULL END as clotted
  from `physionet-data.mimiciv_icu.chartevents` ce
  where ce.itemid in
  (
    -- MetaVision ITEMIDs
    227290, -- CRRT Mode
    224146, -- System Integrity
    -- 225956,  -- Reason for CRRT Filter Change
    -- above itemid is one of: Clotted, Line Changed, Procedure
    -- only ~200 rows, not super useful
    224149, -- Access Pressure
    224144, -- Blood Flow (ml/min)
    228004, -- Citrate (ACD-A)
    225183, -- Current Goal
    225977, -- Dialysate Fluid
    224154, -- Dialysate Rate
    224151, -- Effluent Pressure
    224150, -- Filter Pressure
    225958, -- Heparin Concentration (units/mL)
    224145, -- Heparin Dose (per hour)
    224191, -- Hourly Patient Fluid Removal
    228005, -- PBP (Prefilter) Replacement Rate
    228006, -- Post Filter Replacement Rate
    225976, -- Replacement Fluid
    224153, -- Replacement Rate
    224152, -- Return Pressure
    226457  -- Ultrafiltrate Output
  )
  and ce.value is not null
)
-- use MAX() to collapse to a single row
-- there is only ever 1 row for unique combinations of stay_id/charttime/itemid
select stay_id
, charttime
, MAX(crrt_mode) AS crrt_mode
, MAX(AccessPressure) AS access_pressure
, MAX(BloodFlow) AS blood_flow
, MAX(Citrate) AS citrate
, MAX(CurrentGoal) AS current_goal
, MAX(DialysateFluid) AS dialysate_fluid
, MAX(DialysateRate) AS dialysate_rate
, MAX(EffluentPressure) AS effluent_pressure
, MAX(FilterPressure) AS filter_pressure
, MAX(HeparinConcentration) AS heparin_concentration
, MAX(HeparinDose) AS heparin_dose
, MAX(HourlyPatientFluidRemoval) AS hourly_patient_fluid_removal
, MAX(PrefilterReplacementRate) AS prefilter_replacement_rate
, MAX(PostFilterReplacementRate) AS postfilter_replacement_rate
, MAX(ReplacementFluid) AS replacement_fluid
, MAX(ReplacementRate) AS replacement_rate
, MAX(ReturnPressure) AS return_pressure
, MAX(UltrafiltrateOutput) AS ultrafiltrate_output
, MAX(system_active) AS system_active
, MAX(clots) AS clots
, MAX(clots_increasing) AS clots_increasing
, MAX(clotted) AS clotted
from crrt_settings
group by stay_id, charttime