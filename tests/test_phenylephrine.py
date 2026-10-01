"""Synthetic regression coverage for phenylephrine concentration variants (#2159)."""
from pathlib import Path

import pytest

from mimic_utils.transpile import transpile_query

duckdb = pytest.importorskip("duckdb")
ROOT = Path(__file__).resolve().parents[1] / "mimic-iv"


@pytest.mark.parametrize("sql_source", ["bigquery", "committed_duckdb"])
def test_infusion_variants_reach_norepinephrine_equivalent_dose(sql_source):
    with duckdb.connect() as con:
        con.execute("CREATE SCHEMA mimiciv_icu; CREATE SCHEMA mimiciv_derived")
        con.execute("""
            CREATE TABLE mimiciv_icu.inputevents (
                stay_id BIGINT, linkorderid BIGINT, itemid INTEGER,
                rate DOUBLE, rateuom VARCHAR, patientweight DOUBLE,
                amount DOUBLE, starttime TIMESTAMP, endtime TIMESTAMP
            )
        """)
        # All four infusion labels, the intubation bolus label, and an unrelated drug.
        # Each infusion has a distinct stay so a missing item cannot be masked.
        for stay_id, itemid, rate, unit in [
            (1, 221749, 1.0, "mcg/kg/min"),
            (2, 229630, 2.0, "mcg/kg/min"),
            (3, 229631, 3.0, "mcg/kg/min"),
            (4, 229632, 200.0, "mcg/min"),
            (5, 229789, None, None),
            (6, 999999, 9.0, "mcg/kg/min"),
        ]:
            con.execute("""
                INSERT INTO mimiciv_icu.inputevents VALUES
                (?, ?, ?, ?, ?, 50, 10, '2150-01-01 00:00:00', '2150-01-01 02:00:00')
            """, [stay_id, stay_id, itemid, rate, unit])

        def build(name):
            if sql_source == "bigquery":
                sql = (ROOT / "concepts" / "medication" / f"{name}.sql").read_text()
                con.execute(
                    f"CREATE TABLE mimiciv_derived.{name} AS "
                    + transpile_query(sql, "bigquery", "duckdb")
                )
            else:
                con.execute((ROOT / "concepts_duckdb" / "medication" / f"{name}.sql").read_text())

        build("phenylephrine")
        assert con.execute("""
            SELECT stay_id, vaso_rate FROM mimiciv_derived.phenylephrine ORDER BY stay_id
        """).fetchall() == [(1, 1.0), (2, 2.0), (3, 3.0), (4, 4.0)]

        for name in ("dobutamine", "dopamine", "epinephrine", "norepinephrine", "vasopressin", "milrinone"):
            con.execute(
                f"CREATE TABLE mimiciv_derived.{name} AS "
                "SELECT * FROM mimiciv_derived.phenylephrine WHERE FALSE"
            )
        # A variant also contributes when another vasopressor is already present.
        con.execute("""
            INSERT INTO mimiciv_derived.norepinephrine
            SELECT stay_id, linkorderid, 0.1, vaso_amount, starttime, endtime
            FROM mimiciv_derived.phenylephrine WHERE stay_id = 2
        """)
        build("vasoactive_agent")
        build("norepinephrine_equivalent_dose")
        rows = con.execute("""
            SELECT stay_id, norepinephrine_equivalent_dose
            FROM mimiciv_derived.norepinephrine_equivalent_dose ORDER BY stay_id
        """).fetchall()
        assert [r[0] for r in rows] == [1, 2, 3, 4]
        assert [float(r[1]) for r in rows] == pytest.approx([0.1, 0.3, 0.3, 0.4])
