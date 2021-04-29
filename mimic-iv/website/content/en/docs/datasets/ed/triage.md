---
title: "triage table"
date: 2020-08-10
weight: 1
description: >
  triage table
---

# The TRIAGE table

The TRIAGE table contains information about the patient when they were first triaged in the emergency department.
Patients are assessed at triage by a single care provider and asked a series of questions to assess their current health status.
Their vital signs are measured and a level of acuity is assigned. Based on the level of acuity, the patient either waits in the waiting room for later attention, or is prioritized for immediate care.

**Table source:** Emergency department database.

**Table purpose:** 

**Number of rows:** 

**Links to:**

* MAIN on `stay_id`

# Important considerations

* There is no time associated with triage observations. The closest approximation to triage time is the `intime` of the patient from the MAIN table.

# Table columns

Name | Postgres data type
---- | ----
`stay_id` | INTEGER NOT NULL
`temp`    | NUMERIC(10, 4)
`HR`      | NUMERIC(10, 4)
`RR`      | NUMERIC(10, 4)
`SaO2`    | NUMERIC(10, 4)
`Pain`    | NUMERIC(10, 4)
`Acuity`  | NUMERIC(10, 4)
`SBP`     | NUMERIC(10, 4)
`DBP`     | NUMERIC(10, 4)

## `stay_id`

An identifier which uniquely identifies a single emergency department stay for a single patient.

## `temp`

The patient's temperature in degrees Celsius.

## `HR`

The patient's heart rate.

## `RR`

The patient's respiratory rate.

## `SaO2`

The patient's peripheral oxygen saturation.

## `Pain`

The level of pain self-reported by the patient, on a scale of 0-10.

## `Acuity`

The assigned acuity level for the patient. The acuity level determines how immediately the patient requires care:

* 1 - Not urgent
* 5 - Must be admitted and seen by medical staff immediately

## `SBP`, `DBP`

The patient's systolic and diastolic blood pressure, respectively, measured in millimitres of mercury (mmHg).
