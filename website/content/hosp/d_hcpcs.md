+++
title = "Dimension table: hcpcs"
linktitle = "d_hcpcs"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++

## The d_hcpcs table

The D_HCPCS table is used to acquire human readable definitions for the codes used in the HCPCSEVENTS table. The concepts primarily correspond to hospital billing.

### Links to

* HCPCSEVENTS on `code`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`code` | CHAR(5)
`category` | SMALLINT
`long_description` | TEXT
`short_description` | VARCHAR(180)

## Detailed description

### `code`

A five character code which uniquely represents the event.

### `category`

Broad classification of the code.

### `long_description`, `short_description`

Textual descriptions of the `code` listed for the given row.
