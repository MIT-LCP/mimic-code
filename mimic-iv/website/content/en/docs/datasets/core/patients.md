---
title: "Patients table"
linktitle: "patients"
date: 2020-08-10
weight: 2
description: >
  Patients table
---

Information that is consistent for the lifetime of a patient is stored in this table.

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER
`gender` | VARCHAR(1)
`anchor_age` | INTEGER
`anchor_year` | INTEGER
`anchor_year_group` | VARCHAR(255)
`dod` | TIMESTAMP(0)

## Detailed Description

### `subject_id`

`subject_id` is a unique identifier which specifies an individual patient. Any rows associated with a single `subject_id` pertain to the same individual. As `subject_id` is the primary key for the table, it is unique for each row. 

### `gender`

`gender` is the genotypical sex of the patient.

### `anchor_age`, `anchor_year`, `anchor_year_group`

These columns provide information regarding the actual patient year for the patient admission, and the patient's age at that time.

* `anchor_year` is a shifted year for the patient.
* `anchor_year_group` is a range of years - the patient's `anchor_year` occurred during this range.
* `anchor_age` is the patient's age in the `anchor_year`.
* Example: a patient has an `anchor_year` of 2153, `anchor_year_group` of 2008 - 2010, and an `anchor_age` of 60.
  * The year 2153 for the patient corresponds to 2008, 2009, or 2010.
  * The patient was 60 in the shifted year of 2153, i.e. they were 60 in 2008, 2009, or 2010.
  * A patient admission in 2154 will occur in 2009-2011, an admission in 2155 will occur in 2010-2012, and so on.

### `dod`

The de-identified date of death for the patient. Date of death is extracted from the hospital information system only. **Out-of-hospital mortality is currently unavailable as of MIMIC-IV v1.0**.
