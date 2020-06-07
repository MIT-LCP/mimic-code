-- This query provides various methods of combining the Elixhauser components into a single score
-- The methods are called "vanWalRaven" and "SID30", and "SID29"

CREATE VIEW `physionet-data.mimiciii_clinical.elixhauser_ahrq_score` AS
select subject_id, hadm_id
,  -- Below is the van Walraven score
   0 * AIDS +
   0 * ALCOHOL_ABUSE +
  -2 * BLOOD_LOSS_ANEMIA +
   7 * CONGESTIVE_HEART_FAILURE +
   -- Cardiac arrhythmias are not included in van Walraven based on Quan 2007
   3 * CHRONIC_PULMONARY +
   3 * COAGULOPATHY +
  -2 * DEFICIENCY_ANEMIAS +
  -3 * DEPRESSION +
   0 * DIABETES_COMPLICATED +
   0 * DIABETES_UNCOMPLICATED +
  -7 * DRUG_ABUSE +
   5 * FLUID_ELECTROLYTE +
   0 * HYPERTENSION +
   0 * HYPOTHYROIDISM +
   11 * LIVER_DISEASE +
   9 * LYMPHOMA +
   12 * METASTATIC_CANCER +
   6 * OTHER_NEUROLOGICAL +
  -4 * OBESITY +
   7 * PARALYSIS +
   2 * PERIPHERAL_VASCULAR +
   0 * PEPTIC_ULCER +
   0 * PSYCHOSES +
   4 * PULMONARY_CIRCULATION +
   0 * RHEUMATOID_ARTHRITIS +
   5 * RENAL_FAILURE +
   4 * SOLID_TUMOR +
  -1 * VALVULAR_DISEASE +
   6 * WEIGHT_LOSS
as elixhauser_vanwalraven



,  -- Below is the 29 component SID score
   0 * AIDS +
  -2 * ALCOHOL_ABUSE +
  -2 * BLOOD_LOSS_ANEMIA +
   -- Cardiac arrhythmias are not included in SID-29
   9 * CONGESTIVE_HEART_FAILURE +
   3 * CHRONIC_PULMONARY +
   9 * COAGULOPATHY +
   0 * DEFICIENCY_ANEMIAS +
  -4 * DEPRESSION +
   0 * DIABETES_COMPLICATED +
  -1 * DIABETES_UNCOMPLICATED +
  -8 * DRUG_ABUSE +
   9 * FLUID_ELECTROLYTE +
  -1 * HYPERTENSION +
   0 * HYPOTHYROIDISM +
   5 * LIVER_DISEASE +
   6 * LYMPHOMA +
   13 * METASTATIC_CANCER +
   4 * OTHER_NEUROLOGICAL +
  -4 * OBESITY +
   3 * PARALYSIS +
   0 * PEPTIC_ULCER +
   4 * PERIPHERAL_VASCULAR +
  -4 * PSYCHOSES +
   5 * PULMONARY_CIRCULATION +
   6 * RENAL_FAILURE +
   0 * RHEUMATOID_ARTHRITIS +
   8 * SOLID_TUMOR +
   0 * VALVULAR_DISEASE +
   8 * WEIGHT_LOSS
as elixhauser_SID29


,  -- Below is the 30 component SID score
   0 * AIDS +
   0 * ALCOHOL_ABUSE +
  -3 * BLOOD_LOSS_ANEMIA +
   8 * CARDIAC_ARRHYTHMIAS +
   9 * CONGESTIVE_HEART_FAILURE +
   3 * CHRONIC_PULMONARY +
  12 * COAGULOPATHY +
   0 * DEFICIENCY_ANEMIAS +
  -5 * DEPRESSION +
   1 * DIABETES_COMPLICATED +
   0 * DIABETES_UNCOMPLICATED +
 -11 * DRUG_ABUSE +
  11 * FLUID_ELECTROLYTE +
  -2 * HYPERTENSION +
   0 * HYPOTHYROIDISM +
   7 * LIVER_DISEASE +
   8 * LYMPHOMA +
  17 * METASTATIC_CANCER +
   5 * OTHER_NEUROLOGICAL +
  -5 * OBESITY +
   4 * PARALYSIS +
   0 * PEPTIC_ULCER +
   4 * PERIPHERAL_VASCULAR +
  -6 * PSYCHOSES +
   5 * PULMONARY_CIRCULATION +
   7 * RENAL_FAILURE +
   0 * RHEUMATOID_ARTHRITIS +
  10 * SOLID_TUMOR +
   0 * VALVULAR_DISEASE +
  10 * WEIGHT_LOSS
as elixhauser_SID30

from ELIXHAUSER_AHRQ;
