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
`specimen_id` | INTEGER NOT NULL
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
`comments` | TEXT


### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `stay_id`

{{% include "/static/include/stay_id.md" %}}

### `specimen_id`

Uniquely denoted the specimen from which the lab measurement was made. Most lab measurements are made on patient derived samples (specimens) such as blood, urine, and so on.
Often multiple measurements are made on the same sample. The `specimen_id` will group measurements made on the same sample, e.g. blood gas measurements made on the same sample of blood.

### `itemid`

An identifier which uniquely denotes laboratory concepts.

### `charttime`

The time at which the laboratory measurement was charted. This is usually the time at which the specimen was acquired, and is usually significantly **earlier** than the time at which the measurement is available.

### `storetime`

The time at which the measurement was made available in the laboratory system. This is when the information would have been available to care providers.

### `value`, `valuenum`

The result of the laboratory measurement and, if it is numeric, the value cast as a numeric data type.

### `valueuom`

The unit of measurement for the laboratory concept.

### `ref_range_lower`, `ref_range_upper`

Upper and lower reference ranges indicating the normal range for the laboratory measurements. Values outside the reference ranges are considered abnormal.

### `flag`

A brief string mainly used to indicate if the laboratory measurement is abnormal.

### `priority`

The priority of the laboratory measurement: either routine or stat (urgent).

### `comments`

Deidentified free-text comments associated with the laboratory measurement. Usually these provide information about the sample, whether any notifications were made to care providers regarding the results, considerations for interpretation, or in some cases the comments contain the result of the laboratory itself. Comments which have been fully deidentified (i.e. no information content retained) are present as three underscores: `___`. A `NULL` comment indicates no comment was made for the row.
