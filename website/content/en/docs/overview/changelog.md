---
title: "MIMIC-IV Change log"
linktitle: "Change log"
date: 2020-08-10
weight: 40
description: >
  Changes between releases of MIMIC-IV.
---

The latest version of MIMIC-IV is v1.0. 

This page lists changes implemented in sequential updates to the MIMIC-IV database. Issues are tracked using a unique issue number, usually of the form #100, #101, etc (this issue number relates to a private 'building' repository).

### MIMIC-IV v1.0

MIMIC-IV v1.0 was released March 2nd, 2021.

#### core

* *admissions*
    * A number (~1000, <1%) of erroneous `hadm_id` have been removed.
* *patients
    * `dod` is now populated using the patient's `deathtime` from their latest hospitalization (reported in [#71](https://github.com/MIT-LCP/mimic-iv/issues/71), thanks [@jinjinzhou](https://github.com/jinjinzhou)).
    * At the moment, out-of-hospital mortality is **not** captured by `dod`
* *transfers*
    * Removed erroneous transfers included in the previous version.
    * `transfer_id` has been regenerated. `transfer_id` in MIMIC-IV v1.0 are **not compatible** with `transfer_id` from v0.4. We do not intend to change `transfer_id` when updating MIMIC-IV, but had to update it due to an error in its generation.
    * All `hadm_id` in transfers are also present in *admissions* and vice-versa (reported in [#84](https://github.com/MIT-LCP/mimic-iv/issues/84), thanks [@kokoko12305](https://github.com/kokoko12305)).

#### icu

* *icustays*
    * ICU stays were inappropriately assigned in the previous version due to an error in the preprocessing code. Previously, non-ICU ward transfers were included in the ICU stays, and certain ward stays were not treated as ICU stays (reported in [#67](https://github.com/MIT-LCP/mimic-iv/issues/67), thanks [@JHLiu7](https://github.com/JHLiu7) and [@stefanhgm](https://github.com/stefanhgm)). The assignment of `stay_id` has been regenerated.
    * The mapping between hospital transfers and ICU stays has been updated.
    * `stay_id` in MIMIC-IV v1.0 are **not compatible** with `stay_id` from v0.4. We do not intend to change `stay_id` when updating MIMIC-IV, but had to update it due to an error in its generation.
* The change in *icustays* has re-assigned values to new `stay_id`, as a result all tables have had their content changed (due to a change in `stay_id`), but the structure is unchanged.

#### hosp

* *note*, *note_detail*
    * These tables have been added to the hosp module.
    * The *note* table contains over 60,000 deidentified discharge summaries for patients admitted to an ICU during their hospitalization.
    * The *note_detail* table will also information associated with individual notes (e.g. quantitative information associated with echocardiography reports, contrast information for radiology reports, etc). Currently, the *note_detail* table contains the author of the discharge summary, but due to deidentification the author always appears as three underscores (___). It is not useful currently, but we hope to provide provider identifiers in the future.
* *hcpcsevents*
    * Data has been added for a number of previously excluded hospitalizations.
    * The table now has a `chartdate` column, containing the date associated with the code. Every row is associated with a date.
* *drgcodes*
    * Data has been added for a number of previously excluded hospitalizations.
    * Duplicate DRG codes have been removed from the table.
    * Descriptions have been updated using the latest dictionaries made available from [the Massachusetts government website](https://www.mass.gov/service-details/special-notices-for-acute-hospitals) and [HCUP](https://www.hcup-us.ahrq.gov/db/state/siddbdocumentation.jsp).
* *diagnoses_icd*, *d_icd_diagnoses*
    * Data has been added for a number of previously excluded hospitalizations (reported in [#27](https://github.com/MIT-LCP/mimic-iv/issues/27), thanks [@yugangjia](https://github.com/yugangjia)).
    * The icd_code column is now trimmed and stored as a VARCHAR, i.e. codes no longer contain trailing whitespaces (`850 ` -> `850`).
    * Missing ICD codes have been added to the dictionary. All ICD codes in the diagnoses_icd table have an associated reference in *d_icd_diagnoses*.
* *labevents*
    * The `comments` field has been updated, fixing a bug where comments longer than 4096 characters were truncated. Due to the deidentification, it's unlikely users will see much difference, as these comments will appear as `___`.
* *procedures_icd*
    * Data has been added to *procedures_icd* for a number of previously excluded hospitalizations.
    * The table now has a chartdate column, containing the date associated with each billed procedure.
    * The icd_code column is now trimmed and stored as a VARCHAR, i.e. codes no longer contain trailing whitespaces (`850 ` -> `850`).
    * Missing ICD codes have been added to the dictionary. All ICD codes in the *procedures_icd* table have an associated reference in *d_icd_procedures*.

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
