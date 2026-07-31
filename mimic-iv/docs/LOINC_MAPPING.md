# MIMIC-IV itemid → LOINC mapping

There is **no official, complete MIMIC-IV `itemid` → LOINC map** in this
repository or on PhysioNet as a maintained product.

See [issue #1972](https://github.com/MIT-LCP/mimic-code/issues/1972).

## What exists today

| Path | Scope | Caveat |
|------|-------|--------|
| `d_items` / `d_labitems` labels | MIMIC-IV dictionaries | Human-readable names, not LOINC |
| MIMIC-III `conceptid` / community maps | Older releases | Incomplete; IV itemids are a different namespace |
| OMOP / Athena / manual review | External | Best for modeling when you need LOINC semantics |
| PhysioNet forum threads | Community | Useful pointers; not version-guaranteed |

A multi-hop IV → III → LOINC conversion is **error-prone**: itemids were
reassigned across CareVue / MetaVision / IV, and LOINC bindings in older
helpers were never exhaustive.

## Recommended practice for predictive modeling

1. Prefer **MIMIC-IV `itemid`** (and `d_labitems.label` / `fluid` / `category`)
   as the primary feature key inside a single MIMIC version.
2. If LOINC is required for multi-site harmonization, build an explicit map
   for the **subset of itemids you use**, with manual clinician/terminology
   review — do not treat a scraped IV→III→LOINC chain as ground truth.
3. Record the MIMIC version, map provenance, and unmapped rate in the paper
   or model card.

## What this repository will not add as “official”

A full LOINC crosswalk would need ongoing clinical terminology maintenance
outside the CSV loaders. Until PhysioNet publishes one, please treat any
community CSV as **unofficial**.

## Related

- Lab value / unit quirks: `mimic-iv/buildmimic/TABLE_NOTES.md` (when present)
- Qualitative labs (`NEG`/`POS`): same notes / issue #1938
