+++
title = "Pharmacy"
linktitle = "pharmacy"
weight = 1
toc = false

[menu]
  [menu.main]
    parent = "Hosp Tables"

+++

## *poe*

Provider order entry (POE) is the general interface through which care providers at the hospital enter orders. Most treatments and procedures must be ordered via POE.

## Links to

* *poe_detail* on `poe_id`

<!--

# Important considerations

-->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INTEGER NOT NULL
`hadm_id` | INTEGER NOT NULL
`pharmacy_id` | INTEGER NOT NULL
`starttime` | TIMESTAMP
`stoptime` | TIMESTAMP
`medication` |
`proc_type` | VARCHAR(50) NOT NULL
`status` | VARCHAR(50)
`entertime` | TIMESTAMP NOT NULL
`verifiedtime` | TIMESTAMP
`route` |
`frequency` |
`disp_sched` |
`infusion_type` | VARCHAR(15)
`sliding_scale` | VARCHAR(1)
`lockout_interval` | VARCHAR(50)
`basal_rate` | REAL
`one_hr_max` | VARCHAR(10)
`doses_per_24_hrs` | REAL
`duration` | REAL
`duration_interval` | VARCHAR(50)
`expiration_val` | INTEGER
`expiration_unit` | VARCHAR(50)
`expirationdate` | TIMESTAMP
`dispensation` | VARCHAR(50)
`fill_quantity` |
`poe_id` | VARCHAR(25)
`poe_submit_tm` | TIMESTAMP
`poe_id_approval_ind` |
`poe_id_indication_full` |
`poe_id_ind_emp` |
`poe_id_ind_preop` |
`poe_id_ind_pathogen` |
`poe_id_ind_cx_site` |

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

### `pharmacy_id`

A unique identifier for the given pharmacy entry.

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



### `sliding_scale`



### `lockout_interval`



### `basal_rate`



### `one_hr_max`



### `doses_per_24_hrs`

The number of expected doses per 24 hours. Note that this column can be misleading for continuously infused medications as they are usually only "dosed" once per day, despite continuous administration.

### `duration`, `duration_interval`

`duration` is the numeric duration of the given dose, while `duration_interval` can be considered as the unit of measurement for the given duration. For example, often `duration` is 1 and `duration_interval` is "Doses". Alternatively, `duration` could be 8 and the `duration_interval` could be "Weeks".

### `expiration_val`



### `expiration_unit`



### `expirationdate`



### `dispensation`

The source of dispensation for the medication.

### `fill_quantity`

What proportion of the formulary to fill.

### `poe_id`

A foreign key which links to the provider order entry order in the *prescriptions* table associated with this pharmacy record.

### `poe_submit_tm`



### `poe_id_approval_ind`



### `poe_id_indication_full`



### `poe_id_ind_emp`



### `poe_id_ind_preop`



### `poe_id_ind_pathogen`



### `poe_id_ind_cx_site`


