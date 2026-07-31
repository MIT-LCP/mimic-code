# SpO2 / oxygen saturation in MIMIC-III

Neonatal and adult ICU cohorts often look for pulse oximetry SpO2 in
`chartevents`. Zero rows for a cohort usually means **itemid / carevue vs
metavision mismatch** or an empty window — not a missing “SpO2 table.”

See [issue #1957](https://github.com/MIT-LCP/mimic-code/issues/1957).

## Common itemids

| ITEMID | Label (approx.) | Notes |
|--------|-----------------|-------|
| 646 | SpO2 | CareVue-era charting |
| 220277 | O2 saturation pulseoxymetry | MetaVision-era charting |

MIMIC-III mixes CareVue and MetaVision stays. A neonatal sepsis cohort that
only hits one era can legitimately return **zero** rows for the other itemid.

## Practical guidance

1. Query **both** 646 and 220277 (and inspect `d_items` for related O2 sat
   labels) before concluding data are missing.
2. Drop first-day / sepsis filters temporarily to confirm the itemids fire at
   all for your `icustay_id` set.
3. For **arterial** saturation, look in `labevents` (SaO2 / ABG panels), which
   is a different concept from pulse ox SpO2.
4. MIMIC-IV uses a different `itemid` namespace (`icu.d_items`); do not reuse
   646/220277 there without checking the IV dictionary.

## Related

- MIMIC-IV chartevents timing: `mimic-iv/docs/CHARTEVENTS_TIMING.md` (when present)
- Oxygen delivery device rows: concepts under `measurement/oxygen_delivery`
