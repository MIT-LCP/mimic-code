---
title: "MIMIC-IV Identifiers"
linktitle: "Identifiers"
date: 2020-08-10
weight: 2
description: >
  Identifiers
---

<!-- 
# Types of data in the database

Data within MIMIC were recorded during routine clinical care and *not* explicitly for the purpose of retrospective data analysis. This is a key point to keep in mind when analyzing the data.

There are two types of data in the database: static data and dynamic data. Static data is recorded once for a given identifier. An example of static data is the `dob` column in the PATIENTS table. Each patient has only one date of birth, which does not change over time and is not recorded with an associated timestamp. An example of dynamic data is a patient's blood pressure, which is periodically measured during a hospital stay.

This distinction between static data and dynamic data is merely a helpful conceptual construct: there is *no* strict technical distinction between date of birth and heart rate. However, static data tends to not have an associated `ITEMID` (as there is no need to repeatedly record values for static data), whereas dynamic data have an `ITEMID` to facilitate efficient storage of repeated measurements.

# Static data
-->

# Patient identifiers

Patients are identified in the database using three possible identifiers: `subject_id`, `hadm_id`, and `stay_id`.
Every unique patient is assigned a unique `subject_id`, all unique hospitalizations are assigned a unique `hadm_id`, and finally all unique ward stays are assigned a unique `transfer_id`. In this context, a ward is a distinct area of the hospital, and a new `transfer_id` is assigned to a patient if the hospital patient tracking system records that they have been moved from one room to another.

However, many patients will move from one specific location to another, but practically their type of care has not changed. A good example is a patient moving bed locations within an ICU: these changes result in the patient having a new `transfer_id`, but the patient never left the ICU and we would consider this as a continuous episode of care. In order to alleviate this issue, we have created a `stay_id`, which is retained across all ward stays of the same type occurring within 24 hours of each other. That is, if a patient leaves and returns to the ICU within 24 hours, they will have the same `stay_id` for the second ICU stay.

## `subject_id`

The PATIENTS table contains information for each unique `subject_id`. `subject_id` is sourced from the hospital, and is an anonymized version of a patient's medical record number.

## `hadm_id`

The ADMISSIONS table contains information for each unique `hadm_id`. `hadm_id` is sourced from the hospital, and is an anonymized version of an identifier assigned to each patient hospitalization.

## `transfer_id`

The TRANSFERS table contains information for each unique `transfer_id`. `transfer_id` is an artificially generated identifier which is uniquely assigned to a ward stay for an individual patient.

## `stay_id`

The TRANSFERS table also contains the `stay_id`. This is an artificially generated identifier which groups reasonably contiguous episodes of care.