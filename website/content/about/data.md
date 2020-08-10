+++
date = "2015-09-01T19:33:17-04:00"
title = "MIMIC-IV"
linktitle = "MIMIC-IV"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "About"

+++

## MIMIC-IV

MIMIC-IV is an update to MIMIC-III, containing hospitalized patients from 2008 - 2019 inclusive.
The data is separated into ``modules'' to reflect the non-overlapping nature and distinct origins of the individual modules.

There are currently five modules:

- [core](/datasets/core) - admissions/transfers/stays/services - this is the hospital level patient tracking dataset
- [hosp](/datasets/hosp) - hospital level data for patients: labs, micro, and electronic medication administration
- [icu](/datasets/icu) - ICU level data. These are the event tables, and are identical in structure to MIMIC-III (chartevents, etc)
- [ed](/datasets/ed) - data from the emergency department, fairly simple structure
- [cxr](/datasets/cxr) - metadata linking CXRs to patients

All patients across all datasets are in mimic_core. However, not all ICU patients have ED data, not all ICU patients have CXRs, not all ED patients have hospital data, and so on. Within an individual dataset, there are also incomplete tables as certain electronic systems did not exist in the past. For example, eMAR data is only available from 2015 onward. A metadata table is being created to identify all major instances of this behavior.

## Release notes

This page lists changes implemented in sequential updates to the MIMIC-CXR database. Issues are tracked using a unique issue number, usually of the form #100, #101, etc (this issue number relates to a private 'building' repository).

### Current version

The current version of the database is v0.2. When referencing this version, we recommend using the full title: MIMIC-IV v0.2.

### MIMIC-IV v0.2

- Updated demographics in the patient table
  - `anchor_year` -> `anchor_year_group`
  - `anchor_year_shifted` -> `anchor_year`
  - See the [patients table](/core/patients) for detail on these columns
- *transfers*
  - Deleted the `los` column
- *emar*
  - `mar_id` -> `emar_id`
    - `emar_id` is now a composite of `subject_id` and `emar_seq`, and has form "subject_id-emar_seq"
  - `emar_seq` column - a monotonically increasing integer starting with the first eMAR administration
  - Added `poe_id` and `pharmacy_id` columns for linking to those tables
- *emar_detail*
  - `mar_id` -> `emar_id` (changed as above)
  - Deleted the `mar_detail_id` column
- *hcpcsevents*
  - `ticket_id_seq` -> `seq_num`
- *labevents*
  - Many previously NULL values are now populated - these were removed originally due to deidentification
  - Added the `comments` column. This contains deidentified free-text comments with labs. PHI is replaced with three underscores (`___`). If an entire comment is `___`, then the entire comment was scrubbed.
  - `spec_id` -> `specimen_id`
- *microbiologyevents*
  - `stay_id` column removed
  - `spec_id` -> `micro_specimen_id`
- Added the [*poe*](/hosp/poe) and [*poe_detail*](/hosp/poe_detail) tables
  - Documentation of provider orders for various treatments and other aspects of patient management
- Added the [*prescriptions*](/hosp/prescriptions) table
  - Documentation of medicine prescriptions via the provider order interface
- Added the [*pharmacy*](/hosp/pharmacy) table
  - Detailed information regarding prescriptions provided by the pharmacy including formulary dose, route, frequency, dose, and so on.
- *inputevents*
  - Fixed an error in the calculation of the *amount* column
- *icustays*
  - Re-derived `stay_id` - the new `stay_id` are distinct from the previous version.
- *diagnosis*
  - Added [*diagnosis*](/ed/diagnosis) table with similar schema as the *diagnosis_icd* table.
- *main*
  - Removed diagnosis columns from this table (inserted into *diagnosis* above)

### MIMIC-IV v0.1

MIMIC-IV v0.1 was released on 15 August 2019.
