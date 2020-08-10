+++
title = "Pyxis"
linktitle = "pyxis"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "ED Tables"

+++

# The PYXIS table

The PYXIS table provides information for medicine administrations made via the Pyxis system.

**Table source:** Emergency department database.

**Table purpose:** Track medicine administrations.

**Number of rows:** 

**Links to:**

* MAIN on `stay_id`

<!-- # Important considerations -->

# Table columns

Name | Postgres data type
---- | ----
`stay_id`   | INT NOT NULL
`charttime` | TIMESTAMP(0)
`med_rn`    | SMALLINT NOT NULL
`name`      | VARCHAR(255)
`ifu`       | VARCHAR(255)
`gsn_rn`    | SMALLINT NOT NULL
`gsn`       | VARCHAR(10)

## `stay_id`

An identifier which uniquely identifies a single emergency department stay for a single patient.

## `charttime`

The time at which the medication was charted, which is the closest approximation to the time the medication was administered.

## `med_rn`

A row number for the medicine.

## `name`

The name of the medicine.

## `ifu`

## `gsn`

A hierarchical ontology which groups the medication.

## `gsn_rn`

As a medicine may be a member of multiple groups in the GSN ontology, this row number differentiates them.