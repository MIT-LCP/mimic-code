---
title: "Radiology detail"
linktitle: "radiology_detail"
weight: 1
date: 2021-03-02
description: >
  Auxiliary information for radiology notes.
---

## *radiology_detail*

Additional information associated with notes documented in the *radiology* table. Can be linked to the *radiology* table using `note_id`.

## Links to

* *radiology_detail* on `note_id`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`note_id` | VARCHAR(25) NOT NULL
`subject_id` | INTEGER NOT NULL
`field_name` | VARCHAR(255) NOT NULL
`field_value` | TEXT NOT NULL
`field_ordinal` | INTEGER NOT NULL

### `note_id`

A unique identifier for the given note. `note_id` is composed of `subject_id`, the `note_type` (always two characters long), and a monotonically increasing integer, `note_seq`, in the following format: `subject_id`-`note_type`-`note_seq`.

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `field_name`

Each row provides detail regarding a particular aspect of a note. `field_name` is the name given to that aspect. As of MIMIC-IV, v1.0, possible values include:

* addendum_note_id
* parent_note_id
* cpt_code
* exam_code
* exam_name

### `field_value`

`field_value` is the value associated with the given `field_name`, associated with a note. For example, for the `field_name` of 'author', the `field_value` column contains the author of the note.
