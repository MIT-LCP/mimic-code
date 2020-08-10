+++
title = "Dimension table: microbiology items"
linktitle = "d_micro"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++

## *d_micro*

Definition table for all microbiology measurements.

### Links to

* microbiologyevents on `itemid`

## Table columns

Name | Postgres data type 
---- | ---- 
`itemid` | INTEGER
`label` | VARCHAR(200)
`category` | VARCHAR(100)

## Detailed Description

### `itemid`

As the primary key of the table, `itemid` is unique to each row.

### `label`

The `label` column describes the concept which is represented by the `itemid`, e.g. "AMPICILLIN".

### `category`

`category` categorizes the `itemid` into one of four types:

* ANTIBIOTIC
* MICROTEST
* ORGANISM
* SPECIMEN

"SPECIMEN" describes the sample taken to perform the test, "MICROTEST" describes the type of test performed, "ORGANISM" is the biological organism grown, and "ANTIBIOTIC" is the antibiotic used for evaluating sensitivity of an organism.
