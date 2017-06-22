# Contents of this folder

This folder contains scripts to generate materialized views in a PostgreSQL database with MIMIC installed. If you do not have access to a PostgreSQL database with MIMIC, you can read more about it in the [buildmimic](https://github.com/MIT-LCP/mimic-code/tree/master/buildmimic/postgres) folder.

Concepts are categorized into folders if possible, otherwise they remain in the top-level directory.

# Subfolders

## comorbidity

These scripts derive binary flags indicating the presence of various comorbidities using billing codes (ICD-9) assigned to the patient at hospital discharge.

## cookbook

This is an asortment of scripts intended to give the user more familiarity with the MIMIC-III database. None of these scripts generate materialized views.

## demographics

Summary of patient/admission level information such as age, height, weight, etc.

## firstday

The first day subfolder contains scripts used to calculate various clinical concepts on the first day of a patient's admission to the ICU, such as the highest blood pressure, lowest temperature, etc. This folder contains many useful scripts which can be adapted to capture data outside the first day.

## functions

Useful snippets of SQL implementing common functions. For example, the `auroc.sql` file calculates the area under the receiver operator characteristic curve (AUROC) for a set of predictions, `PRED`, given a set of targets, `TAR`. The AUROC is a useful measure of the discrimination of a set of predictions.

## other-languages

Scripts in flavours of SQL which are not necessarily compatible with PostgreSQL.

## sepsis

Definitions of sepsis, a common cause of mortality for intensive care unit patients.

## severityscores

Severity of illness scores which summarize the acuity of a patient's illness on admission to the intensive care unit (usually in the first 24 hours).

## durations

Start and stop times for administration of various treatments or durations of various phenomena, including: medical agents which have a vasoactive effect on a patient's circulatory system, continuous renal replacement therapy (CRRT), and mechanical ventilation.
