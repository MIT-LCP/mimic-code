---
title: "MIMIC-IV Change log"
linktitle: "Change log"
date: 2020-08-10
weight: 40
description: >
  Changes between releases of MIMIC-IV.
---

The latest version of MIMIC-IV is v0.4. 

This page lists changes implemented in sequential updates to the MIMIC-IV database. Issues are tracked using a unique issue number, usually of the form #100, #101, etc (this issue number relates to a private 'building' repository).

### MIMIC-IV v0.4

MIMIC-IV v0.4 was released August 13th, 2020.

- *d_micro*
    - This table has been removed
- *microbiologyevents*
    - Added the `spec_type_desc`, `test_name`, `org_name`, and `ab_name` columns
        - These columns contain the textual name of the organism/antibiotic/test/specimen
    - Added the `comments` column
        - this column contains information about the test, and in some cases (e.g. viral load tests), contains the result
    - `micro_specimen_id` has been regenerated; the values will not match previous versions.

### MIMIC-IV v0.3

MIMIC-IV v0.3 was released July 13th, 2020. 

- Fixed an alignment issue in shifted dates/times

### MIMIC-IV v0.2

MIMIC-IV v0.2 was released June 23rd, 2020.

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
