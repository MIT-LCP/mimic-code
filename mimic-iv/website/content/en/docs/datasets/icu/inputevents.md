---
date: "2015-09-01T19:34:46-04:00"
title: "Inputevents"
linktitle: "Inputevents"
weight: 10
date: 2020-08-10
description: >
  ICU level table
---

# The Inputevents table

**Table source:** MetaVision ICU database.

**Table purpose:** Input data for patients.

**Number of rows:** 7,643,978

**Links to:**

* PATIENTS on `subject_id`
* ADMISSIONS on `hadm_id`
* ICUSTAYS on `stay_id`
* D_ITEMS on `ITEMID`

# Brief example

The original source database recorded input data using two tables: RANGESIGNALS and ORDERENTRY. These tables do not appear in MIMIC as they have been merged to form the INPUTEVENTS table. RANGESIGNALS contains recorded data elements which last for a fixed period of time. Furthermore, the RANGESIGNALS table recorded information for each component of the drug separately. For example, for a norepinephrine administration there would be two components: a main order component (norepinephrine) and a solution component (NaCl). The `STARTTIME` and `ENDTIME` of RANGESIGNALS indicated when the drug started and finished. *Any* change in the drug rate would result in the current infusion ending, and a new `STARTTIME` being created.

Let's examine an example of a patient being given norepinephrine.

Item | `STARTTIME` | `ENDTIME` | `RATE` | `RATEUOM` | `ORDERID` | `LINKORDERID`
---- | ---- | ---- | ---- | ---- | ---- | ----
Norepinephrine | 18:20 | 18:25 | 1 | mcg/kg/min | 8003 | 8003
NaCl | 18:20 | 18:25 | 10 | ml/hr | 8003 | 8003
Norepinephrine | 18:25 | 20:00 | 2 | mcg/kg/min | 8020 | 8003
NaCl | 18:25 | 20:00 | 20 | ml/hr | 8020 | 8003

The `STARTTIME` for the solution (NaCl) and the drug (norepinephrine) would be 18:20. The rate of the drug is 1 mcg/kg/min, and the rate of the solution is 10 mL/hr. The nurse decides to increase the drug rate at 18:25 to 2 mcg/kg/min. As a result, the `ENDTIME` for the two rows corresponding to the solution (NaCl and norepinephrine) is set to 18:25. Two new rows are generated with a `STARTTIME` of 18:25. These two new rows would continue until either (i) the drug rate was changed or (ii) the drug was delivery was discontinued. The `ORDERID` column is used to group drug delivery with rate of delivery. In this case, we have NaCl and norepinephrine in the same bag delivered at the same time - as a result their `ORDERID` is the same (8003). When the rate is changed, a new `ORDERID` is generated (8020). The column `LINKORDERID` can be used to link this drug across all administrations, even when the rate is changed. Note also that `LINKORDERID` is always equal to the first `ORDERID` which occurs for the solution, as demonstrated in the example above.

# Important considerations

* For Metavision data, there is no concept of a volume in the database: only a `RATE`. All inputs are recorded with a `STARTTIME` and an `ENDTIME`. As a result, the volumes in the database for Metavision patients are *derived* from the rates. Furthermore, exact start and stop times for the drugs are easily deducible.
* A bolus will be listed as ending one minute after it started, i.e. `ENDTIME`: `STARTTIME` + 1 minute

# Table columns

Name | Postgres data type
---- | ----
ROW\_ID | INT
SUBJECT\_ID | INT
HADM\_ID | INT
ICUSTAY\_ID | INT
STARTTIME | TIMESTAMP(0)
ENDTIME | TIMESTAMP(0)
ITEMID | INT
AMOUNT | DOUBLE PRECISION
AMOUNTUOM | VARCHAR(30)
RATE | DOUBLE PRECISION
RATEUOM | VARCHAR(30)
STORETIME | TIMESTAMP(0)
CGID | BIGINT
ORDERID | BIGINT
LINKORDERID | BIGINT
ORDERCATEGORYNAME | VARCHAR(100)
SECONDARYORDERCATEGORYNAME | VARCHAR(100)
ORDERCOMPONENTTYPEDESCRIPTION | VARCHAR(200)
ORDERCATEGORYDESCRIPTION | VARCHAR(50)
PATIENTWEIGHT | DOUBLE PRECISION
TOTALAMOUNT | DOUBLE PRECISION
TOTALAMOUNTUOM | VARCHAR(50)
ISOPENBAG | SMALLINT
CONTINUEINNEXTDEPT | SMALLINT
CANCELREASON | SMALLINT
STATUSDESCRIPTION | VARCHAR(30)
COMMENTS\_STATUS | VARCHAR(30)
COMMENTS\_TITLE | VARCHAR(100)
COMMENTS\_DATE | TIMESTAMP(0)
ORIGINALAMOUNT | DOUBLE PRECISION
ORIGINALRATE | DOUBLE PRECISION

# Detailed Description

## `subject_id`, `hadm_id`, `stay_id`

Identifiers which specify the patient: `subject_id` is unique to a patient, `hadm_id` is unique to a patient hospital stay and `stay_id` is unique to a patient ICU stay.

<!--

## CGID

`CGID` is the identifier for the caregiver who validated the given measurement.

-->

## `STARTTIME`, `ENDTIME`

`STARTTIME` and `ENDTIME` record the start and end time of an input/output event.

## ITEMID

Identifier for a single measurement type in the database. Each row associated with one `ITEMID` which corresponds to an instantiation of the same measurement (e.g. norepinephrine).
MetaVision `ITEMID` values are all above 220000. Since this data only contains data from MetaVision, it only contains `ITEMID` above 220000 (see [here](/mimicdata/metavision/) for details about MetaVision)

## AMOUNT, AMOUNTUOM

`AMOUNT` and `AMOUNTUOM` list the amount of a drug or substance administered to the patient either between the `STARTTIME` and `ENDTIME`.

## RATE, RATEUOM

`RATE` and `RATEUOM` list the rate at which the drug or substance was administered to the patient either between the `STARTTIME` and `ENDTIME`.

## STORETIME

`STORETIME` records the time at which an observation was manually input or manually validated by a member of the clinical staff.

## ORDERID, LINKORDERID

`ORDERID` links multiple items contained in the same solution together. For example, when a solution of noradrenaline and normal saline is administered both noradrenaline and normal saline occur on distinct rows but will have the same `ORDERID`.

`LINKORDERID` links the same order across multiple instantiations: for example, if the rate of delivery for the solution with noradrenaline and normal saline is changed, two new rows which share the same new `ORDERID` will be generated, but the `LINKORDERID` will be the same.

## ORDERCATEGORYNAME, SECONDARYORDERCATEGORYNAME, ORDERCOMPONENTTYPEDESCRIPTION, ORDERCATEGORYDESCRIPTION

These columns provide higher level information about the order the medication/solution is a part of. Categories represent the type of administration, while the `ORDERCOMPONENTTYPEDESCRIPTION` describes the role of the substance in the solution (i.e. main order parameter, additive, or mixed solution)

## PATIENTWEIGHT

The patient weight in kilograms.

## TOTALAMOUNT, TOTALAMOUNTUOM

Intravenous administrations are usually given by hanging a bag of fluid at the bedside for continuous infusion over a certain period of time. These columns list the total amount of the fluid in the bag containing the solution.

## STATUSDESCRIPTION

```STATUSDESCRIPTION``` states the ultimate status of the item, or more specifically, row. It is used to indicate why the delivery of the compound has ended. There are only six possible statuses:

* Changed - The current delivery has ended as some aspect of it has changed (most frequently, the rate has been changed)
* Paused - The current delivery has been paused
* FinishedRunning - The delivery of the item has finished (most frequently, the bag containing the compound is empty)
* Stopped - The delivery of the item been terminated by the caregiver
* Rewritten - Incorrect information was input, and so the information in this row was rewritten (these rows are primarily useful for auditing purposes - the rates/amounts described were *not* delivered and so should not be used if determining what compounds a patient has received)
* Flushed - A line was flushed.

## ISOPENBAG

Whether the order was from an open bag.

## CONTINUEINNEXTDEPT

If the order ended on patient transfer, this field indicates if it continued into the next department (e.g. a floor).

## CANCELREASON

If the order was canceled, this column provides some explanation.

## COMMENTS\_STATUS, COMMENTS\_TITLE, COMMENTS_DATE

Specifies if the order was edited or canceled, and if so, the date and job title of the care giver who canceled or edited it.

## ORIGINALAMOUNT

Drugs are usually mixed within a solution and delivered continuously from the same bag. This column represents the amount of the drug contained in the bag at `STARTTIME`. For the first infusion of a new bag, `ORIGINALAMOUNT`: `TOTALAMOUNT`. Later on, if the rate is changed, then the amount of the drug in the bag will be lower (as some has been administered to the patient). As a result, `ORIGINALAMOUNT` < `TOTALAMOUNT`, and `ORIGINALAMOUNT` will be the amount of drug leftover in the bag at that `STARTTIME`.

## ORIGINALRATE

This is the rate that was input by the care provider. Note that this may differ from `RATE` because of various reasons: `ORIGINALRATE` was the original planned rate, while the `RATE` column will be the true rate delivered. For example, if a a bag is about to run out and the care giver decides to push the rest of the fluid, then `RATE` > `ORIGINALRATE`.
However, these two columns are usually the same, but have minor non-clinically significant differences due to rounding error.