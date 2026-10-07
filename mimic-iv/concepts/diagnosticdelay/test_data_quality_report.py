#!/usr/bin/env python3
"""Regression tests for data_quality_report.py.

Covers the two report-generator issues fixed for PR #2173 review:

* [P1] PostgreSQL: ``psycopg2`` connections have no ``execute`` method --
  queries must go through an explicit cursor (which is then closed).
* [P2] Split schemas: ``icustays`` lives in ``mimiciv_icu`` while
  ``admissions``/``patients`` live in ``mimiciv_hosp`` -- the coverage
  denominator must join across both schemas.

Run with: ``python -m pytest test_data_quality_report.py -v``
(duckdb must be installed: ``pip install duckdb``)
"""

import sys
import os
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import data_quality_report as dqr  # noqa: E402


ICU_SCHEMA = "mimiciv_icu"
HOSP_SCHEMA = "mimiciv_hosp"
DERIVED_SCHEMA = "mimiciv_derived"


def _cohort_ddl():
    return """
        CREATE TABLE {s}.suspected_sepsis_cohort (
            subject_id INTEGER,
            hadm_id INTEGER,
            admittime TIMESTAMP,
            dischtime TIMESTAMP,
            gender VARCHAR,
            hospital_expire_flag INTEGER,
            admission_age DOUBLE
        )
    """.format(s=DERIVED_SCHEMA)


def _delay_ddl():
    ts_cols = ",\n".join(f"            {c} TIMESTAMP" for c in dqr.TIMESTAMP_COLUMNS)
    delay_cols = ",\n".join(f"            {c} DOUBLE" for c in dqr.DELAY_COLUMNS)
    flag_cols = ",\n".join(f"            {c} INTEGER" for c in dqr.FLAG_COLUMNS)
    return f"""
        CREATE TABLE {DERIVED_SCHEMA}.diagnostic_delay (
{ts_cols},
{delay_cols},
{flag_cols},
            onset_window VARCHAR
        )
    """


def build_duckdb_split_schema():
    """In-memory DuckDB mirroring the standard MIMIC-IV schema layout."""
    import duckdb

    con = duckdb.connect(":memory:")
    con.execute(f"CREATE SCHEMA {ICU_SCHEMA}")
    con.execute(f"CREATE SCHEMA {HOSP_SCHEMA}")
    con.execute(f"CREATE SCHEMA {DERIVED_SCHEMA}")

    # raw ICU schema: icustays only
    con.execute(
        f"""
        CREATE TABLE {ICU_SCHEMA}.icustays (
            subject_id INTEGER, hadm_id INTEGER, stay_id INTEGER
        )
        """
    )
    con.execute(
        f"INSERT INTO {ICU_SCHEMA}.icustays VALUES (100, 200, 300)"
    )

    # raw hospital schema: admissions + patients
    con.execute(
        f"""
        CREATE TABLE {HOSP_SCHEMA}.admissions (
            subject_id INTEGER,
            hadm_id INTEGER,
            admittime TIMESTAMP,
            admission_location VARCHAR
        )
        """
    )
    con.execute(
        f"""
        CREATE TABLE {HOSP_SCHEMA}.patients (
            subject_id INTEGER, anchor_age INTEGER, anchor_year INTEGER
        )
        """
    )
    con.execute(
        f"""
        INSERT INTO {HOSP_SCHEMA}.admissions VALUES
            (100, 200, '2020-01-01 10:00:00', 'EMERGENCY ROOM')
        """
    )
    con.execute(
        f"INSERT INTO {HOSP_SCHEMA}.patients VALUES (100, 60, 2020)"
    )

    # derived concept tables
    con.execute(_cohort_ddl())
    con.execute(
        f"""
        INSERT INTO {DERIVED_SCHEMA}.suspected_sepsis_cohort VALUES
            (100, 200, '2020-01-01 10:00:00', '2020-01-10 10:00:00',
             'F', 0, 60.0)
        """
    )
    con.execute(_delay_ddl())
    ts_vals = ", ".join(["'2020-01-01 12:00:00'"] * len(dqr.TIMESTAMP_COLUMNS))
    delay_vals = ", ".join(["2.5"] * len(dqr.DELAY_COLUMNS))
    flag_vals = ", ".join(["0"] * len(dqr.FLAG_COLUMNS))
    con.execute(
        f"""
        INSERT INTO {DERIVED_SCHEMA}.diagnostic_delay VALUES
            ({ts_vals}, {delay_vals}, {flag_vals}, 'present_on_admission')
        """
    )
    return con


class FakePsycopg2Cursor:
    """Minimal stand-in for a psycopg2 cursor."""

    def __init__(self):
        self.executed = []
        self.closed = False

    def execute(self, sql, params=()):
        self.executed.append((sql, params))

    def fetchone(self):
        return (1,)

    def fetchall(self):
        return [(1,)]

    @property
    def description(self):
        return [("n",)]

    def close(self):
        self.closed = True


class FakePsycopg2Connection:
    """Mimics psycopg2: cursor() exists, execute() does NOT."""

    def __init__(self):
        self.cursors = []
        self.closed = False

    def cursor(self):
        cur = FakePsycopg2Cursor()
        self.cursors.append(cur)
        return cur

    def close(self):
        self.closed = True


class TestPostgresCursorPath(unittest.TestCase):
    """[P1] Queries must go through a cursor on psycopg2 connections."""

    def test_fetchone_uses_cursor(self):
        con = FakePsycopg2Connection()
        # Would raise AttributeError before the fix (no .execute on con).
        row = dqr.fetchone(con, "SELECT 1")
        self.assertEqual(row, (1,))
        self.assertEqual(len(con.cursors), 1)
        self.assertTrue(con.cursors[0].closed)

    def test_fetchall_uses_cursor(self):
        con = FakePsycopg2Connection()
        cols, rows = dqr.fetchall(con, "SELECT 1 AS n")
        self.assertEqual(cols, ["n"])
        self.assertEqual(rows, [(1,)])
        self.assertEqual(len(con.cursors), 1)
        self.assertTrue(con.cursors[0].closed)

    def test_duckdb_connection_still_executes_directly(self):
        import duckdb

        con = duckdb.connect(":memory:")
        try:
            self.assertIs(dqr._cursor(con), con)
            self.assertEqual(dqr.fetchone(con, "SELECT 42"), (42,))
        finally:
            con.close()


class TestSplitSchemas(unittest.TestCase):
    """[P2] Coverage denominator joins icustays (ICU) to admissions/patients
    (hospital schema)."""

    def test_coverage_with_split_schemas(self):
        con = build_duckdb_split_schema()
        try:
            cov = dqr.coverage_stats(con, ICU_SCHEMA, HOSP_SCHEMA)
            self.assertIsNotNone(cov)
            self.assertEqual(cov["n_adult_ed_icu_stays"], 1)
            self.assertEqual(cov["n_patients"], 1)
        finally:
            con.close()

    def test_coverage_defaults_hosp_schema_to_icu_schema(self):
        # Backwards compatible: single schema containing all three tables.
        import duckdb

        con = duckdb.connect(":memory:")
        try:
            con.execute("CREATE SCHEMA raw")
            con.execute(
                "CREATE TABLE raw.icustays"
                " (subject_id INTEGER, hadm_id INTEGER)"
            )
            con.execute(
                "CREATE TABLE raw.admissions (subject_id INTEGER,"
                " hadm_id INTEGER, admittime TIMESTAMP,"
                " admission_location VARCHAR)"
            )
            con.execute(
                "CREATE TABLE raw.patients (subject_id INTEGER,"
                " anchor_age INTEGER, anchor_year INTEGER)"
            )
            con.execute("INSERT INTO raw.icustays VALUES (1, 10)")
            con.execute(
                "INSERT INTO raw.admissions VALUES"
                " (1, 10, '2021-06-01 08:00:00', 'EMERGENCY ROOM')"
            )
            con.execute("INSERT INTO raw.patients VALUES (1, 55, 2021)")
            cov = dqr.coverage_stats(con, "raw")
            self.assertIsNotNone(cov)
            self.assertEqual(cov["n_adult_ed_icu_stays"], 1)
        finally:
            con.close()

    def test_full_report_with_split_schemas(self):
        con = build_duckdb_split_schema()
        try:
            report = dqr.build_report(
                con, DERIVED_SCHEMA, ICU_SCHEMA, HOSP_SCHEMA
            )
            self.assertIn("coverage", report)
            self.assertEqual(
                report["coverage"]["n_adult_ed_icu_stays"], 1
            )
            self.assertEqual(report["cohort"]["n_stays"], 1)
            md = dqr.render_markdown(report)
            self.assertIn("Capture rate", md)
        finally:
            con.close()


if __name__ == "__main__":
    unittest.main()
