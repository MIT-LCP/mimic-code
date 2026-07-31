# Finding Vitamin C (ascorbic acid) in MIMIC

There is **no dedicated Vitamin C table** in MIMIC-III or MIMIC-IV.

See [issue #1962](https://github.com/MIT-LCP/mimic-code/issues/1962).

## Where exposure usually lives

| Source | Module | What to search |
|--------|--------|----------------|
| `prescriptions` | hosp | drug / drug_name_generic containing `ascorbic`, `vitamin c`, `vit c` |
| `emar` / `emar_detail` | hosp | administered meds with the same name patterns |
| `inputevents` (III: `_cv` / `_mv`) | icu | infusions if charted as inputs (rare for vit C) |
| `labevents` + `d_labitems` | hosp | serum ascorbic acid **levels** (not doses), if ordered |

Retrospective papers that report “Vitamin C exposure” almost always derive a
cohort from **medication orders / eMAR**, not from a first-class vit-C module.

## Practical guidance

1. Start with `prescriptions` / `emar` string filters; review false positives
   (multivitamins, “C” abbreviations).
2. Decide whether you need **orders**, **administrations**, or **serum labs** —
   they answer different questions.
3. Do not expect complete capture: OTCs and outside-hospital vitamins are often
   absent.

## What this repository will not add

A curated “official” Vitamin C concept would need ongoing pharmacy vocabulary
maintenance. Contribute a versioned derived concept with explicit inclusion
strings if you build one for a paper.
