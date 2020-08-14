---
title: "CXR Record List"
linktitle: "cxr_record_list"
date: 2020-08-10
weight: 3
description: >
  CXR Record List
---

This table lists all records in the MIMIC-CXR database.
Each DICOM file, corresponding to a single chest x-ray, is assigned a unique `dicom_id`.
This table links those IDs to a `study_id` for the radiology report and a `subject_id` for the patient.

**Table source:** Hospital database.

**Table purpose:** Provides a link between `subject_id`, `study_id`, and `dicom_id`.

**Number of rows:** 

**Links to:**

* CORE.PATIENTS on `subject_id`

# Important considerations

Chest x-rays are available for all *patients* who presented to the emergency department. The logic was:

* extract patient identifiers for all patients admitted to the emergency department between 2011 - 2016
* use these patient identifiers to extract *all* chest x-rays performed during 2011-2016

As such, if a patient was admitted to the ED between 2011 - 2016, then x-rays will be available for the ED admission, and any subsequent stays in the hospital (e.g. if they were admitted to the intensive care unit, their chest x-rays in the ICU will be available).

# Table columns

Name | Postgres data type
---- | ----
`subject_id`   | INTEGER NOT NULL
`study_id`     | INTEGER NOT NULL
`dicom_id`     | TEXT NOT NULL

## `subject_id`

`subject_id` is a unique identifier which specifies an individual patient. Any rows associated with a single `subject_id` pertain to the same individual.

## `study_id`

A unique identifier for the radiology report written for the given chest x-ray.

## `dicom_id`

A unique identifier for the chest x-ray.