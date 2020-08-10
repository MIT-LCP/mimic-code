+++
title = "HCPCS events"
linktitle = "hcpcsevents"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++

## *hcpcsevents*

## Links to

* *d_hcpcs* on hcpcs_cd

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER
`hadm_id` | INTEGER
`hcpcs_cd` | CHAR(5)
`seq_num` | INTEGER
`short_description` | TEXT

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `hcpcs_cd`

A five character code which uniquely represents the event.
Link this to `code` in D_HCPCS for a longer description of the code.

### `seq_num`

An assigned order to HCPCS codes for an individual hospitalization. This order sometimes conveys meaning, e.g. sometimes higher priority, but this is not guaranteed across all codes.

### `short_description`

A short textual descriptions of the `hcpcs_cd` listed for the given row.
