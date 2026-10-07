# Diagnostic delay

Reproducible cohort extraction and diagnostic-delay measurement for
MIMIC-IV, plus a data-quality report generator.

## What this is

ICD codes in MIMIC carry no timestamp, so "when was this diagnosed?" is
a recurring community question (e.g.
[#1843](https://github.com/MIT-LCP/mimic-code/issues/1843)). This
module answers a tractable version of it: for ICU stays with a
*suspected-infection* episode (an antibiotic paired with a microbiology
culture, per the `suspicion_of_infection` concept), it measures the
delay between hospital/ICU admission and the first clinically
observable recognition event (first antibiotic order, first culture
draw, suspected-infection time).

Contents:

| File | Description |
|---|---|
| `suspected_sepsis_cohort.sql` | Cohort concept: one row per ICU stay for adults admitted via the ED with >= 1 suspected-infection episode. |
| `diagnostic_delay.sql` | Delay measures (hours), onset-window classification, and temporal-plausibility flags, one row per cohort stay. |
| `data_quality_report.py` | Generates a Markdown/JSON data-quality report (coverage, missingness, flag prevalence, delay distributions) from the two tables above. |

The SQL is written in the BigQuery dialect, following the repository's
concept conventions; PostgreSQL and DuckDB versions are generated
automatically on merge (see the top-level README).

## Cohort definition (`suspected_sepsis_cohort`)

* Source: `mimiciv_icu.icustays` x `mimiciv_hosp.admissions` x
  `mimiciv_hosp.patients`, inner-joined to
  `mimiciv_derived.suspicion_of_infection` (suspected_infection = 1),
  aggregated to one row per `stay_id`.
* Inclusion: admission age >= 18 (same `anchor_age` formula as
  `age.sql`); `admissions.admission_location = 'EMERGENCY ROOM'`.
* Carries: `subject_id, hadm_id, stay_id, gender, admission_age, race,
  admittime, dischtime, admission_type, admission_location,
  hospital_expire_flag, hospstay_seq, icu_intime, icu_outtime,
  icustay_seq, n_suspicion_episodes, first_suspicion_time,
  first_antibiotic_time, first_culture_time`.

## Delay measures (`diagnostic_delay`)

All delays are in hours (1 decimal):

* `admission_to_suspicion_hours`, `icu_to_suspicion_hours`,
  `admission_to_antibiotic_hours`, `admission_to_culture_hours`,
  `culture_to_antibiotic_hours` (positive = antibiotic after culture).
* `onset_window`: `pre_admission` (suspicion before `admittime`),
  `present_on_admission` (within 48 h of admission), `hospital_onset`
  (after 48 h).
* Plausibility flags (1 = implausible, 0 = plausible, NULL =
  unassessable): `flag_suspicion_before_admission`,
  `flag_suspicion_after_icu_outtime`, `flag_suspicion_after_discharge`,
  `flag_missing_culture_time`, `flag_missing_antibiotic_time`.

## Data-quality report

```bash
python data_quality_report.py \
    --duckdb ~/data/mimic-iv.duckdb \
    --schema mimiciv_derived \
    --raw-schema mimiciv_icu \
    --output delay_data_quality.md \
    --json-output delay_data_quality.json
```

`--postgres-dsn` (requires `psycopg2`) can be used instead of
`--duckdb`. `--raw-schema` is optional; when given, the report adds
the cohort capture rate against adult ED ICU stays from the raw
tables.

## Validation

Real MIMIC-IV data requires credentialed PhysioNet access, so the
logic was validated without it:

1. `sqlglot` parse check of both queries (BigQuery dialect) -- the
   same check CI runs (`.github/scripts/check_sql_syntax.py`).
2. `sqlfluff` lint with the repository's `.sqlfluff` config.
3. Transpiled both queries to DuckDB with the repo's `mimic_utils`
   transpiler and executed them against hand-built synthetic fixtures
   mirroring the MIMIC-IV schema (admissions, icustays, patients,
   derived suspicion_of_infection). Fixtures cover: a standard
   present-on-admission case, a hospital-onset case, a
   pre-admission-suspicion case (flagged), multiple episodes per stay,
   a pediatric exclusion, a non-ED admission exclusion, a stay with no
   suspected infection (excluded), and a NULL `icu_outtime` case
   (flag unassessable).
4. Ran `data_quality_report.py` against the resulting DuckDB database
   and verified the Markdown/JSON outputs against hand-computed
   expectations.

What still needs real data: end-to-end execution against MIMIC-IV
(v3.1), sanity of the delay distributions at scale, and the capture
rate of the cohort definition.

## Limitations

* "Diagnosis time" is proxied by recognition events (antibiotic /
  culture); true clinical diagnosis time is not recorded in MIMIC.
* ED arrival time is not used: the module only depends on
  `mimiciv_hosp` + `mimiciv_icu` + derived concepts so it runs without
  the separate MIMIC-IV-ED module.
* Implausible raw values (see
  [#2168](https://github.com/MIT-LCP/mimic-code/issues/2168)) are
  flagged via ordering checks, not range-checked here.
