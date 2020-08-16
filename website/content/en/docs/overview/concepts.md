---
title: "Core concepts"
linktitle: "Concepts"
date: 2020-08-10
weight: 10
description: >
  A few key concepts when working with MIMIC-IV.
---

<!-- 
# Types of data in the database

Data within MIMIC were recorded during routine clinical care and *not* explicitly for the purpose of retrospective data analysis. This is a key point to keep in mind when analyzing the data.

There are two types of data in the database: static data and dynamic data. Static data is recorded once for a given identifier. An example of static data is the `dob` column in the PATIENTS table. Each patient has only one date of birth, which does not change over time and is not recorded with an associated timestamp. An example of dynamic data is a patient's blood pressure, which is periodically measured during a hospital stay.

This distinction between static data and dynamic data is merely a helpful conceptual construct: there is *no* strict technical distinction between date of birth and heart rate. However, static data tends to not have an associated `ITEMID` (as there is no need to repeatedly record values for static data), whereas dynamic data have an `ITEMID` to facilitate efficient storage of repeated measurements.

# Static data
-->

# Patient identifiers

Patients are identified in the database using three possible identifiers: `subject_id`, `hadm_id`, and `stay_id`.
Every unique patient is assigned a unique `subject_id`, all unique hospitalizations are assigned a unique `hadm_id`, and finally all unique ward stays are assigned a unique `transfer_id`. In this context, a ward is a distinct area of the hospital, and a new `transfer_id` is assigned to a patient if the hospital patient tracking system records that they have been moved from one room to another.

However, many patients will move from one specific location to another, but practically their type of care has not changed. A good example is a patient moving bed locations within an ICU: these changes result in the patient having a new `transfer_id`, but the patient never left the ICU and we would consider this as a continuous episode of care. In order to alleviate this issue, we have created a `stay_id`, which is retained across all ward stays of the same type occurring within 24 hours of each other. That is, if a patient leaves and returns to the ICU within 24 hours, they will have the same `stay_id` for the second ICU stay.

## `subject_id`

The PATIENTS table contains information for each unique `subject_id`. `subject_id` is sourced from the hospital, and is an anonymized version of a patient's medical record number.

## `hadm_id`

The ADMISSIONS table contains information for each unique `hadm_id`. `hadm_id` is sourced from the hospital, and is an anonymized version of an identifier assigned to each patient hospitalization.

## `transfer_id`

The transferS table contains information for each unique `transfer_id`. `transfer_id` is an artificially generated identifier which is uniquely assigned to a ward stay for an individual patient.

## `stay_id`

The transferS table also contains the `stay_id`. This is an artificially generated identifier which groups reasonably contiguous episodes of care.

# date and times

Columns which store a date and time in the database are stored with one of two suffixes: `time` or `date`.
If a column has `time` as the suffix, e.g. `charttime`, then the data resolution is down to the minute. If the column has `date` as the suffix, e.g. `chartdate`, then the data resolution is down to the day. That means that measurements in a `chartdate` column will always have 00:00:00 has the hour, minute, and second values. This does *not* mean it was recorded at midnight: it indicates that we do not have the exact time, only the date.

## Date shifting

All dates in the database have been shifted to protect patient confidentiality. dates will be internally consistent for the same patient, but randomly distributed in the future. dates of birth which occur in the present time are *not* true dates of birth. Furthermore, dates of birth which occur before the year 1900 occur if the patient is older than 89. In these cases, the patient's age at their first admission has been fixed to 300.

## `charttime` vs `storetime`

Most data, with the exception of patient related demographics, are recorded with a time indicating when the observation was made: `charttime`. `charttime` dates back to the use of paper charts: in order to facilitate efficient observations by nursing staff, the day was separated into hourly blocks, and observations were recorded within these hourly blocks. Thus, any time one performed a measurement between the hours of 04:00 and 05:00, the data would be charted in the 04:00 block, and so on. This concept has carried forward into the electronic recording of data: even if data is recorded at 04:23, in many cases it is still charted as occurring at 04:00.

`storetime` provides information on the recording of the data element itself. All observations in the database must be validated before they are archived into the patient medical record. The `storetime` provides the exact time that this validation occurred. For example, a heart rate may be charted at 04:00, but only validated at 04:40. This indicates that the care provider validated the measurement at 4:40 and indicated that it was a valid observation of the patient at 04:00.
Conversely, it's also possible that the `storetime` occurs *before* the `charttime`. While a Glasgow Coma Scale may be charted at a `charttime` of 04:00, the observation may have been made and validated slightly before (e.g. 3:50). Again, the validation implies that the care staff believed the measurement to be an accurate reflection of the patient status at the given `charttime`.

To recap:

* `charttime` is the time at which a measurement is *charted*. In almost all cases, this is the time which best matches the time of actual measurement. In the case of continuous vital signs (heart rate, respiratory rate, invasive blood pressure, non-invasive blood pressure, oxygen saturation), the `charttime` is usually exactly the time of measurement.
* `storetime` is the time at which the data is recorded in the database: logically it occurs after `charttime`, often by hours, but usually not more than that.

## Other date and time columns present in the database

### `chartdate`

`chartdate` is equivalent to `charttime`, except it does not contain any information on the time (all hour, minute, and seconds are 0 for these measurements).

### `admittime`, `dischtime`, `deathtime`

`admittime` and `dischtime` are the hospital admission and discharge times, respectively. `deathtime` is the time of death of a patient if they died *in* hospital. If the patient did not die within the hospital for the given hospital admission, `deathtime` will be null.

### `intime`, `outtime`

`intime` and `outtime` provide the time at which a patient entered and exited the given unit. In the ICUSTAYS table, the unit is always an ICU. In the transferS table, the unit can be any ward in the hospital.

### `starttime`, `endtime`

For events which occur over a period of time, `starttime` and `endtime` provide the beginning and end time of the event. For medical infusions, these columns indicate the period over which the substance was administered.

### `dod`

`dod` is the patient's date of death: sourced either from the hospital database.

### `transfertime`

`transfertime` is the time at which the patient's service changes.

<!--

## Automatic synchronization of data

Many of the monitors in the ICU continuously update the ICU database with observations of the patient. For example, patients with an ECG (i.e. almost all ICU patients) have a heart rate continuously input into the database every minute. However, casual inspection of the database will indicate that heart rate is documented far less frequently than once per minute. In fact, it is usually documented once per hour. The reason for this is because the minute by minute heart rate values are not *validated*. The process of data validation involves a nurse manually right clicking the observation and selecting "validate" from a drop down menu. All charted values in the database have been validated by a nursing staff. In routine clinical practice, the nurse only validates the patient's vital signs on an hourly basis. As a result, only these hourly observations constitute the data available in the database. The time at which the data is validated is recorded in the database in the `storetime` field. Note that a nurse can validate multiple observations at the same time. The user who validates the data is typically recorded in the `CGID` column - linking this to the `CAREGIVERS` table allows one to inspect the role of the caregiver who validated the data (RN, etc).

Putting this all together, let's consider recording the heart rate of a single patient. The heart rate will be continuously uploaded to the ICU database. Nurse A decides to review the flowsheet of the patient they are assigned at 19:41 (note that the "flowsheet" summarizes all the patient observations and is essentially a front end to the database). Nurse A notes that for the past three hours the heart rate has not been validated (it appears as italic text). The nurse will review the measurements, ensure that they are physiologically reasonable and match nurse A's observations of the patient for the past three hours. Then, nurse A selects the past three hours of heart rate measurements (17:00, 18:00 and 19:00) and selects "validate" from a drop down menu. Visually, the text of these measurements changes from italics to bold weight. Technically, the data has been marked as validated and will be archived in the database. The `charttime` for these three measurements will be 17:00, 18:00 and 19:00. The `storetime` for all three measurements will be 19:41.

-->
