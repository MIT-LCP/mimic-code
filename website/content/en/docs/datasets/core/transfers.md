---
title: "Transfers table"
linktitle: "transfers"
date: 2020-08-10
weight: 3
description: >
  Transfers table
---

## *transfers*

Physical locations for patients throughout their hospital stay.

### Links to

* *patients* on `subject_id`
* *admissions* on `hadm_id`

## Important considerations

* The `icustays` table is derived from this table.

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER
`hadm_id` | INTEGER
`transfer_id` | INTEGER
`eventtype` | VARCHAR(10)
`careunit` | VARCHAR(255)
`intime` | TIMESTAMP(0)
`outtime` | TIMESTAMP(0)

## Detailed Description

## `subject_id`, `hadm_id`, `transfer_id`

Identifiers which specify the patient: `subject_id` is unique to a patient, `hadm_id` is unique to a patient hospital stay, and `transfer_id` is unique to a patient physical location.

Note that `stay_id` present in the *icustays* and *edstays* tables is derived from `transfer_id`. For example, three contiguous ICU stays will have three separate `transfer_id` for each distinct physical location (e.g. a patient could move from one bed to another). The entire stay will have a single `stay_id`, whih will be equal to the `transfer_id` of the first physical location.

## `eventtype`

`eventtype` describes what transfer event occurred: 'ed' for an emergency department stay, 'admit' for an admission to the hospital, 'transfer' for an intra-hospital transfer and 'discharge' for a discharge from the hospital.

## `careunit`

The type of unit or ward in which the patient is physically located. Examples of care units include medical ICUs, surgical ICUs, medical wards, new baby nurseries, and so on.

## `intime`, `outtime`

`intime` provides the date and time the patient was transferred into the current care unit (`careunit`) from the previous care unit. `outtime` provides the date and time the patient was transferred out of the current physical location.
