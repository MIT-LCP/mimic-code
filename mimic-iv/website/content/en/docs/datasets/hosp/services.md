---
title: "Services"
linktitle: "services"
weight: 1
date: 2020-08-10
description: >
  Hospital level table
---

## *services*

The *services* table describes the service that a patient was admitted under. While a patient can be physicially located at a given ICU type (say MICU), they are not necessarily being cared for by the team which staffs the MICU. This can happen due to a number of reasons, including bed shortage. The *services* table should be used if interested in identifying the type of service a patient is receiving in the hospital. For example, if interested in identifying surgical patients, the recommended method is searching for patients admitted under a surgical service.

Each service is listed in the table as an abbreviation - this is exactly how the data is stored in the hospital database. For user convenience, we have provided a description of each service type.

Service | Description
--- | ---
CMED | Cardiac Medical - for non-surgical cardiac related admissions
CSURG | Cardiac Surgery - for surgical cardiac admissions
DENT | Dental - for dental/jaw related admissions
ENT | Ear, nose, and throat - conditions primarily affecting these areas
GU | Genitourinary - reproductive organs/urinary system
GYN | Gynecological - female reproductive systems and breasts
MED | Medical - general service for internal medicine
NB | Newborn - infants born at the hospital
NBB | Newborn baby - infants born at the hospital
NMED | Neurologic Medical - non-surgical, relating to the brain
NSURG | Neurologic Surgical - surgical, relating to the brain
OBS | Obstetrics - conerned with childbirth and the care of women giving birth
ORTHO | Orthopaedic - surgical, relating to the musculoskeletal system
OMED | Orthopaedic medicine - non-surgical, relating to musculoskeletal system
PSURG | Plastic - restortation/reconstruction of the human body (including cosmetic or aesthetic)
PSYCH | Psychiatric - mental disorders relating to mood, behaviour, cognition, or perceptions
SURG | Surgical - general surgical service not classified elsewhere
TRAUM | Trauma - injury or damage caused by physical harm from an external source
TSURG | Thoracic Surgical - surgery on the thorax, located between the neck and the abdomen
VSURG | Vascular Surgical - surgery relating to the circulatory system

## Links to

* patients on `subject_id`
* admissions on `hadm_id`

<!-- # Important considerations -->

## Table columns

Name | Postgres data type
---- | ----
`subject_id` | INT
`hadm_id` | INT
`transfertime` | TIMESTAMP(0)
`prev_service` | VARCHAR(20)
`curr_service` | VARCHAR(20)

### `subject_id`

{{% include "/static/include/subject_id.md" %}}

### `hadm_id`

{{% include "/static/include/hadm_id.md" %}}

## `transfertime`

`transfertime` is the time at which the patient moved from the `prev_service` (if present) to the `curr_service`.

## `prev_service`, `curr_service`

`prev_service` and `curr_service` are the previous and current service that the patient resides under.
