+++
title = "Times"
linktitle = "Times"
weight = 2
toc = "false"

[menu]
  [menu.main]
    parent = "Basics"

+++

# Time types

Time in the database is stored with one of two suffixes: `TIME` and `DATE`. If a column has `TIME` as the suffix, e.g. `CHARTTIME`, then the data resolution is down to the minute. If the column has `DATE` as the suffix, e.g. `CHARTDATE`, then the data resolution is down to the day. That means that measurements in a `CHARTDATE` column will always have 00:00:00 has the hour, minute, and second values. This does *not* mean it was recorded at midnight: it indicates that we do not have the exact time, only the date.

# Date shifting

All dates in the database have been shifted to protect patient confidentiality. Dates will be internally consistent for the same patient, but randomly distributed in the future. Dates of birth which occur in the present time are *not* true dates of birth. Furthermore, dates of birth which occur before the year 1900 occur if the patient is older than 89. In these cases, the patient's age at their first admission has been fixed to 300.

# Time columns in the database

## `CHARTTIME` vs `STORETIME`

Most data, with the exception of patient related demographics, are recorded with a time indicating when the observation was made: `CHARTTIME`. `CHARTTIME` dates back to the use of paper charts: in order to facilitate efficient observations by nursing staff, the day was separated into hourly blocks, and observations were recorded within these hourly blocks. Thus, any time one performed a measurement between the hours of 04:00 and 05:00, the data would be charted in the 04:00 block, and so on. This concept has carried forward into the electronic recording of data: even if data is recorded at 04:23, in many cases it is still charted as occurring at 04:00.

`STORETIME` provides information on the recording of the data element itself. All observations in the database must be validated before they are archived into the patient medical record. The `STORETIME` provides the exact time that this validation occurred. For example, a heart rate may be charted at 04:00, but only validated at 04:40. This indicates that the care provider validated the measurement at 4:40 and indicated that it was a valid observation of the patient at 04:00.
Conversely, it's also possible that the `STORETIME` occurs *before* the `CHARTTIME`. While a Glasgow Coma Scale may be charted at a `CHARTTIME` of 04:00, the observation may have been made and validated slightly before (e.g. 3:50). Again, the validation implies that the care staff believed the measurement to be an accurate reflection of the patient status at the given `CHARTTIME`.

## Summing up: `CHARTTIME` vs. `STORETIME`

`CHARTTIME` is the time at which a measurement is *charted*. In almost all cases, this is the time which best matches the time of actual measurement. In the case of continuous vital signs (heart rate, respiratory rate, invasive blood pressure, non-invasive blood pressure, oxygen saturation), the `CHARTTIME` is usually exactly the time of measurement. `STORETIME` is the time at which the data is recorded in the database: logically it occurs after `CHARTTIME`, often by hours, but usually not more than that.

## CHARTDATE

`CHARTDATE` is equivalent to `CHARTTIME`, except it does not contain any information on the time (all hour, minute, and seconds are 0 for these measurements).

## ADMITTIME, DISCHTIME, DEATHTIME

`ADMITTIME` and `DISCHTIME` are the hospital admission and discharge times, respectively. `DEATHTIME` is the time of death of a patient if they died *in* hospital. If the patient did not die within the hospital for the given hospital admission, `DEATHTIME` will be null.

## CREATETIME, UPDATETIME, ACKNOWLEDGETIME, OUTCOMETIME, FIRSTRESERVATIONTIME, CURRENTRESERVATIONTIME

`CREATETIME` is the time at which an ICU discharge was requested for a given patient. `UPDATETIME` is the time which the ICU discharge request was updated. `ACKNOWLEDGETIME` was the time at which the discharge request was acknowledged by the transfers team. `OUTCOMETIME` is the time at which the ICU discharge request was completed (with an outcome of 'Discharged' or 'Canceled'). `FIRSTRESERVATIONTIME` and `CURRENTRESERVATIONTIME` only occur for patients who require certain locations in the hospital.

## INTIME, OUTTIME

`INTIME` and `OUTTIME` provide the time at which a patient entered and exited the given unit. In the ICUSTAYS table, the unit is always an ICU. In the TRANSFERS table, the unit can be any ward in the hospital.

## STARTTIME, ENDTIME

For events which occur over a period of time, `STARTTIME` and `ENDTIME` provide the beginning and end time of the event. For medical infusions, these columns indicate the period over which the substance was administered.

## COMMENTS_DATE

`COMMENTS_DATE` provides the time at which a cancel or edit comment was made for a given order.

## DOB, DOD, DOD_HOSP, DOD_SSN

`DOB` is the patient's date of birth. If the patient is older than 89, their date of birth is set to 300 at their first admission. `DOD` is the patient's date of death: sourced either from the hospital database (`DOD_HOSP`) or the social security database (`DOD_SSN`).

## TRANSFERTIME

`TRANSFERTIME` is the time at which the patient's service changes.

<!--

## Automatic synchronization of data

Many of the monitors in the ICU continuously update the ICU database with observations of the patient. For example, patients with an ECG (i.e. almost all ICU patients) have a heart rate continuously input into the database every minute. However, casual inspection of the database will indicate that heart rate is documented far less frequently than once per minute. In fact, it is usually documented once per hour. The reason for this is because the minute by minute heart rate values are not *validated*. The process of data validation involves a nurse manually right clicking the observation and selecting "validate" from a drop down menu. All charted values in the database have been validated by a nursing staff. In routine clinical practice, the nurse only validates the patient's vital signs on an hourly basis. As a result, only these hourly observations constitute the data available in the database. The time at which the data is validated is recorded in the database in the `STORETIME` field. Note that a nurse can validate multiple observations at the same time. The user who validates the data is typically recorded in the `CGID` column - linking this to the `CAREGIVERS` table allows one to inspect the role of the caregiver who validated the data (RN, etc).

Putting this all together, let's consider recording the heart rate of a single patient. The heart rate will be continuously uploaded to the ICU database. Nurse A decides to review the flowsheet of the patient they are assigned at 19:41 (note that the "flowsheet" summarizes all the patient observations and is essentially a front end to the database). Nurse A notes that for the past three hours the heart rate has not been validated (it appears as italic text). The nurse will review the measurements, ensure that they are physiologically reasonable and match nurse A's observations of the patient for the past three hours. Then, nurse A selects the past three hours of heart rate measurements (17:00, 18:00 and 19:00) and selects "validate" from a drop down menu. Visually, the text of these measurements changes from italics to bold weight. Technically, the data has been marked as validated and will be archived in the database. The `CHARTTIME` for these three measurements will be 17:00, 18:00 and 19:00. The `STORETIME` for all three measurements will be 19:41.

-->
