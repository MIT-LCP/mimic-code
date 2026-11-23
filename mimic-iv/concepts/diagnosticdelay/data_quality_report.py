#!/usr/bin/env python3
"""Data-quality report for the diagnostic-delay concept tables.

Reads the ``suspected_sepsis_cohort`` and ``diagnostic_delay`` tables
(mimic-iv/concepts/diagnosticdelay/) from a DuckDB database (or
PostgreSQL, if psycopg2 is installed) and emits a data-quality report
covering:

* cohort coverage -- how many ICU stays/patients the cohort captures,
  optionally against the raw ``icustays`` denominator (``--raw-schema``)
* missingness of every anchor timestamp and delay measure
* temporal-plausibility flag prevalence
  (suspicion before admission, after ICU discharge, after hospital
  discharge, missing culture/antibiotic times)
* delay distributions (median / p25 / p75) and onset-window breakdown

Example (DuckDB, after building the derived concepts)::

    python data_quality_report.py \\
        --duckdb ~/data/mimic-iv.duckdb \\
        --schema mimiciv_derived \\
        --raw-schema mimiciv_icu \\
        --raw-hosp-schema mimiciv_hosp \\
        --output delay_data_quality.md

The aggregation SQL is plain portable SQL (no engine-specific
functions); quantiles are computed in Python so the numbers are
identical on every backend.
"""

import argparse
import json
import math
import sys
from datetime import datetime, timezone


COHORT_TABLE = "suspected_sepsis_cohort"
DELAY_TABLE = "diagnostic_delay"

TIMESTAMP_COLUMNS = [
    "admittime",
    "dischtime",
    "icu_intime",
    "icu_outtime",
    "first_suspicion_time",
    "first_antibiotic_time",
    "first_culture_time",
]

DELAY_COLUMNS = [
    "admission_to_suspicion_hours",
    "icu_to_suspicion_hours",
    "admission_to_antibiotic_hours",
    "admission_to_culture_hours",
    "culture_to_antibiotic_hours",
]

FLAG_COLUMNS = [
    "flag_suspicion_before_admission",
    "flag_suspicion_after_icu_outtime",
    "flag_suspicion_after_discharge",
    "flag_missing_culture_time",
    "flag_missing_antibiotic_time",
]


def connect(args):
    """Open a DB-API connection for the requested engine."""
    if args.postgres_dsn:
        try:
            import psycopg2
        except ImportError:
            sys.exit("psycopg2 is required for --postgres-dsn")
        return psycopg2.connect(args.postgres_dsn)
    try:
        import duckdb
    except ImportError:
        sys.exit("duckdb is required for --duckdb (pip install duckdb)")
    con = duckdb.connect(args.duckdb, read_only=True)
    return con


def _cursor(con):
    """Return something executable for this DB-API connection.

    psycopg2 connections expose no ``execute`` method -- queries must go
    through an explicit cursor. DuckDB connections execute directly.
    """
    return con if hasattr(con, "execute") else con.cursor()


def fetchone(con, sql, params=()):
    cur = _cursor(con)
    try:
        cur.execute(sql, params)
        return cur.fetchone()
    finally:
        if cur is not con:
            cur.close()


def fetchall(con, sql, params=()):
    cur = _cursor(con)
    try:
        cur.execute(sql, params)
        cols = [d[0] for d in cur.description]
        return cols, cur.fetchall()
    finally:
        if cur is not con:
            cur.close()


def table_exists(con, schema, table):
    try:
        row = fetchone(
            con, f"SELECT 1 FROM {schema}.{table} LIMIT 1"
        )
        return row is not None
    except Exception:
        return False


def quantiles(values, qs=(0.25, 0.5, 0.75)):
    """Quantiles computed in Python (portable across backends)."""
    vals = sorted(v for v in values if v is not None)
    if not vals:
        return {q: None for q in qs}
    out = {}
    for q in qs:
        pos = q * (len(vals) - 1)
        lo = math.floor(pos)
        hi = math.ceil(pos)
        out[q] = vals[lo] + (vals[hi] - vals[lo]) * (pos - lo)
    return out


def cohort_stats(con, schema):
    cols, rows = fetchall(
        con,
        f"""
        SELECT COUNT(*) AS n_stays
            , COUNT(DISTINCT subject_id) AS n_patients
            , COUNT(DISTINCT hadm_id) AS n_hadm
            , MIN(admittime) AS min_admittime
            , MAX(admittime) AS max_admittime
            , SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS n_female
            , SUM(CASE WHEN hospital_expire_flag = 1 THEN 1 ELSE 0 END)
                AS n_hospital_deaths
        FROM {schema}.{COHORT_TABLE}
        """,
    )
    stats = dict(zip(cols, rows[0]))
    ages = [
        r[0]
        for r in fetchall(
            con, f"SELECT admission_age FROM {schema}.{COHORT_TABLE}"
        )[1]
    ]
    stats["admission_age_p25"], stats["admission_age_p50"], stats[
        "admission_age_p75"
    ] = (lambda q: (q[0.25], q[0.5], q[0.75]))(quantiles(ages))
    return stats


def coverage_stats(con, icu_schema, hosp_schema=None):
    """Cohort capture rate against the raw icustays denominator.

    ``icustays`` lives in the ICU schema (``mimiciv_icu``); ``admissions``
    and ``patients`` live in the hospital schema (``mimiciv_hosp``), so the
    two schema names are accepted separately. Denominator mirrors the
    cohort filters (adult, ED origin) without requiring a
    suspected-infection episode. Returns None when the raw tables are
    unavailable. The age filter reproduces the concept's
    ``anchor_age + year(admittime) - anchor_year`` formula with
    engine-portable date parts.
    """
    hosp_schema = hosp_schema or icu_schema
    try:
        cols, rows = fetchall(
            con,
            f"""
            SELECT COUNT(*) AS n_adult_ed_icu_stays
                , COUNT(DISTINCT ie.subject_id) AS n_patients
            FROM {icu_schema}.icustays ie
            INNER JOIN {hosp_schema}.admissions adm
                ON ie.hadm_id = adm.hadm_id
            INNER JOIN {hosp_schema}.patients pat
                ON ie.subject_id = pat.subject_id
            WHERE pat.anchor_age
                    + DATE_PART('YEAR', adm.admittime)
                    - pat.anchor_year >= 18
                AND adm.admission_location = 'EMERGENCY ROOM'
            """,
        )
    except Exception:
        return None
    return dict(zip(cols, rows[0]))


def missingness(con, schema):
    """Per-column missingness for timestamps and delay measures."""
    select = ", ".join(
        f"SUM(CASE WHEN {c} IS NULL THEN 1 ELSE 0 END) AS {c}_missing"
        for c in TIMESTAMP_COLUMNS + DELAY_COLUMNS
    )
    cols, rows = fetchall(
        con, f"SELECT COUNT(*) AS n, {select} FROM {schema}.{DELAY_TABLE}"
    )
    res = dict(zip(cols, rows[0]))
    n = res.pop("n")
    return {
        "n": n,
        "columns": {
            c: {"missing": res[f"{c}_missing"], "pct": res[f"{c}_missing"] / n * 100}
            for c in TIMESTAMP_COLUMNS + DELAY_COLUMNS
        },
    }


def flag_prevalence(con, schema):
    select = ", ".join(
        f"SUM(CASE WHEN {c} = 1 THEN 1 ELSE 0 END) AS {c}_n"
        f", SUM(CASE WHEN {c} IS NULL THEN 1 ELSE 0 END) AS {c}_null"
        for c in FLAG_COLUMNS
    )
    cols, rows = fetchall(
        con, f"SELECT COUNT(*) AS n, {select} FROM {schema}.{DELAY_TABLE}"
    )
    res = dict(zip(cols, rows[0]))
    n = res.pop("n")
    return {
        "n": n,
        "flags": {
            c: {
                "flagged": res[f"{c}_n"],
                "pct": res[f"{c}_n"] / n * 100,
                "unassessable_null": res[f"{c}_null"],
            }
            for c in FLAG_COLUMNS
        },
    }


def delay_distributions(con, schema):
    out = {}
    for col in DELAY_COLUMNS:
        values = [
            r[0]
            for r in fetchall(
                con,
                f"SELECT {col} FROM {schema}.{DELAY_TABLE}"
                f" WHERE {col} IS NOT NULL",
            )[1]
        ]
        q = quantiles(values)
        out[col] = {
            "n": len(values),
            "p25": q[0.25],
            "median": q[0.5],
            "p75": q[0.75],
            "min": min(values) if values else None,
            "max": max(values) if values else None,
        }
    return out


def onset_window_counts(con, schema):
    cols, rows = fetchall(
        con,
        f"""
        SELECT onset_window, COUNT(*) AS n
        FROM {schema}.{DELAY_TABLE}
        GROUP BY onset_window
        ORDER BY n DESC
        """,
    )
    return [dict(zip(cols, r)) for r in rows]


def build_report(con, schema, raw_schema, raw_hosp_schema=None):
    if not table_exists(con, schema, COHORT_TABLE):
        sys.exit(f"table {schema}.{COHORT_TABLE} not found")
    if not table_exists(con, schema, DELAY_TABLE):
        sys.exit(f"table {schema}.{DELAY_TABLE} not found")
    report = {
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "schema": schema,
        "cohort": cohort_stats(con, schema),
        "missingness": missingness(con, schema),
        "flags": flag_prevalence(con, schema),
        "delays": delay_distributions(con, schema),
        "onset_windows": onset_window_counts(con, schema),
    }
    if raw_schema:
        report["coverage"] = coverage_stats(con, raw_schema, raw_hosp_schema)
    return report


def render_markdown(report):
    c = report["cohort"]
    lines = [
        "# Diagnostic-delay data-quality report",
        "",
        f"Generated {report['generated_at']} from schema `{report['schema']}`.",
        "",
        "## Cohort coverage",
        "",
        f"* ICU stays in cohort: **{c['n_stays']}**",
        f"* Patients: **{c['n_patients']}**; hospitalizations: **{c['n_hadm']}**",
        f"* Admission window: {c['min_admittime']} to {c['max_admittime']}",
        f"* Female: {c['n_female']} ({c['n_female'] / c['n_stays'] * 100:.1f}%)",
        f"* Hospital deaths: {c['n_hospital_deaths']}"
        f" ({c['n_hospital_deaths'] / c['n_stays'] * 100:.1f}%)",
        f"* Admission age p25/median/p75: "
        f"{c['admission_age_p25']:.0f} / {c['admission_age_p50']:.0f} /"
        f" {c['admission_age_p75']:.0f}",
    ]
    if report.get("coverage"):
        cov = report["coverage"]
        denom = cov["n_adult_ed_icu_stays"]
        lines.append(
            f"* Capture rate vs adult ED ICU stays: "
            f"{c['n_stays']}/{denom} = {c['n_stays'] / denom * 100:.1f}%"
            if denom
            else "* Capture rate: denominator unavailable"
        )
    lines += ["", "## Missingness", ""]
    for col, m in report["missingness"]["columns"].items():
        lines.append(
            f"* `{col}`: {m['missing']} missing ({m['pct']:.2f}%)"
        )
    lines += ["", "## Temporal-plausibility flags", ""]
    for flag, f in report["flags"]["flags"].items():
        lines.append(
            f"* `{flag}`: {f['flagged']} flagged ({f['pct']:.2f}%)"
            + (
                f", {f['unassessable_null']} unassessable (NULL anchor)"
                if f["unassessable_null"]
                else ""
            )
        )
    lines += ["", "## Delay distributions (hours)", ""]
    lines.append("| measure | n | p25 | median | p75 | min | max |")
    lines.append("|---|---|---|---|---|---|---|")
    for col, d in report["delays"].items():
        lines.append(
            f"| `{col}` | {d['n']} | {d['p25']:.1f} | {d['median']:.1f}"
            f" | {d['p75']:.1f} | {d['min']:.1f} | {d['max']:.1f} |"
        )
    lines += ["", "## Onset windows", ""]
    for w in report["onset_windows"]:
        lines.append(f"* `{w['onset_window']}`: {w['n']} stays")
    lines.append("")
    return "\n".join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(
        description="Data-quality report for the diagnostic-delay concepts."
    )
    parser.add_argument("--duckdb", help="path to a DuckDB database file")
    parser.add_argument(
        "--postgres-dsn", help="psycopg2 DSN for a PostgreSQL database"
    )
    parser.add_argument(
        "--schema", default="mimiciv_derived", help="derived schema name"
    )
    parser.add_argument(
        "--raw-schema",
        default=None,
        help="raw ICU schema with icustays (enables the coverage "
        "denominator)",
    )
    parser.add_argument(
        "--raw-hosp-schema",
        default=None,
        help="raw hospital schema with admissions/patients "
        "(defaults to --raw-schema)",
    )
    parser.add_argument(
        "--output", default=None, help="write the Markdown report here"
    )
    parser.add_argument(
        "--json-output", default=None, help="write the raw report JSON here"
    )
    args = parser.parse_args(argv)
    if not args.duckdb and not args.postgres_dsn:
        parser.error("one of --duckdb or --postgres-dsn is required")

    con = connect(args)
    try:
        report = build_report(
            con, args.schema, args.raw_schema, args.raw_hosp_schema
        )
    finally:
        con.close()

    markdown = render_markdown(report)
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(markdown)
        print(f"wrote Markdown report to {args.output}")
    else:
        print(markdown)
    if args.json_output:
        with open(args.json_output, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, default=str)
        print(f"wrote JSON report to {args.json_output}")


if __name__ == "__main__":
    main()
