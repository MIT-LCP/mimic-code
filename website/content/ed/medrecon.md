+++
title = "Medicine Reconciliation"
linktitle = "medrecon"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "ED Tables"

+++

# The MEDRECON table

On admission to the emergency departments, staff will ask the patient what current medications they are taking. This process is called medicine reconciliation, and the MEDRECON table stores the findings of the care providers.

**Table source:** Emergency department database.

**Table purpose:** Document medications a patient is currently taking.

**Number of rows:** 

**Links to:**

* MAIN on `stay_id`

<!-- # Important considerations -->

# Table columns

Name | Postgres data type
---- | ----
`stay_id`         | INT NOT NULL
`charttime`       | TIMESTAMP(0)
`name`            | VARCHAR(255)
`gsn`             | VARCHAR(10)
`ndc`             | VARCHAR(12)
`etc_rn`          | SMALLINT NOT NULL
`etccode`         | VARCHAR(8)
`etcdescription`  | VARCHAR(255)

## `stay_id`

An identifier which uniquely identifies a single emergency department stay for a single patient.

## `charttime`

The time at which the medicine reconciliation was charted.

## `name`

The name of the medication.

## `gsn`

A code for the medication.

## `ndc`

The National Drug Code (ndc) for the medication.

## `etc_rn`, `etccode`, `etcdescription`

Medications are grouped using a hierarchical ontology. As more than one group may be associated with the medication, `etc_rn` is used to differentiate the groups (there is no meaning to the order of `etc_rn`). `etccode` provides the code and `etcdescription` provides the description of the group.