---
title: MIMIC-IV documentation
linktitle: Docs
menu:
  main:
    weight: 10
---

MIMIC-IV is a relational database containing real hospital stays for patients admitted to a tertiary academic medical center in Boston, MA, USA. MIMIC-IV contains comprehensive information for each patient while they were in the hospital: laboratory measurements, medications administered, vital signs documented, and so on.
The database is intended to support a wide variety of research in healthcare.
MIMIC-IV builds upon the success of [MIMIC-III](https://mimic.mit.edu), and incorporates numerous improvements over MIMIC-III.

MIMIC-IV is separated into "modules" to reflect the provenance of the data. There are currently five modules:

- [core](/docs/datasets/core) - patient stay information (i.e. admissions and transfers)
- [hosp](/docs/datasets/hosp) - hospital level data for patients: labs, micro, and electronic medication administration
- [icu](/docs/datasets/icu) - ICU level data. These are the event tables, and are identical in structure to MIMIC-III (chartevents, etc)
- [ed](/docs/datasets/ed) - data from the emergency department (TBD: currently not public.)
- [cxr](/docs/datasets/cxr) - lookup tables and meta-data from MIMIC-CXR, allowing linking to MIMIC-IV

All patients across all datasets are in `mimic_core`. However, not all ICU patients have ED data, not all ICU patients have CXRs, not all ED patients have hospital data, and so on. Within an individual dataset, there are also incomplete tables as certain electronic systems did not exist in the past. For example, eMAR data is only available from 2015 onward.

Tables for each module are detailed in the respective sections.