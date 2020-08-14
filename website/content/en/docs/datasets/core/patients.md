---
title: "Patients table"
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

`dod` is the date of death as recorded in the hospital database.

### `anchor_age`, `anchor_year`, `anchor_year_group`

These columns provide information regarding the actual patient year for the patient admission, and the patient's age at that time.

* `anchor_year` is a shifted year for the patient.
* `anchor_year_group` is a range of years - the patient's `anchor_year` occurred during this range.
* `anchor_age` is the patient's age in the `anchor_year`.
* Example: a patient has an `anchor_year` of 2153, `anchor_year_group` of 2008 - 2010, and an `anchor_age` of 60.
  * The year 2153 for the patient corresponds to 2008, 2009, or 2010.
  * The patient was 60 in the shifted year of 2153, i.e. they were 60 in 2008, 2009, or 2010.
  * A patient admission in 2154 will occur in 2009-2011, an admission in 2155 will occur in 2010-2012, and so on.

## `ANCHOR_AGE`, `ANCHOR_YEAR`, `ANCHOR_YEAR_SHIFTED`

`ANCHOR_AGE`, `ANCHOR_YEAR`, and `ANCHOR_YEAR_SHIFTED` are intended to be analyzed together. The `ANCHOR_AGE` is the age of the patient in the given `ANCHOR_YEAR`/`ANCHOR_YEAR_SHIFTED`. In order to determine the age of a patient on admission to the hospital, it is necessary to account for the number of years between `ANCHOR_YEAR_SHIFTED` and their hospital admission time.

## `DOD`

The de-identified date of death for the patient. Date of death is extracted from the hospital information system only, and does not include out of hospital mortality as of MIMIC-IV v1.0.
