---
title: "Provider Order Entry detail"
linktitle: "poe_detail"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## *poe_detail*

The *poe_detail* table provides further information on POE orders. The table uses an Entity-Attribute-Value (EAV) model: the entity is `poe_id`, the attribute is `field_name`, and the value is `field_value`.
EAV tables allow for flexible description of entities when the attributes are heterogenous.

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
`field_name` | VARCHAR(255)
`field_value` | TEXT

### `poe_id`

A unique identifier for the given order. `poe_id` is composed of `subject_id` and a monotonically increasing integer, `poe_seq`, in the following format: `subject_id`-`poe_seq`.

### `poe_seq`

A monotonically increasing integer which chronologically sorts the POE orders. That is, POE orders can be ordered sequentially by `poe_seq`.

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `field_name`

Each row provides detail regarding a particular aspect of a POE order. `field_name` is the name given to that aspect. It is one of the following values:

* Admit category
* Admit to
* Code status
* Consult Status
* Consult Status Time
* Discharge Planning
* Discharge When
* Indication
* Level of Urgency
* Transfer to
* Tubes & Drains type

### `field_value`

`field_value` is the value associated with the given POE order and `field_name`. For example, for the `field_name` of 'Admit to', the `field_value` column contains the type of unit the patient was admitted to (Psychiatry, GYN, and so on).
