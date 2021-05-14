---
title: "vitalsign table"
date: 2020-08-10
weight: 1
description: >
  vitalsign table
---


# The VITALSIGN table

Patients admitted to the emergency department have routine vital signs taken ever 1-4 hours. These vital signs are stored in the VITALSIGN table.

**Table source:** Emergency department database.

**Table purpose:** Provides nurse documented vital signs.

**Number of rows:** 

**Links to:**

* MAIN on `stay_id`

<!-- # Important considerations -->

# Table columns

Name | Postgres data type
---- | ----
`stay_id`   | INTEGER NOT NULL
`charttime` | TIMESTAMP(0)
`temp`      | NUMERIC(10, 4)
`pulse`     | NUMERIC(10, 4)
`SBP`       | INTEGER
`DBP`       | INTEGER
`RR`        | NUMERIC(10, 4)
`O2Sat`     | NUMERIC(10, 4)
`Rhythm`    | TEXT
`Pain`      | TEXT

## `stay_id`

An identifier which uniquely identifies a single emergency department stay for a single patient.

## `charttime`

The time at which the vital signs were charted.

## `temp`

The patient's temperature.

## `pulse`

The patient's heart rate.

## `sbp`, `dbp`

The patient's diastolic (dbp) and systolic (sbp) blood pressure.

## `rr`

The patient's respiratory rate.

<!-- o2flow -->

## `o2sat`

The patient's peripheral oxygen saturation.

## `rhythm`

The patient's current heart rhythm

## `pain`

The patient's self-reported level of pain on a scale from 0-10.