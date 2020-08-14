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
`spec_id` | VARCHAR(8) NOT NULL
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

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}
