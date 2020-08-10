+++
title = "Electronic Medical Administration Record"
linktitle = "emar"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++

## *emar*

The EMAR table is used to record administrations of a given medicine to an individual patient.
Records in this table are populated by bedside nursing staff scanning barcodes associated with the medicine and the patient.

## Links to

* *emar_detail* on `emar_id`
* *pharmacy* on `pharmacy_id`
* *prescriptions* on `poe_id`
* *poe* on `poe_id`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER NOT NULL
`hadm_id` | INTEGER NOT NULL
`emar_id` | VARCHAR(100) NOT NULL
`emar_seq` | INTEGER NOT NULL
`poe_id` | VARCHAR(25) NOT NULL
`charttime` | TIMESTAMP NOT NULL
`medication` | TEXT
`event_txt` | TEXT
`scheduletime` | TIMESTAMP
`storetime` | TIMESTAMP NOT NULL

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `emar_id`, `emar_seq`

Identifiers for the eMAR table. `emar_id` is a unique identifier for each order made in eMAR. `emar_seq` is a consecutive integer which numbers eMAR orders chronologically. `emar_id` is composed of `subject_id` and `emar_seq` in the following pattern: '`subject_id`-`emar_seq`'.

### `poe_id`

An identifier which links administrations in *emar* to orders in *poe* and *prescriptions*.

### `pharmacy_id`

An identifier which links administrations in *emar* to pharmacy information in the *pharmacy* table.

### `charttime`

The time at which the medication was administered.

### `medication`

The name of the medication which was administered.

### `event_txt`

Information about the administration. Most frequently `event_txt` is 'Administered', but other possible values are 'Applied', 'Confirmed', 'Delayed', 'Not Given', and so on.

### `scheduletime`

If present, the time at which the administration was scheduled.

### `storetime`

The time at which the administration was documented in the eMAR table.
