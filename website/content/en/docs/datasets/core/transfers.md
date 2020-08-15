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
`stay_id` | INTEGER
`transfer_id` | INTEGER
`eventtype` | VARCHAR(10)
`careunit` | VARCHAR(255)
`intime` | TIMESTAMP(0)
`outtime` | TIMESTAMP(0)

## Detailed Description

## `subject_id`, `hadm_id`, `transfer_id`

Identifiers which specify the patient: `subject_id` is unique to a patient, `hadm_id` is unique to a patient hospital stay, `stay_id` is unique to a patient stay in a hospital unit, `transfer_id` is unique to a patient physical location.

## `eventtype`

`eventtype` describes what transfer event occurred: 'admit' for an admission, 'transfer' for an intra-hospital transfer and 'discharge' for a discharge from the hospital.

## `careunit`

`careunit` contains the care unit in which the patient currently resides.

The `intime` and `outtime` of the transfer event correspond to the `careunit`.

## `intime`, `outtime`

`intime` provides the date and time the patient was transferred into the current care unit (`careunit`) from the previous care unit. `outtime` provides the date and time the patient was transferred out of the current physical location.
