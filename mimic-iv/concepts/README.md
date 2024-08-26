# MIMIC-IV Concepts

This folder contains scripts to generate useful abstractions of raw MIMIC-IV data ("concepts").
The scripts are written using the **BigQuery Standard SQL Dialect**. Concepts are categorized into folders if possible, otherwise they remain in the top-level directory. The [postgres](/mimic-iv/concepts_postgres) subfolder contains automatically generated PostgreSQL versions of these scripts; [see below for how these were generated](#postgresql-concepts). Concepts are categorized into folders if possible, otherwise they remain in the top-level directory.

The concepts are organized into individual SQL scripts, with each script generating a table. The BigQuery `mimiciv_derived` dataset under `physionet-data` contains the concepts pregenerated. Access to this dataset is available to MIMIC-IV approved users: see the [cloud instructions](https://mimic.mit.edu/docs/gettingstarted/cloud/) on how to access MIMIC-IV on BigQuery (which includes the derived concepts).

See the [top-level readme](mimic-iv/README.md) for more information about generating the concepts.

## Concept Index

Concepts in this folder:

```
├── comorbidity
│   └── charlson.sql
├── demographics
│   ├── age.sql
│   ├── icustay_detail.sql
│   ├── icustay_hourly.sql
│   ├── icustay_times.sql
│   └── weight_durations.sql
├── firstday
│   ├── first_day_bg.sql
│   ├── first_day_bg_art.sql
│   ├── first_day_gcs.sql
│   ├── first_day_height.sql
│   ├── first_day_lab.sql
│   ├── first_day_rrt.sql
│   ├── first_day_sofa.sql
│   ├── first_day_urine_output.sql
│   ├── first_day_vitalsign.sql
│   └── first_day_weight.sql
├── measurement
│   ├── bg.sql
│   ├── blood_differential.sql
│   ├── cardiac_marker.sql
│   ├── chemistry.sql
│   ├── coagulation.sql
│   ├── complete_blood_count.sql
│   ├── creatinine_baseline.sql
│   ├── enzyme.sql
│   ├── gcs.sql
│   ├── height.sql
│   ├── icp.sql
│   ├── inflammation.sql
│   ├── oxygen_delivery.sql
│   ├── rhythm.sql
│   ├── urine_output.sql
│   ├── urine_output_rate.sql
│   ├── ventilator_setting.sql
│   └── vitalsign.sql
├── medication
│   ├── acei.sql
│   ├── antibiotic.sql
│   ├── arb.sql
│   ├── dobutamine.sql
│   ├── dopamine.sql
│   ├── epinephrine.sql
│   ├── milrinone.sql
│   ├── neuroblock.sql
│   ├── norepinephrine.sql
│   ├── norepinephrine_equivalent_dose.sql
│   ├── nsaid.sql
│   ├── phenylephrine.sql
│   ├── vasoactive_agent.sql
│   └── vasopressin.sql
├── organfailure
│   ├── kdigo_creatinine.sql
│   ├── kdigo_stages.sql
│   ├── kdigo_uo.sql
│   └── meld.sql
├── score
│   ├── apsiii.sql
│   ├── lods.sql
│   ├── oasis.sql
│   ├── sapsii.sql
│   ├── sirs.sql
│   └── sofa.sql
├── sepsis
│   ├── sepsis3.sql
│   └── suspicion_of_infection.sql
└── treatment
    ├── code_status.sql
    ├── crrt.sql
    ├── invasive_line.sql
    ├── rrt.sql
    └── ventilation.sql
```
