+++
title = "What's new?"
linktitle = "What's new?"
weight = 5
toc = false

[menu]
  [menu.main]
    parent = "About"

+++

# What's new in MIMIC-IV?

Many users will be familiar with [MIMIC-III](http://mimic.mit.edu/), the predecessor of MIMIC-IV.
A number of improvements have been made, including simplifying the structure, adding new data elements, and improving the usability of previous data elements.

## Structure

The structure of MIMIC-IV is necessarily different than MIMIC-III.
In MIMIC-III, the set of tables were given as one large set, with no obvious differentiation between them.
In MIMIC-IV, we explicitly state the source database of each table.
Not only does this clarify the data provenance, but it answers many questions regarding data coverage.
For example, as the CHARTEVENTS table is sourced from the ICU clinical information system, it will only provide data for patients while they are in an ICU.
Conversely, the LABEVENTS table is sourced from the hospital database, and consequently contains information for a patient's entire hospital stay.

## Contemporary

MIMIC-IV contains data from 2008 - 2018 (inclusive).
Tests which have been more recently introduced to MIMIC-CXR (e.g. procalcitonin) will be available.

## Years are included

The date-shift strategy in MIMIC has changed.
Instead of releasing the day of the week and the season, we will release the year of patient admission.
This allows studying patients over time as care practices change.

### ED data

Completely new to MIMIC is the inclusion of data from the emergency department (MIMIC-ED).
This data covers over 200,000 patients and provides crucial information about the initial period of their hospital stay. The ED section describes the tables in MIMIC-ED. Approximately 65% of patients admitted to an ICU at the BIDMC are first seen in the emergency department.

### Chest x-ray data

Imaging data is also an entirely new addition to MIMIC. The MIMIC-CXR database is [publicly available](https://physionet.org/content/mimic-cxr/). Notably, the `subject_id` identifier used in the MIMIC-CXR database is consistent with the `subject_id` used in MIMIC-IV. Therefore, all chest x-rays in MIMIC-CXR are linkable to patient stays in MIMIC-IV.


## Table-wise improvements over MIMIC-III

A number of enhancements have been made to tables which may be familiar to you from MIMIC-III. 
Entirely new tables have also been added.

### Hospital data

#### LABEVENTS

* Reference ranges are now available.
* A specimen identifier (`spec_id`) allows users to group all measurements made for a single specimen (e.g. all blood gas measurements from the same sample of blood).
* A priority column indicates the priority level of the laboratory measure.

#### MICROBIOLOGYEVENTS

* Now contains the name of the test performed.

#### EMAR and EMAR_DETAIL

Two entirely new tables are made available, sourced from the relatively newly installed electronic Medicine Administration Record (eMAR) system.
Bedside staff will scan barcodes for each individual formulary unit of a medication when administering it. This allows for a granular, high resolution record of when a medication was given.

#### HCPCSEVENTS, D_HCPCS

TBD.

### ICU data

#### INPUTEVENTS

* Ingredients are now stored in the data. Importantly, "water" is an ingredient in most inputs, and tabulating the amount of water a patient receives allows accurate estimation of the patient's fluid intake.
