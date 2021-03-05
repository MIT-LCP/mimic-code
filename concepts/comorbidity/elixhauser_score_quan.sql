-- This query provides various methods of combining the Elixhauser components into a single score
-- The methods are called "vanWalRaven" and "SID30", and "SID29"

select hadm_id
,  -- Below is the van Walraven score
   0 * aids +
   0 * alcohol_abuse +
  -2 * blood_loss_anemia +
   7 * congestive_heart_failure +
   -- Cardiac arrhythmias are not included in van Walraven based on Quan 2007
   3 * chronic_pulmonary +
   3 * coagulopathy +
  -2 * deficiency_anemias +
  -3 * depression +
   0 * diabetes_complicated +
   0 * diabetes_uncomplicated +
  -7 * drug_abuse +
   5 * fluid_electrolyte +
   0 * hypertension +
   0 * hypothyroidism +
   11 * liver_disease +
   9 * lymphoma +
   12 * metastatic_cancer +
   6 * other_neurological +
  -4 * obesity +
   7 * paralysis +
   2 * peripheral_vascular +
   0 * peptic_ulcer +
   0 * psychoses +
   4 * pulmonary_circulation +
   0 * rheumatoid_arthritis +
   5 * renal_failure +
   4 * solid_tumor +
  -1 * valvular_disease +
   6 * weight_loss
as elixhauser_vanwalraven



,  -- Below is the 29 component SID score
   0 * aids +
  -2 * alcohol_abuse +
  -2 * blood_loss_anemia +
   -- Cardiac arrhythmias are not included in SID-29
   9 * congestive_heart_failure +
   3 * chronic_pulmonary +
   9 * coagulopathy +
   0 * deficiency_anemias +
  -4 * depression +
   0 * diabetes_complicated +
  -1 * diabetes_uncomplicated +
  -8 * drug_abuse +
   9 * fluid_electrolyte +
  -1 * hypertension +
   0 * hypothyroidism +
   5 * liver_disease +
   6 * lymphoma +
   13 * metastatic_cancer +
   4 * other_neurological +
  -4 * obesity +
   3 * paralysis +
   0 * peptic_ulcer +
   4 * peripheral_vascular +
  -4 * psychoses +
   5 * pulmonary_circulation +
   6 * renal_failure +
   0 * rheumatoid_arthritis +
   8 * solid_tumor +
   0 * valvular_disease +
   8 * weight_loss
as elixhauser_SID29


,  -- Below is the 30 component SID score
   0 * aids +
   0 * alcohol_abuse +
  -3 * blood_loss_anemia +
   8 * cardiac_arrhythmias +
   9 * congestive_heart_failure +
   3 * chronic_pulmonary +
  12 * coagulopathy +
   0 * deficiency_anemias +
  -5 * depression +
   1 * diabetes_complicated +
   0 * diabetes_uncomplicated +
 -11 * drug_abuse +
  11 * fluid_electrolyte +
  -2 * hypertension +
   0 * hypothyroidism +
   7 * liver_disease +
   8 * lymphoma +
  17 * metastatic_cancer +
   5 * other_neurological +
  -5 * obesity +
   4 * paralysis +
   0 * peptic_ulcer +
   4 * peripheral_vascular +
  -6 * psychoses +
   5 * pulmonary_circulation +
   7 * renal_failure +
   0 * rheumatoid_arthritis +
  10 * solid_tumor +
   0 * valvular_disease +
  10 * weight_loss
as elixhauser_SID30

from  `physionet-data.mimiciii_clinical.elixhauser_quan`;
