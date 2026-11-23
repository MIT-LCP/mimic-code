#!/usr/bin/env python3
"""Regression tests for the diagnostic_delay.sql onset-window classification.

The onset window must be classified from the raw timestamps, not the
rounded delay measures: a suspicion 2 minutes before admission rounds to a
delay of -0.0 (which is not < 0) and a suspicion 48 hours 2 minutes after
admission rounds to 48.0 (which is not > 48), so the rounded form
misclassified both boundary cases (PR #2173 review).

The test transpiles the BigQuery concept SQL to DuckDB with the repository
transpiler (``src/mimic_utils/transpile.py``), runs it against a synthetic
``suspected_sepsis_cohort`` table, and checks the onset window on both
sides of the admission and admission+48h boundaries.

Run with: ``python -m pytest test_diagnostic_delay_sql.py -v``
(duckdb and sqlglot must be installed: ``pip install duckdb sqlglot``)
"""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)),
                               "..", "..", "..", "src"))

from mimic_utils.transpile import transpile_query  # noqa: E402

THIS_DIR = os.path.dirname(os.path.abspath(__file__))
DERIVED_SCHEMA = "mimiciv_derived"

# (case id, first_suspicion_time, expected onset_window)
# admittime is 2020-01-01 10:00:00 for every case.
BOUNDARY_CASES = [
    # both sides of the admission boundary
    ("two_min_before", "2020-01-01 09:58:00", "pre_admission"),
    ("one_min_before", "2020-01-01 09:59:00", "pre_admission"),
    ("exactly_at_admission", "2020-01-01 10:00:00", "present_on_admission"),
    ("one_min_after", "2020-01-01 10:01:00", "present_on_admission"),
    # both sides of the admission + 48h boundary
    ("just_inside_48h", "2020-01-03 09:59:00", "present_on_admission"),
    ("exactly_48h", "2020-01-03 10:00:00", "present_on_admission"),
    ("one_min_past_48h", "2020-01-03 10:01:00", "hospital_onset"),
    ("two_min_past_48h", "2020-01-03 10:02:00", "hospital_onset"),
]


def _transpiled_sql():
    with open(os.path.join(THIS_DIR, "diagnostic_delay.sql")) as f:
        bq = f.read()
    return transpile_query(bq, "bigquery", "duckdb")


def build_duckdb_with_cohort():
    import duckdb

    con = duckdb.connect(":memory:")
    con.execute(f"CREATE SCHEMA {DERIVED_SCHEMA}")
    con.execute(
        f"""
        CREATE TABLE {DERIVED_SCHEMA}.suspected_sepsis_cohort (
            subject_id INTEGER,
            hadm_id INTEGER,
            stay_id INTEGER,
            admittime TIMESTAMP,
            dischtime TIMESTAMP,
            icu_intime TIMESTAMP,
            icu_outtime TIMESTAMP,
            n_suspicion_episodes INTEGER,
            first_suspicion_time TIMESTAMP,
            first_antibiotic_time TIMESTAMP,
            first_culture_time TIMESTAMP
        )
        """
    )
    for i, (case_id, suspicion, _) in enumerate(BOUNDARY_CASES):
        con.execute(
            f"""
            INSERT INTO {DERIVED_SCHEMA}.suspected_sepsis_cohort VALUES (
                100, 200, {300 + i},
                '2020-01-01 10:00:00', '2020-01-10 10:00:00',
                '2020-01-01 11:00:00', '2020-01-05 11:00:00',
                1, '{suspicion}',
                '2020-01-01 12:00:00', '2020-01-01 11:30:00'
            )
            """
        )
    return con


class TestOnsetWindowBoundaries(unittest.TestCase):
    """Onset window is classified from raw timestamps at both boundaries."""

    def test_boundary_cases(self):
        con = build_duckdb_with_cohort()
        try:
            rows = con.execute(
                _transpiled_sql()
            ).fetchall()
            got = {r[2]: r[16] for r in rows}  # stay_id -> onset_window
            self.assertEqual(len(got), len(BOUNDARY_CASES))
            for i, (case_id, _, expected) in enumerate(BOUNDARY_CASES):
                self.assertEqual(
                    got[300 + i], expected,
                    f"case {case_id}: expected {expected}, got {got[300 + i]}",
                )
        finally:
            con.close()


if __name__ == "__main__":
    unittest.main()
