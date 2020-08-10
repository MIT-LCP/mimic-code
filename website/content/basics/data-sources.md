+++
title = "Data sources"
linktitle = "Data sources"
weight = 3
toc = "false"

[menu]
  [menu.main]
    parent = "Basics"

+++

# Data sources

This page overviews the raw system used to extract data for each of the components of MIMIC-IV.


# Hospital acquired data

The following tables were sourced from the hospital database, and contain information recorded in the hospital, but not necessarily during the patient's ICU stay:

* ADMISSIONS
* CALLOUT
* CPTEVENTS
* DIAGNOSES_ICD
* DRGCODES
* ICUSTAYS
* LABEVENTS
* MICROBIOLOGYEVENTS
* PATIENTS
* PRESCRIPTIONS
* PROCEDURES_ICD
* SERVICES
* TRANSFERS

# ICU acquired data

MetaVision is a clinical information system provided by iMDSoft which acrhives and displays data at the bedside for patients cared in intensive care units as the Beth Israel Deaconness Medical Center. All of the ICU data available in the `mimic_icu` schema are sourced from MetaVision.
The following tables were sourced from the ICU databases, and contain information only during a patient's ICU stay:

* CHARTEVENTS
* DATETIMEEVENTS
* INPUTEVENTS
* OUTPUTEVENTS
* PROCEDUREEVENTS

# Externally acquired data

The `DOD_SSN` (which also contributes to the `DOD` column) is acquired from the social security death registry. It contains dates of death up to 90 days in the future for Metavision patients. It contains dates of death up to 4 years in the future for CareVue patients.

<!--

# Manual input of data

Not all data in the ICU is recorded automatically by monitors and synchronized with the database. For example the Glasgow Coma Scale, a measurement of neurological dysfunction, requires interaction and observation with the patient by a member of the clinical staff. These observations must be manually recorded in the database. Typical workflow for data of this type is to record the observation on paper, and later transcribe a batch of data to the database. Again, the data would appear with a `CHARTTIME` corresponding to the hour of the measurement, and data entered contemporaneously would share the same `STORETIME`.

-->

