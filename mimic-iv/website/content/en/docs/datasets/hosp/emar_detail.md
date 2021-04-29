---
title: "eMAR details"
linktitle: "emar_detail"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## *emar_detail*

The *emar_detail* table contains information for each medicine administration made in the EMAR table.
Information includes the associated pharmacy order, the dose due, the dose given, and many other parameters associated with the medical administration.

## Links to

* *emar* on `emar_id`
* *pharmacy* on `pharmacy_id`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER NOT NULL
`emar_id` | VARCHAR(25) NOT NULL
`emar_seq` | INTEGER NOT NULL
`parent_field_ordinal` | NUMERIC(5, 3)
`administration_types` | VARCHAR(50)
`pharmacy_id` | INTEGER
`barcode_type` | VARCHAR(4)
`Reason_for_No_Barcode` | TEXT
`Complete_Dose_Not_Given` | VARCHAR(5)
`Dose_Due` | VARCHAR(50)
`Dose_Due_Unit` | VARCHAR(50)
`Dose_Given` | VARCHAR(255)
`Dose_Given_Unit` | VARCHAR(50)
`will_remainder_of_dose_be_given` | VARCHAR(5)
`Product_Amount_Given` | VARCHAR(30)
`Product_Unit` | VARCHAR(30)
`Product_Code` | VARCHAR(30)
`Product_Description` | VARCHAR(255)
`Product_Description_Other` | VARCHAR(255)
`Prior_Infusion_Rate` | VARCHAR(20)
`Infusion_Rate` | VARCHAR(20)
`Infusion_Rate_Adjustment` | VARCHAR(50)
`Infusion_Rate_Adjustment_Amount` | VARCHAR(30)
`Infusion_Rate_Units` | VARCHAR(30)
`Route` | VARCHAR(5)
`Infusion_Complete` | VARCHAR(255)
`Completion_Interval` | VARCHAR(30)
`New_IV_Bag_Hung` | VARCHAR(1)
`Continued_infusion_in_other_location` | VARCHAR(1)
`Restart_Interval` | VARCHAR(30)
`Side` | VARCHAR(10)
`Site` | VARCHAR(255)
`non_formulary_visual_verification` | VARCHAR(1)

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `emar_id`, `emar_seq`

Identifiers for the eMAR table. `emar_id` is a unique identifier for each order made in eMAR. `emar_seq` is a consecutive integer which numbers eMAR orders chronologically. `emar_id` is composed of `subject_id` and `emar_seq` in the following pattern: '`subject_id`-`emar_seq`'.

### `parent_field_ordinal`

`parent_field_ordinal` delineates multiple administrations for the same eMar event, e.g. multiple formulary doses for the full dose. As eMAR requires the administrating provider to scan a barcode for *each* formulary provided to the patient, it is often the case that multiple rows in *emar_detail* correspond to a single row in *emar* (e.g. multiple pills are administered which add up to the desired dose). There is one row per eMAR order with a NULL `parent_field_ordinal`: this row usually contains the desired dose for the administration. Afterward, if there are N formulary doses, `parent_field_ordinal` will take values '1.1', '1.2', ..., '1.N'. The most common case occurs when there is only one formulary dose per medication. In this case the `emar_id` will have two rows in the *emar_detail* table: one with a NULL value for `parent_field_ordinal` (usually providing the dose due), and one row with a value of '1.1' for `parent_field_ordinal` (usually providing the actual dose administered).

### `administration_types`

The type of administration, including 'IV Bolus', 'IV Infusion', 'Medication Infusion', 'Transdermal Patch', and so on.

### `pharmacy_id`

An identifier which allows linking the eMAR order to pharmacy information provided in the *pharmacy* table. Note: rarely the same `emar_id` may have multiple distinct `pharmacy_id` across rows in the *emar_detail* table.

### Remaining columns

The remaining columns provide information about the delivery of the formulary dose of the administered medication.

