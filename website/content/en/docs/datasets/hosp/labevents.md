---
title: "labevents"
linktitle: "labevents"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## *labevents*

The *labevents* table stores the results of all laboratory measurements made for a single patient.
These include hematology measurements, blood gases, chemistry panels, and less common tests such as genetic assays.

## Links to

* *d_labitems* on `itemid`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER NOT NULL
`hadm_id` | INTEGER
`stay_id` | INTEGER
`spec_id` | INTEGER NOT NULL
`itemid` | INTEGER NOT NULL
`charttime` | TIMESTAMP NOT NULL
`storetime` | TIMESTAMP
`value` | VARCHAR(200)
`valuenum` | DOUBLE PRECISION
`valueuom` | VARCHAR(20)
`ref_range_lower` | DOUBLE PRECISION
`ref_range_upper` | DOUBLE PRECISION
`flag` | VARCHAR(10)
`priority` | VARCHAR(7)


### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}
