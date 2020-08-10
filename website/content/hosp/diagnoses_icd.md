+++
title = "ICD diagnoses"
linktitle = "diagnoses_icd"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++

## *diagnoses_icd*

During routine hospital care, patients are billed by the *hospital* for diagnoses associated with their hospital stay.
This table contains a record of all diagnoses a patient was billed for during their hospital stay using the ICD-9 and ICD-10 ontologies.
Diagnoses are billed on hospital discharge, and are determined by trained persons who read signed clinical notes.

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER
`hadm_id` | INTEGER
`seq_num` | INTEGER
`icd_code` | CHAR(7)
`icd_version` | INTEGER

## Detailed Description

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `seq_num`

The priority assigned to the diagnoses.
The priority can be interpreted as a ranking of which diagnoses are "important", but many caveats to this broad statement exist.
For example, patients who are diagnosed with sepsis must have sepsis as their *2nd* billed condition. The 1st billed condition must be the infectious agent.
There's also less importance placed on ranking low priority diagnoses "correctly" (as there may be no correct ordering of the priority of the 5th - 10th diagnosis codes, for example).

### `icd_code`, `icd_version`

`icd_code` is the International Coding Definitions (ICD) code.

There are two versions for this coding system: version 9 (ICD-9) and version 10 (ICD-10). These can be differentiated using the `icd_version` column.
In general, ICD-10 codes are more detailed, though code mappings (or "cross-walks") exist which convert ICD-9 codes to ICD-10 codes.

Both ICD-9 and ICD-10 codes are often presented with a decimal. This decimal is not required for interpretation of an ICD code; i.e. the `icd_code` of '0010' is equivalent to '001.0'.
