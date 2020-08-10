+++
title = "Dimension table: items"
linktitle = "d_items"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "ICU Tables"

+++


# The d_items table

**Table source:** Metavision ICU databases.

**Table purpose:** Definition table for all items in the ICU databases.

**Number of rows:** 3,816

**Links to:**

* CHARTEVENTS on `ITEMID`
* DATETIMEEVENTS on `ITEMID`
* INPUTEVENTS on `ITEMID`
* OUTPUTEVENTS on `ITEMID`
* PROCEDUREEVENTS on `ITEMID`

# Important considerations

* If the `LINKSTO` column is null, then the data is currently unavailable, but planned for a future release.

# Table columns

Name | Postgres data type
---- | ----
ITEMID | INT
LABEL | VARCHAR(200)
ABBREVIATION | VARCHAR(100)
LINKSTO | VARCHAR(50)
CATEGORY | VARCHAR(100)
UNITNAME | VARCHAR(100)
PARAM\_TYPE | VARCHAR(30)
LOWNORMALVALUE | Floating point number
HIGHNORMALVALUE | Floating point number

# Detailed Description

The D_ITEMS table defines `ITEMID`, which represents measurements in the database. Measurements of the same type (e.g. heart rate) will have the same `ITEMID` (e.g. 220045). Values in the `ITEMID` column are unique to each row. All `ITEMID`s will have a value > 220000.

## `ITEMID`

As an alternate primary key to the table, `ITEMID` is unique to each row.

## `LABEL`, `ABBREVIATION`

The `LABEL` column describes the concept which is represented by the `ITEMID`. The `ABBREVIATION` column, only available in Metavision, lists a common abbreviation for the label.

## `LINKSTO`

`LINKSTO` provides the table name which the data links to. For example, a value of 'chartevents' indicates that the `ITEMID` of the given row is contained in CHARTEVENTS. A single `ITEMID` is only used in one event table, that is, if an `ITEMID` is contained in CHARTEVENTS it will *not* be contained in any other event table (e.g. IOEVENTS, CHARTEVENTS, etc).

## `CATEGORY`

`CATEGORY` provides some information of the type of data the `ITEMID` corresponds to. Examples include 'ABG', which indicates the measurement is sourced from an arterial blood gas, 'IV Medication', which indicates that the medication is administered through an intravenous line, and so on.

## `UNITNAME`

`UNITNAME` specifies the unit of measurement used for the `ITEMID`. This column is not always available, and this may be because the unit of measurement varies, a unit of measurement does not make sense for the given data type, or the unit of measurement is simply missing. Note that there is sometimes additional information on the unit of measurement in the associated event table, e.g. the `VALUEUOM` column in CHARTEVENTS.

## `PARAM_TYPE`

`PARAM_TYPE` describes the type of data which is recorded: a date, a number or a text field.

## `LOWNORMALVALUE`, `HIGHNORMALVALUE`

These columns store reference ranges for the measurement. Note that a reference range encompasses the *expected* value of a measurement: values outside of this may still be physiologically plausible, but are considered unusual.