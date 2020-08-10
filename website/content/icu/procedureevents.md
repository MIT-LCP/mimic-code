+++
title = "Procedureevents"
linktitle = "procedureevents"
weight = 10
toc = false

[menu]
  [menu.main]
    parent = "ICU Tables"

+++


# The procedureevents_mv table

**Table source:** MetaVision ICU database.

**Table purpose:** Contains procedures for patients

**Number of rows:** 592,932

**Links to:**

* PATIENTS on `subject_id`
* ADMISSIONS on `hadm_id`
* ICUSTAYS on `stay_id`
* D_ITEMS on `itemid`

<!-- # Important considerations -->

# Table columns


Name | Data type
---- | --------
SUBJECT\_ID | Integer
HADM\_ID | Integer
STAY\_ID | Integer
ITEMID | Integer
CHARTTIME | Date with times
STORETIME | Date with times
VALUE | Text
VALUENUM | Decimal number
VALUEUOM | Text
WARNING | Binary (0 or 1)
LOCATION |  VARCHAR(30)
LOCATIONCATEGORY |  VARCHAR(30)
STORETIME |  TIMESTAMP(0)
CGID  |  INT
ORDERID |  INT
LINKORDERID |  INT
ORDERCATEGORYNAME |  VARCHAR(100)
SECONDARYORDERCATEGORYNAME |  VARCHAR(100)
ORDERCATEGORYDESCRIPTION |  VARCHAR(50)
ISOPENBAG |  SMALLINT
CONTINUEINNEXTDEPT |  SMALLINT
CANCELREASON |  SMALLINT
STATUSDESCRIPTION |  VARCHAR(30)
COMMENTS_EDITEDBY |  VARCHAR(30)
COMMENTS_CANCELEDBY |  VARCHAR(30)
COMMENTS_DATE |  TIMESTAMP(0)

<!--
# Detailed Description

## `subject_id`, `hadm_id`

Identifiers which specify the patient: `subject_id` is unique to a patient and `hadm_id` is unique to a patient hospital stay.

## `PROC_SEQ_NUM`

`PROC_SEQ_NUM` provides the order in which the procedures were performed.

## `ICD9_CODE`

`CODE` provides the code for the given procedure. 

-->


<!-- 
## `CGID`

`CGID` is the identifier for the caregiver who validated the given measurement.

-->
