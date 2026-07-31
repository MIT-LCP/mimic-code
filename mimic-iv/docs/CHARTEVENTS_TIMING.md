# Chartevents timing vs ICU stay windows

Researchers often find `icu.chartevents.charttime` values **after**
`icu.icustays.outtime` (or occasionally before `intime`). Large absolute counts
are expected in the raw PhysioNet files and usually do **not** mean a broken
`stay_id` join.

See [issue #1961](https://github.com/MIT-LCP/mimic-code/issues/1961).

## Why charttime can fall outside `[intime, outtime]`

1. **Late charting.** Nurses and devices often document observations after the
   patient has left the ICU; the row still carries the ICU `stay_id`.
2. **Device / interface clocks.** Bedside monitors and EHR interfaces may stamp
   times that disagree slightly with ADT `intime`/`outtime`.
3. **Derived stay boundaries.** `icustays` windows are constructed from
   transfer / careunit logic; charted data is not clipped to those windows in
   the ETL that loads the CSV files.

The public tables do not expose a "manual vs automatic" provenance flag for
each `charttime`.

## Practical guidance

- Treat `icustays.intime` / `outtime` as the **administrative** ICU window.
- For "in-ICU only" cohorts, filter explicitly, e.g.
  `charttime >= intime AND charttime <= outtime`, and report how many rows you
  dropped.
- Prefer a sensitivity analysis that also keeps a short post-`outtime` grace
  period (e.g. 1–6 hours) when studying labs or vitals that are often charted
  late.
- Do **not** rewrite `outtime` from the latest `charttime` inside the PhysioNet
  loaders — that belongs in a documented derived concept if you need it.

## Related notes

- ED module: `mimic-iv-ed/docs/TIMING_NOTES.md` (`edstays.intime` vs pyxis)
- Lab / OMR unit caveats: `mimic-iv/buildmimic/TABLE_NOTES.md` when present
