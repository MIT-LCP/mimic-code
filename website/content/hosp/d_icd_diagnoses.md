+++
title = "Dimension table: ICD diagnoses"
linktitle = "d_icd_diagnoses"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++


## The d_icd_diagnoses table

This table defines International Classification of Diseases (ICD) Version 9 and 10 codes for **diagnoses**. These codes are assigned at the end of the patient's stay and are used by the hospital to bill for care provided.

### Links to

* *diagnoses_icd* ON `icd_code`

<!-- # Important considerations -->

## Table columns

Name | Postgres data type
---- | ----
`icd_code` | VARCHAR(10)
`icd_version` | INTEGER
`long_title`  | VARCHAR(300)

## Detailed Description

### `icd_code`, `icd_version`

`icd_code` is the International Coding Definitions (ICD) code.

There are two versions for this coding system: version 9 (ICD-9) and version 10 (ICD-10). These can be differentiated using the `icd_version` column.
In general, ICD-10 codes are more detailed, though code mappings (or "cross-walks") exist which convert ICD-9 codes to ICD-10 codes.

Both ICD-9 and ICD-10 codes are often presented with a decimal. This decimal is not required for interpretation of an ICD code; i.e. the `icd_code` of '0010' is equivalent to '001.0'.

ICD-9 and ICD-10 codes have distinct formats: ICD-9 codes are 5 character long strings which are entirely numeric (with the exception of codes prefixed with "E" or "V" which are used for external causes of injury or supplemental classification). Importantly, ICD-9 codes are retained as strings in the database as the leading 0s in codes are meaningful.

ICD-10 codes are 3-7 characters long and always prefixed by a letter followed by a set of numeric values.

### `long_title`

The `long_title` provides the meaning of the ICD code. For example, the ICD-9 code 0010 has `long_title` "Cholera due to vibrio cholerae".
