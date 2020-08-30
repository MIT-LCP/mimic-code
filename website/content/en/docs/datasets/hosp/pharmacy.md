---
title: "Pharmacy"
linktitle: "pharmacy"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## *pharmacy*

The pharmacy table provides detailed information regarding filled medications which were prescribed to the patient.
Pharmacy information includes the dose of the drug, the number of formulary doses, the frequency of dosing, the medication route, and the duration of the prescription.

## Links to

* *poe* on `poe_id`
* *prescriptions* on `poe_id`
* *emar* on `pharmacy_id`

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER NOT NULL
`hadm_id` | INTEGER NOT NULL
`pharmacy_id` | INTEGER NOT NULL
`poe_id` | VARCHAR(25)
`starttime` | TIMESTAMP(3)
`stoptime` | TIMESTAMP(3)
`medication` | TEXT
`proc_type` | VARCHAR(50) NOT NULL
`status` | VARCHAR(50)
`entertime` | TIMESTAMP(3) NOT NULL
`verifiedtime` | TIMESTAMP(3)
`route` | VARCHAR(50)
`frequency` | VARCHAR(50)
`disp_sched` | VARCHAR(255)
`infusion_type` | VARCHAR(15)
`sliding_scale` | VARCHAR(1)
`lockout_interval` | VARCHAR(50)
`basal_rate` | REAL
`one_hr_max` | VARCHAR(10)
`doses_per_24_hrs` | REAL
`duration` | REAL
`duration_interval` | VARCHAR(50)
`expiration_value` | INTEGER
`expiration_unit` | VARCHAR(50)
`expirationdate` | TIMESTAMP(3)
`dispensation` | VARCHAR(50)
`fill_quantity` | VARCHAR(50)

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `pharmacy_id`

A unique identifier for the given pharmacy entry.
Each row of the pharmacy table has a unique `pharmacy_id`. This identifier can be used to link the pharmacy information to the provider order (in *poe* or *prescriptions*) or to the administration of the medication (in *emar*).

### `poe_id`

A foreign key which links to the provider order entry order in the *prescriptions* table associated with this pharmacy record.

### `starttime`, `stoptime`

The start and stop times for the given prescribed medication.

### `medication`

The name of the medication provided.

### `ord_proc_type_full`

The type of order: "IV Piggyback", "Non-formulary", "Unit Dose", and so on.

### `status_full`

Whether the prescription is active, inactive, or discontinued.

### `entertime`

The date and time at which the prescription was entered into the pharmacy system.

### `verifiedtime`

The date and time at which the prescription was verified by a physician.

### `route`

The intended route of administration for the prescription.

### `frequency`

The frequency at which the medication should be administered to the patient. Many commonly used short hands are used in the frequency column.
Q# indicates every # hours; e.g. "Q6" or "Q6H" is every 6 hours.

### `disp_sched`

The hours of the day at which the medication should be administered, e.g. "08, 20" would indicate the medication should be administered at 8:00 AM and 8:00 PM, respectively.

### `infusion_type`

A coded letter describing the type of infusion: 'B', 'C', 'N', 'N1', 'O', or 'R'.

### `sliding_scale`

Indicates whether the medication should be given on a sliding scale: either 'Y' or 'N'.

### `lockout_interval`

The time the patient must wait until providing themselves with another dose; often used with patient controlled analgesia.

### `basal_rate`

The rate at which the medication is given over 24 hours.

### `one_hr_max`

The maximum dose that may be given in a single hour.

### `doses_per_24_hrs`

The number of expected doses per 24 hours. Note that this column can be misleading for continuously infused medications as they are usually only "dosed" once per day, despite continuous administration.

### `duration`, `duration_interval`

`duration` is the numeric duration of the given dose, while `duration_interval` can be considered as the unit of measurement for the given duration. For example, often `duration` is 1 and `duration_interval` is "Doses". Alternatively, `duration` could be 8 and the `duration_interval` could be "Weeks".

### `expiration_value`, `expiration_unit`, `expirationdate`

If the drug has a relevant expiry date, these columns detail when this occurs. `expiration_value` and `expiration_unit` provide a length of time until the drug expires, e.g. 30 days, 72 hours, and so on. `expirationdate` provides the deidentified date of expiry.

### `dispensation`

The source of dispensation for the medication.

### `fill_quantity`

What proportion of the formulary to fill.
