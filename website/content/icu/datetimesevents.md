+++
title = "Datetimeevents"
linktitle = "datetimeevents"
weight = 10
toc = false

[menu]
  [menu.main]
    parent = "ICU Tables"

+++


# The datetimeevents table

**Table source:** MetaVision ICU database.

**Table purpose:** Contains all date formatted data.

**Number of rows:** 5,988,217

**Links to:**

* PATIENTS on `subject_id`
* ADMISSIONS on `hadm_id`
* ICUSTAYS on `STAY_ID`
* D_ITEMS on `itemid`

<!-- # Important considerations -->

# Table columns


Name | Data type
---- | --------
SUBJECT\_ID | Integer
HADM\_ID | Integer
STAY\_ID | Integer
CHARTTIME | Date with times
STORETIME | Date with times
ITEMID | Integer
VALUE | Date with times
VALUEUOM | Text
WARNING | Binary (0 or 1)
	
# Detailed Description

DATETIMEEVENTS contains all date measurements about a patient in the ICU. For example, the date of last dialysis would be in the DATETIMEEVENTS table, but the systolic blood pressure would not be in this table. As all dates in MIMIC are anonymized to protect patient confidentiality, all dates in this table have been shifted. Note that the chronology for an individual patient has been unaffected however, and quantities such as the difference between two dates remain true to reality.

## `subject_id`, `hadm_id`, `stay_id`

Identifiers which specify the patient: `subject_id` is unique to a patient, `hadm_id` is unique to a patient hospital stay and `stay_id` is unique to a patient ward stay.

<!-- 
## `CGID`

`CGID` is the identifier for the caregiver who validated the given measurement.

-->

## `CHARTTIME`, `STORETIME`

`CHARTTIME` records the time at which an observation was charted, and is usually the closest proxy to the time the data was actually measured. `STORETIME` records the time at which an observation was manually input or manually validated by a member of the clinical staff.

## `ITEMID`

Identifier for a single measurement type in the database. Each row associated with one `ITEMID` (e.g. 212) corresponds to an instantiation of the same measurement (e.g. heart rate).

## `VALUE`

The documented date - this is the value that corresponds to the concept referred to by `itemid`. For example, if querying for `itemid` = 225755 ("18 Gauge Insertion Date"), then the `value` column indicates the date the line was inserted.

## `VALUEUOM`

The unit of measurement for the value - almost always the text string "Date".

## `WARNING`

`WARNING` specifies if a warning for this observation was manually documented by the care provider.