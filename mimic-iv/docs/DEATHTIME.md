# Interpreting `admissions.deathtime`

Hospital admissions can show a `deathtime` while `transfers` (and ICU
`icustays`) still list care-unit activity **after** that timestamp. That is a
known pattern in MIMIC-IV, not usually a join bug.

See [issue #1945](https://github.com/MIT-LCP/mimic-code/issues/1945).

## What `deathtime` is

| Column | Table | Meaning |
|--------|-------|---------|
| `deathtime` | `hosp.admissions` | Time of death recorded for **that hospital admission**, when death occurred in-hospital |
| `hospital_expire_flag` | `hosp.admissions` | 1 if the patient died during the admission |
| `dod` | `hosp.patients` | Date of death at the **patient** level (coarser; may come from hospital or Social Security sources depending on version/docs) |

`deathtime` is an admission-scoped clinical/administrative death time. It is
**not** forced to equal the last `transfers.outtime` or `icustays.outtime`.

## Why transfers can continue after `deathtime`

Common explanations (often several at once):

1. **ADT lag.** Transfer / location rows are written when the bed-management
   system updates, which can trail the documented time of death.
2. **Post-mortem logistics.** Patients may still appear to "move" (e.g. ICU →
   PACU / morgue-related locations) in the transfer chain after death is
   recorded.
3. **Clock disagreement.** Death documentation and ADT systems are not always
   on one synchronized clock in the released tables.
4. **Stay construction.** Derived ICU stays use transfer/careunit rules; they
   are not clipped to `deathtime` in the PhysioNet loaders.

So for `hadm_id` examples like the one in #1945, prefer treating `deathtime`
as the mortality timestamp for that admission, and treat later transfer rows as
ADT/administrative trail — unless your study specifically needs location-based
definitions of "end of care."

## Practical guidance

- For **in-hospital mortality**, use `hospital_expire_flag` / `deathtime` on
  `admissions` (and `patients.dod` when you need patient-level death date).
- Do **not** require `deathtime >= max(transfers.outtime)` as a data-quality
  filter without documenting that you are excluding real deaths with late ADT.
- If you need "alive in ICU until outtime," define that rule explicitly (e.g.
  ICU outtime, or `least(outtime, deathtime)`), and report sensitivity to the
  choice.
- This repository will **not** rewrite transfer out-times from `deathtime` in
  the CSV loaders.

## Related notes

- ICU charting after outtime: `mimic-iv/docs/CHARTEVENTS_TIMING.md`
- ED intime vs pyxis: `mimic-iv-ed/docs/TIMING_NOTES.md`
