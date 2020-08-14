---
title: "edstays table"
date: 2020-08-10
weight: 1
description: >
  edstays table
---

# The MAIN table

The MAIN table is the primary tracking table for emergency department visits.
It provides the time the patient entered the emergency department and the time they left the emergency department.
It also provides a set of diagnoses assigned for the patient.

**Table source:** Emergency department database.

**Table purpose:** Track patient admissions to the emergency department.

**Number of rows:** 

**Links to:**

<!-- # Important considerations -->

# Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER NOT NULL
`stay_id`    | INTEGER NOT NULL
`intime`     | TIMESTAMP(0) NOT NULL
`outtime`    | TIMESTAMP(0) NOT NULL
`sex`        | CHAR(1) NOT NULL
`dx1`        | VARCHAR(255)
`dx1_icd`    | VARCHAR(10)
`dx2`        | VARCHAR(255)
`dx2_icd`    | VARCHAR(10)
`dx3`        | VARCHAR(255)
`dx3_icd`    | VARCHAR(10)
`dx4`        | VARCHAR(255)
`dx4_icd`    | VARCHAR(10)
`dx5`        | VARCHAR(255)
`dx5_icd`    | VARCHAR(10)
`dx6`        | VARCHAR(255)
`dx6_icd`    | VARCHAR(10)
`dx7`        | VARCHAR(255)
`dx7_icd`    | VARCHAR(10)
`dx8`        | VARCHAR(255)
`dx8_icd`    | VARCHAR(10)
`dx9`        | VARCHAR(255)
`dx9_icd`    | VARCHAR(10)

## `subject_id`

`subject_id` is a unique identifier which specifies an individual patient. Any rows associated with a single `subject_id` pertain to the same individual.

## `stay_id`

An identifier which uniquely identifies a single emergency department stay for a single patient.

## `intime`, `outtime`

The admission datetime (`intime`) and discharge datetime (`outtime`) of the given emergency department stay.

## `dx1_icd`, `dx2_icd`, ... `dx9_icd`

The ICD coded diagnoses for the patient, ordered by priority.

## `dx1`, `dx2`, ..., `dx9`

The textual description of ICD diagnoses for the patient.
