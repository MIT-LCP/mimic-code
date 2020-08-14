---
title: MIMIC-IV documentation
linktitle: Docs
menu:
  main:
    weight: 10
---

MIMIC-IV is an update to MIMIC-III, containing hospitalized patients from 2008 - 2019 inclusive.
The data is separated into ``modules'' to reflect the provenance of the individual modules.

There are currently five modules:

- [core](/docs/datasets/core) - admissions/transfers/stays/services - this is the hospital level patient tracking dataset
- [hosp](/docs/datasets/hosp) - hospital level data for patients: labs, micro, and electronic medication administration
- [icu](/docs/datasets/icu) - ICU level data. These are the event tables, and are identical in structure to MIMIC-III (chartevents, etc)
- [ed](/docs/datasets/ed) - data from the emergency department (TBD: currently not public.)
- [cxr](/docs/datasets/cxr) - metadata linking CXRs to patients

All patients across all datasets are in mimic_core. However, not all ICU patients have ED data, not all ICU patients have CXRs, not all ED patients have hospital data, and so on. Within an individual dataset, there are also incomplete tables as certain electronic systems did not exist in the past. For example, eMAR data is only available from 2015 onward.