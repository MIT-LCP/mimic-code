+++
title = "Provider Order Entry"
linktitle = "poe"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++

## *poe*

Provider order entry (POE) is the general interface through which care providers at the hospital enter orders. Most treatments and procedures must be ordered via POE.

## Links to

* *poe_detail* on `poe_id`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`poe_id` | VARCHAR(25) NOT NULL
`poe_seq` | INTEGER NOT NULL
`subject_id` | INTEGER NOT NULL
`hadm_id` | INTEGER NOT NULL
`ordertime` | TIMESTAMP NOT NULL
`order_type` | VARCHAR(25)
`order_subtype` | VARCHAR(50)
`transaction_type` | VARCHAR(15)
`discontinue_of_poe_id` | VARCHAR(25)
`discontinued_by_poe_id` | VARCHAR(25)
`order_status` | VARCHAR(15)

### `poe_id`

A unique identifier for the given order. `poe_id` is composed of `subject_id` and a monotonically increasing integer, `poe_seq`, in the following format: `subject_id`-`poe_seq`.

### `poe_seq`

A monotonically increasing integer which chronologically sorts the POE orders. That is, POE orders can be ordered sequentially by `poe_seq`.

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `ordertime`

The date and time at which the provider order was made.

### `order_type`

The type of provider order. One of the following:

* ADT orders
* Blood Bank
* Cardiology
* Consults
* Critical Care
* General Care
* Hemodialysis
* IV therapy
* Lab
* Medications
* Neurology
* Nutrition
* OB
* Radiology
* Respiratory
* TPN

### `order_subtype`

Further detail on the type of order made by the provider. The `order_subtype` is best interpreted alongside the `order_type`, e.g. `order_type = 'Cardiology'` with `order_subtype = 'Holter Monitor'`.

### `transaction_type`

The action which the provider performed when performing this order. One of the following:

* Change
* Co
* D/C
* H
* New
* T

### `discontinue_of_poe_id`, `discontinued_by_poe_id`

If this order discontinues a previous order, then `discontinue_of_poe_id` will link to the previous order which was discontinued.
Conversely, if this order was later discontinued by a distinct order, then `discontinued_by_poe_id` will link to that future order.

### `order_status`

Whether the order is still active ('Active') or whether it has been inactivated ('Inactive').
