+++
title = "Chartevents"
linktitle = "chartevents"
weight = 10
toc = false

[menu]
  [menu.main]
    parent = "ICU Tables"

+++


# The chartevents table

**Table source:** MetaVision ICU database.

**Table purpose:** Contains all charted data for all patients.

**Number of rows:** 264,885,089

**Links to:**

* PATIENTS on `subject_id`
* ADMISSIONS on `hadm_id`
* ICUSTAYS on `stay_id`
* D_ITEMS on `itemid`

# Brief summary

CHARTEVENTS contains all the charted data available for a patient. During their ICU stay, the primary repository of a patient's information is their electronic chart. The electronic chart displays patients' routine vital signs and any additional information relevant to their care: ventilator settings, laboratory values, code status, mental status, and so on. As a result, the bulk of information about a patient's stay is contained in CHARTEVENTS. Furthermore, even though laboratory values are captured elsewhere (LABEVENTS), they are frequently repeated within CHARTEVENTS. This occurs because it is desirable to display the laboratory values on the patient's electronic chart, and so the values are copied from the database storing laboratory values to the database storing the CHARTEVENTS.

# Important considerations

* Some items are duplicated between the labevents and chartevents tables. In cases where there is disagreement between measurements, labevents should be taken as the ground truth.

# Table columns

Name | Data type
---- | --------
SUBJECT\_ID | Integer
HADM\_ID | Integer
STAY\_ID | Integer
CHARTTIME | Date with times
STORETIME | Date with times
ITEMID | Integer
VALUE | Text
VALUENUM | Decimal number
VALUEUOM | Text
WARNING | Binary (0 or 1)

## `subject_id`, `hadm_id`, `stay_id`

Identifiers which specify the patient: `subject_id` is unique to a patient, `hadm_id` is unique to a patient hospital stay and `stay_id` is unique to a patient ward stay. More information about these identifiers is [available here](/basics/identifiers).

## `CHARTTIME`, `STORETIME`

`CHARTTIME` records the time at which an observation was made, and is usually the closest proxy to the time the data was actually measured. `STORETIME` records the time at which an observation was manually input or manually validated by a member of the clinical staff.

<!-- 

## `CGID`

`CGID` is the identifier for the caregiver who validated the given measurement.

-->

## `ITEMID`

Identifier for a single measurement type in the database. Each row associated with one `ITEMID` (e.g. 212) corresponds to an instantiation of the same measurement (e.g. heart rate).

## `VALUE`, `VALUENUM`

`VALUE` contains the value measured for the concept identified by the `ITEMID`. If this value is numeric, then `VALUENUM` contains the same data in a numeric format. If this data is not numeric, `VALUENUM` is null. In some cases (e.g. scores like Glasgow Coma Scale, Richmond Sedation Agitation Scale and Code Status), `VALUENUM` contains the score and `VALUE` contains the score and text describing the meaning of the score.

## `VALUEUOM`

`VALUEUOM` is the unit of measurement for the `VALUE`, if appropriate.

## `WARNING`

`WARNING` specifies if a warning for this observation was manually documented by the care provider.