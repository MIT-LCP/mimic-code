---
title: "Radiology"
linktitle: "radiology"
weight: 1
date: 2021-03-02
description: >
  Radiology reports
---

## *radiology*

The *radiology* table contains free-text radiology reports associated with radiography imaging. Radiology reports cover a variety of imaging modalities: x-ray, computed tomography, magnetic resonance imaging, ultrasound, and so on. Free-text radiology reports are semi-structured and usually follow a consistent template for a given imaging protocol.

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
`hadm_id` | INTEGER NOT NULL
`note_type` | CHAR(2) NOT NULL
`note_seq` | INTEGER NOT NULL
`charttime` | TIMESTAMP NOT NULL
`storetime` | TIMESTAMP
`text` | TEXT NOT NULL

### `note_id`

A unique identifier for the given note. `note_id` is composed of `subject_id`, the `note_type` (always two characters long), and a monotonically increasing integer, `note_seq`, in the following format: `subject_id`-`note_type`-`note_seq`.

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `note_type`

The type of note recorded in the row. There are two types of note:

* 'RR' - radiology report
* 'AR' - radiology report addendum

### `note_seq`

A monotonically increasing integer which chronologically sorts the notes within `note_type` categories. That is, notes can be ordered sequentially by `note_seq`.

### `charttime`

The time at which the note was charted - this is usually the most relevant time for interpreting the content of the note, but it is not necessarily when the note was fully written.

### `storetime`

The time at which the note was stored in the database. This is usually when the note was completed and signed.
