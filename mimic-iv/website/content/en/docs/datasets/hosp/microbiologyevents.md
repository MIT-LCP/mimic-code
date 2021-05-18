---
title: "microbiologyevents"
linktitle: "microbiologyevents"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## *microbiologyevents*

Microbiology tests are a common procedure to check for infectious growth and to assess which antibiotic treatments are most effective.

The table is best explained with a demonstrative example. If a blood culture is requested for a patient, then a blood sample will be taken and sent to the microbiology lab.
The time at which this blood sample is taken is the `charttime`.
The `spec_type_desc` will indicate that this is a blood sample.
Bacteria will be cultured on the blood sample, and the remaining columns depend on the outcome of this growth:

* If no growth is found, the remaining columns will be NULL
* If bacteria is found, then each organism of bacteria will be present in `org_name`, resulting in multiple rows for the single specimen (i.e. multiple rows for the given `spec_type_desc`).
* If antibiotics are tested on a given bacterial organism, then each antibiotic tested will be present in the `ab_name` column (i.e. multiple rows for the given `org_name` associated with the given `spec_type_desc`). Antibiotic parameters and sensitivities are present in the remaining columns (`dilution_text`, `dilution_comparison`, `dilution_value`, `interpretation`).

## Links to

* d_micro on `spec_itemid`
* d_micro on `test_itemid`
* d_micro on `org_itemid`
* d_micro on `ab_itemid`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER
`hadm_id` | INTEGER
`stay_id` | INTEGER
`micro_specimen_id` | INTEGER NOT NULL
`chartdate` | TIMESTAMP(0) NOT NULL
`charttime` | TIMESTAMP(0)
`spec_itemid` | INTEGER NOT NULL
`spec_type_desc` | VARCHAR(100) NOT NULL
`test_seq` | INTEGER NOT NULL
`storedate` | TIMESTAMP(0)
`storetime` | TIMESTAMP(0)
`test_itemid` | INTEGER
`test_name` | VARCHAR(100)
`test_text` | VARCHAR
`org_itemid` | INTEGER
`org_name` | VARCHAR(100)
`isolate_num` | SMALLINT
`quantity` | VARCHAR(50)
`ab_itemid` | INTEGER
`ab_name` | VARCHAR(30)
`dilution_text` | VARCHAR(10)
`dilution_comparison` | VARCHAR(20)
`dilution_value` | DOUBLE PRECISION
`interpretation` | VARCHAR(5)
`comments` | TEXT

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `stay_id`

{{% include "/static/include/stay_id.md" %}}


## `chartdate`, `charttime`

`charttime` records the time at which an observation was charted, and is usually the closest proxy to the time the data was actually measured.
`chartdate` is the same as `charttime`, except there is no time available.

`chartdate` was included as time information is not always available for microbiology measurements: in order to be clear about when this occurs, `charttime` is null, and `chartdate` contains the date of the measurement.

In the cases where both `charttime` and `chartdate` exists, `chartdate` is equal to a truncated version of `charttime` (i.e. `charttime` without the timing information). Not all observations have a `charttime`, but all observations have a `chartdate`.

## `spec_itemid`, `spec_type_desc`

The specimen which is tested for bacterial growth.
The specimen is a sample derived from a patient; e.g. blood, urine, sputum, etc.

## `org_itemid`, `org_name`

The organism, if any, which grew when tested. If NULL, no organism grew (i.e. a negative culture).

## `isolate_num`

For testing antibiotics, the isolated colony (integer; starts at 1).

## `ab_itemid`, `ab_name`

If an antibiotic was tested against the given organism for sensitivity, the antibiotic is listed here.

## `dilution_text`, `dilution_comparison`, `dilution_value`

Dilution values when testing antibiotic sensitivity.

## `interpretation`

`interpretation` of the antibiotic sensitivity, and indicates the results of the test. "S" is sensitive, "R" is resistant, "I" is intermediate, and "P" is pending.

### `comments`

Deidentified free-text comments associated with the microbiology measurement. Usually these provide information about the sample, whether any notifications were made to care providers regarding the results, considerations for interpretation, or in some cases the comments contain the result of the measurement itself. Comments which have been fully deidentified (i.e. no information content retained) are present as three underscores: `___`. A `NULL` comment indicates no comment was made for the row.
