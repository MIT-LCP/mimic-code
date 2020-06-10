# Contents of this folder

This folder contains scripts to generate useful abstractions of raw MIMIC-III data.
The scripts are intended to be run against the BigQuery instantiation of MIMIC-III, and are written in the BigQuery Standard SQL dialect.
You can read about cloud access to MIMIC-III, including via Google BigQuery, on the [cloud page](https://mimic.physionet.org/gettingstarted/cloud/).

Alternatively, almost all these scripts can be run against a PostgreSQL database with MIMIC installed.
If you do not have access to a PostgreSQL database with MIMIC, you can read more about it in the [buildmimic](https://github.com/MIT-LCP/mimic-code/tree/master/buildmimic/postgres) folder.
First, the [postgres-functions.sql](postgres-functions.sql) script must be run to create functions which emulate BigQuery syntax. Afterwards, the [postgres_make_concepts.sh](postgres_make_concepts.sh) file runs the scripts after applying a few regular expressions which convert table references appropriately. Most scripts work directly with PostgreSQL after removing \`physionet-data.mimiciii_clinical\` from the table references.

Concepts are categorized into folders if possible, otherwise they remain in the top-level directory.

## List of concepts

Folder | Table | Description
--- | --- | ---
- | [echo_data](echo_data.sql) | Text extracted from echocardiography reports using regular expressions.
- | [code_status](code_status.sql) | Whether the patient has restrictions on life saving resuscitation.
comorbidity | [elixhauser_ahrq_v37](comorbidity/elixhauser_ahrq_v37.sql)                    | Comorbidities in categories proposed by Elixhauser et al. AHRQ produced the mapping.
comorbidity | [elixhauser_ahrq_v37_no_drg](comorbidity/elixhauser_ahrq_v37_no_drg.sql)      | As above, but DRG codes are not used to exclude primary conditions.
comorbidity | [elixhauser_quan](comorbidity/elixhauser_quan.sql)                            | Comorbidities in categories proposed by Elixhauser et al. using an algorithm by Quan et al.
comorbidity | [elixhauser_score_ahrq](comorbidity/elixhauser_score_ahrq.sql)                | An integer score relating comorbid burden to mortality (AHRQ comorbidities).
comorbidity | [elixhauser_score_quan](comorbidity/elixhauser_score_quan.sql)                |An integer score relating comorbid burden to mortality (Quan et al. comorbidities).
**demographics** | | Summary of patient/admission level information such as age, height, weight, etc.
demographics | [heightweight](demographics/heightweight.sql)                                | Patient height (cm) and weight (kg).
demographics | [icustay_detail](demographics/icustay_detail.sql)                            | Information relating to each patient ICU stay.
demographics | [icustay_hours](demographics/icustay_hours.sql)                              | A table with one row per hour a patient is in the ICU.
demographics | [icustay_times](demographics/icustay_times.sql)                              | A table with start/stop times for a patient's ICU stay based on the time of their first and last documented heart rate.
**diagnosis** | | 
diagnosis | [ccs_diagnosis_table_psql](diagnosis/ccs_diagnosis_table_psql.sql)              | Load ICD-9 to CCS mapping (PostgreSQL only).
diagnosis | [ccs_dx](diagnosis/ccs_dx.sql)                                                  | Load ICD-9 to CCS mapping.
**durations** | | Start and stop times for administration of various treatments or durations of various phenomena.
durations | [adenosine_durations](durations/adenosine_durations.sql)                        | Start and stop times for administration of adenosine.
durations | [arterial_line_durations](durations/arterial_line_durations.sql)                | Start and stop times for presence of an arterial line.
durations | [central_line_durations](durations/central_line_durations.sql)                  | Start and stop times for presence of an central line
durations | [crrt_durations](durations/crrt_durations.sql)                                  | Start and stop times for continuous renal replacement therapy (CRRT).
durations | [dobutamine_durations](durations/dobutamine_durations.sql)                      | Start and stop times for administration of dobutamine.
durations | [dopamine_durations](durations/dopamine_durations.sql)                          | Start and stop times for administration of dopamine.
durations | [epinephrine_durations](durations/epinephrine_durations.sql)                    | Start and stop times for administration of epinephrine.
durations | [isuprel_durations](durations/isuprel_durations.sql)                            | Start and stop times for administration of isuprel.
durations | [milrinone_durations](durations/milrinone_durations.sql)                        | Start and stop times for administration of milrinone.
durations | [norepinephrine_durations](durations/norepinephrine_durations.sql)              | Start and stop times for administration of norepinephrine.
durations | [phenylephrine_durations](durations/phenylephrine_durations.sql)                | Start and stop times for administration of phenylephrine.
durations | [vasopressin_durations](durations/vasopressin_durations.sql)                    | Start and stop times for administration of vasopressin.
durations | [vasopressor_durations](durations/vasopressor_durations.sql)                    | Start and stop times for administration of vasopressor.
durations | [dobutamine_dose](durations/dobutamine_dose.sql)                                | Dose administered with start/stop times for dobutamine.
durations | [dopamine_dose](durations/dopamine_dose.sql)                                    | Dose administered with start/stop times for dopamine.
durations | [epinephrine_dose](durations/epinephrine_dose.sql)                              | Dose administered with start/stop times for epinephrine.
durations | [neuroblock_dose](durations/neuroblock_dose.sql)                                | Dose administered with start/stop times for neuro blocking agents.
durations | [norepinephrine_dose](durations/norepinephrine_dose.sql)                        | Dose administered with start/stop times for norepinephrine.
durations | [phenylephrine_dose](durations/phenylephrine_dose.sql)                          | Dose administered with start/stop times for phenylephrine.
durations | [vasopressin_dose](durations/vasopressin_dose.sql)                              | Dose administered with start/stop times for vasopressin.
durations | [ventilation_classification](durations/ventilation_classification.sql)          | Classifies patient settings as implying mechanical ventilation.
durations | [ventilation_durations](durations/ventilation_durations.sql)                    | Start and stop times for mechanical ventilation.
durations | [weight_durations](durations/weight_durations.sql)                              | Start and stop times for daily weight measurements.
**firstday** | | The first day subfolder contains scripts to summarizes a patient's health on their first ICU day.
firstday | [blood_gas_first_day](firstday/blood_gas_first_day.sql)                          | Highest and lowest blood gas values in the first 24 hours of a patient's ICU stay.
firstday | [blood_gas_first_day_arterial](firstday/blood_gas_first_day_arterial.sql)        | As above, but arterial blood gases only.
firstday | [gcs_first_day](firstday/gcs_first_day.sql)                                      | Highest and lowest Glasgow Coma Scale in the first 24 hours of a patient's ICU stay.
firstday | [height_first_day](firstday/height_first_day.sql)                                | Median height recorded for the patient in the first 24 hours of a patient's ICU stay.
firstday | [labs_first_day](firstday/labs_first_day.sql)                                    | Highest and lowest laboratory values in the first 24 hours of a patient's ICU stay.
firstday | [rrt_first_day](firstday/rrt_first_day.sql)                                      | Presence of renal replacement therapy in the first 24 hours of a patient's ICU stay.
firstday | [urine_output_first_day](firstday/urine_output_first_day.sql)                    | Total urine output over the first 24 hours of a patient's ICU stay.
firstday | [ventilation_first_day](firstday/ventilation_first_day.sql)                      | Whether the patient was mechanically ventilated in the first 24 hours.
firstday | [vitals_first_day](firstday/vitals_first_day.sql)                                | Highest and lowest vital signs in the first 24 hours of a patient's ICU stay.
firstday | [weight_first_day](firstday/weight_first_day.sql)                                | Highest and lowest weight measurements in the first 24 hours of a patient's ICU stay.
**fluid_balance** | | Tables which track fluid input and output for the patient.
fluid_balance | [colloid_bolus](fluid_balance/colloid_bolus.sql)                            | Times at which a patient received a bolus of colloidal fluid.
fluid_balance | [crystalloid_bolus](fluid_balance/crystalloid_bolus.sql)                    | Times at which a patient received a bolus of crystalloid fluid.
fluid_balance | [urine_output](fluid_balance/urine_output.sql)                              | Urine output for a patient with the time of documentation.
**organfailure** | | Summarizations of the degree of organ failure for single organ systems.
organfailure | [kdigo_creatinine](organfailure/kdigo_creatinine.sql)                        | Creatinine values with baseline creatinine as defined by KDIGO.
organfailure | [kdigo_uo](organfailure/kdigo_uo.sql)                                        | Urine output over 6, 12, and 24 hour periods.
organfailure | [kdigo_stages](organfailure/kdigo_stages.sql)                                | Stages of acute kidney failure (AKI) as defined by KDIGO.
organfailure | [kdigo_stages_48hr](organfailure/kdigo_stages_48hr.sql)                      | Stages of AKI for the first 48 hours of a patient's ICU stay.
organfailure | [kdigo_stages_7day](organfailure/kdigo_stages_7day.sql)                      | Stages of AKI for the first 7 days of a patient's ICU stay.
organfailure | [meld](organfailure/meld.sql)                                                | The MELD score, often used to assess health of liver transplant candidates.
**pivot** |                                                                                 | Pivoted views contain the patient `icustay_id`, the `charttime`, and a number of variables. They are useful to acquiring a time series of values for patient stays.
pivot | [pivoted_bg](pivot/pivoted_bg.sql)                                                  | Blood gas measurements.
pivot | [pivoted_fio2](pivot/pivoted_fio2.sql)                                              | Fraction of inspired oxygen.
pivot | [pivoted_gcs](pivot/pivoted_gcs.sql)                                                | Glasgow Coma Scale.
pivot | [pivoted_height](pivot/pivoted_height.sql)                                          | Height.
pivot | [pivoted_icp](pivot/pivoted_icp.sql)                                                | Intracranial pressure.
pivot | [pivoted_invasive_lines](pivot/pivoted_invasive_lines.sql)                          | Invasive lines.
pivot | [pivoted_lab](pivot/pivoted_lab.sql)                                                | Laboratory values.
pivot | [pivoted_oasis](pivot/pivoted_oasis.sql)                                            | The Oxford Acute Severity of Illness Score (OASIS).
pivot | [pivoted_rrt](pivot/pivoted_rrt.sql)                                                | Renal replacement therapy.
pivot | [pivoted_sofa](pivot/pivoted_sofa.sql)                                              | The Sequential Organ Failure Assessment (SOFA) scale.
pivot | [pivoted_uo](pivot/pivoted_uo.sql)                                                  | Urine output.
pivot | [pivoted_vent_setting](pivot/pivoted_vent_setting.sql)                              | Ventilator settings (tidal volume, PEEP, etc).
pivot | [pivoted_vital](pivot/pivoted_vital.sql)                                            | Vital signs.
**sepsis** | | Definitions of sepsis, a common cause of mortality for intensive care unit patients.
sepsis | [angus](sepsis/angus.sql)                                                          | Sepsis defined using billing codes validated by Angus et al.
sepsis | [explicit](sepsis/explicit.sql)                                                    | Explicitly coded sepsis (i.e. a list of patients with ICD-9 codes which refer to sepsis).
sepsis | [martin](sepsis/martin.sql)                                                        | Sepsis defined using billing codes validated by Martin et al. (now considered "septicemia").
**severityscores** |                                                                        | Severity of illness scores are defined using the highest/lowest values during the first 24 hours of a patient's stay.
severityscores | [apsiii](severityscores/apsiii.sql)                                        | Acute Physiology Score III.
severityscores | [lods](severityscores/lods.sql)                                            | Logistic Organ Dysfunction Score.
severityscores | [mlods](severityscores/mlods.sql)                                          | Modified Logistic Organ Dysfunction Score.
severityscores | [oasis](severityscores/oasis.sql)                                          | The Oxford Acute Severity of Illness Score (OASIS).
severityscores | [qsofa](severityscores/qsofa.sql)                                          | The quick Sequential Organ Failure Assessment (qSOFA) scale.
severityscores | [saps](severityscores/saps.sql)                                            | The Simplified Acute Physiology Score (SAPS).
severityscores | [sapsii](severityscores/sapsii.sql)                                        | SAPS II.
severityscores | [sirs](severityscores/sirs.sql)                                            | The Systemic Inflammation Response Score (SIRS).
severityscores | [sofa](severityscores/sofa.sql)                                            | The Sequential Organ Failure Assessment (SOFA) scale.
**treatment** | | Tables associated with treatment of a patient.
treatment | [abx_prescriptions_list](treatment/abx_prescriptions_list.sql)                  | A list of antibiotics mentioned in the prescriptions table.
treatment | [suspicion_of_infection](treatment/suspicion_of_infection.sql)                  | Suspicion of infection as defined by antibiotic use near the ordering of blood cultures.

## Other scripts present

### cookbook

This is an asortment of scripts intended to give the user more familiarity with the MIMIC-III database. None of these scripts generate materialized views.

## functions

Useful snippets of SQL implementing common functions. For example, the `auroc.sql` file calculates the area under the receiver operator characteristic curve (AUROC) for a set of predictions, `PRED`, given a set of targets, `TAR`. The AUROC is a useful measure of the discrimination of a set of predictions.

## other-languages

Scripts in flavours of SQL which are not necessarily compatible with PostgreSQL.
