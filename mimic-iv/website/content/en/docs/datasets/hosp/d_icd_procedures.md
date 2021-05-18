---
title: "Dimension table: ICD procedures"
linktitle: "d_icd_procedures"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## The D_ICD_PROCEDURES table

This table defines International Classification of Diseases (ICD) codes for **procedures**. These codes are assigned at the end of the patient's stay and are used by the hospital to bill for care provided. They can further be used to identify if certain procedures have been performed (e.g. surgery).

### Links to

* procedures_icd on `icd_code`

## Brief summary

<!-- # Important considerations -->

## Table columns

Name | Postgres data type
---- | ----
`icd_code` | VARCHAR(10)
`icd_version` | INTEGER
`long_title` | VARCHAR(300)

## Detailed Description

### `icd_code`, `icd_version`

`icd_code` is the International Coding Definitions (ICD) code.

There are two versions for this coding system: version 9 (ICD-9) and version 10 (ICD-10). These can be differentiated using the `icd_version` column.
In general, ICD-10 codes are more detailed, though code mappings (or "cross-walks") exist which convert ICD-9 codes to ICD-10 codes.

Both ICD-9 and ICD-10 codes are often presented with a decimal. This decimal is not required for interpretation of an ICD code; i.e. the `icd_code` of '0010' is equivalent to '001.0'.

## `long_title`

The title fields provide a brief definition for the given procedure code in ``.
