# MIMIC-IV-ED timing caveats

Researchers sometimes see `ed.pyxis.charttime` or `hosp.prescriptions.starttime`
values that fall **before** `ed.edstays.intime` for the same stay. That pattern
is expected in the raw data and is usually **not** a join bug.

This note summarizes how those clocks differ and how to treat them. It does not
change any ETL scripts — only documents behavior already present in the public
files. See also [issue #1910](https://github.com/MIT-LCP/mimic-code/issues/1910).

## Clocks involved

| Source | Column(s) | What it usually represents |
|--------|-----------|----------------------------|
| `ed.edstays` | `intime` / `outtime` | ED stay registration window from the ADT / ED tracking system |
| `ed.pyxis` | `charttime` | Pyxis (automated dispensing cabinet) event time |
| `hosp.prescriptions` | `starttime` / `stoptime` | Order start/stop as recorded in the pharmacy / order system |
| `ed.medrecon` | `charttime` | Medication reconciliation documentation time |
| `ed.vitalsign` | `charttime` | Documented vital-sign observation time |

These systems are **not** forced onto a single synchronized clock in the
released tables. Small negative offsets (event slightly before `intime`) are
common; large offsets need case-by-case review.

## Why events can precede `edstays.intime`

Common, non-exclusive explanations:

1. **Registration lag.** Care (triage meds, Pyxis pulls) can start before the
   ED stay row is fully registered, so ADT `intime` is later than the clinical
   action.
2. **System clocks differ.** Pyxis, pharmacy, and ADT may stamp with different
   device or server times; MIMIC does not re-align them.
3. **Order times ≠ administration times.** `prescriptions.starttime` is an
   **order** time. It can be entered retrospectively, copied from prior orders,
   or set for a planned start that is not the first Pyxis dispense.
4. **Linkage across modules.** Joining ED stays to `hosp.prescriptions` via
   `subject_id` / `hadm_id` can pull hospital-ward orders that are temporally
   near the ED window but not strictly inside it.

None of these are labeled in the public schema as "manual" vs "automatic" — the
tables do not expose that provenance flag.

## Practical guidance

- Treat `edstays.intime`/`outtime` as the **administrative** ED window, not a
  hard clinical filter that every charted event must satisfy.
- Prefer `ed.pyxis.charttime` when studying **dispensing** in the ED; prefer
  `prescriptions` when studying **orders**; do not assume they agree.
- If you need "events during the ED stay," decide explicitly whether to:
  - keep events with `charttime < intime` within a small tolerance (e.g. 1–2 h),
  - drop them, or
  - flag them for sensitivity analysis.
- Do **not** rewrite `intime` from the earliest Pyxis time without documenting
  the rule — that invents a derived stay definition.

## Related reading

- PhysioNet MIMIC-IV ED module overview: <https://mimic.mit.edu/docs/iv/modules/ed/>
- Table pages for `edstays` and `pyxis` under that module
- Analogous ICU charting lag is discussed for `chartevents` (events after
  `outtime` / before `intime` appear in raw ICU data as well)
