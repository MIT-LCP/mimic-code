---
title: "DRG Codes"
linktitle: "drgcodes"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## *drgcodes*

Diagnosis related groups (DRGs) are used by the hospital to obtain reimbursement for a patient's hospital stay.
The codes correspond to the primary reason for a patient's stay at the hospital.

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER
`hadm_id` | INTEGER
`drg_type` | VARCHAR(4)
`drg_code` | VARCHAR(10)
`description` | VARCHAR(195)
`drg_severity` | SMALLINT
`drg_mortality` | SMALLINT

## Detailed Description

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `drg_type`

The specific DRG ontology used for the code.

### `drg_code`

The DRG code.

### `description`

A description for the given DRG code.

### `drg_severity`, `drg_mortality`

Some DRG ontologies further qualify the patient severity of illness and likelihood of mortality, which are recorded here.