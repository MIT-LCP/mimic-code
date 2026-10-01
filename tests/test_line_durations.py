"""Regression coverage for overlapping MetaVision line intervals (#371)."""
from datetime import datetime, timedelta
from pathlib import Path

import pytest

from mimic_utils.transpile import transpile_query

duckdb = pytest.importorskip("duckdb")
ROOT = Path(__file__).resolve().parents[1] / "mimic-iii"


@pytest.mark.parametrize("line_type", ["arterial", "central"])
@pytest.mark.parametrize("sql_source", ["bigquery", "committed_duckdb"])
def test_line_intervals_are_unioned_without_bridging_gaps(line_type, sql_source):
    origin = datetime(2150, 1, 1)
    itemid = 225752 if line_type == "arterial" else 224263
    location = "Invasive Arterial" if line_type == "arterial" else "Invasive Venous"
    with duckdb.connect() as con:
        con.execute("CREATE SCHEMA mimiciii; CREATE SCHEMA mimiciii_derived")
        con.execute("""
            CREATE TABLE mimiciii.procedureevents_mv (
                icustay_id BIGINT, starttime TIMESTAMP, endtime TIMESTAMP,
                itemid INTEGER, locationcategory VARCHAR
            );
            CREATE TABLE mimiciii.chartevents (
                icustay_id BIGINT, charttime TIMESTAMP, itemid INTEGER, value VARCHAR
            )
        """)
        # Nested rows must not break the enclosing interval. Duplicates,
        # overlap chains, and touching intervals belong to the same island.
        # The 14-to-16 gap and another patient's interval must stay separate.
        for stay, start, end in [
            (1, 0, 10), (1, 0, 10), (1, 0, 1), (1, 2, 3), (1, 4, 5), (1, 4, 5),
            (1, 9, 12), (1, 12, 14), (1, 16, 18), (2, 1, 6),
        ]:
            con.execute("INSERT INTO mimiciii.procedureevents_mv VALUES (?, ?, ?, ?, ?)",
                        [stay, origin + timedelta(hours=start), origin + timedelta(hours=end), itemid, location])
        # An unrelated procedure cannot bridge the gap.
        con.execute("INSERT INTO mimiciii.procedureevents_mv VALUES (?, ?, ?, ?, ?)",
                    [1, origin + timedelta(hours=14), origin + timedelta(hours=16), 999999, location])
        # Preserve the existing CareVue extraction, including a documentation gap.
        for hour in (0, 2, 20, 22):
            con.execute("INSERT INTO mimiciii.chartevents VALUES (?, ?, 229, ?)",
                        [3, origin + timedelta(hours=hour), "A-Line" if line_type == "arterial" else "Multi-lumen"])

        name = f"{line_type}_line_durations"
        if sql_source == "bigquery":
            query = (ROOT / "concepts" / "durations" / f"{name}.sql").read_text()
            con.execute(
                f"CREATE TABLE mimiciii_derived.{name} AS "
                + transpile_query(query, "bigquery", "duckdb", {"mimiciii_clinical": "mimiciii"})
            )
        else:
            con.execute((ROOT / "concepts_duckdb" / "durations" / f"{name}.sql").read_text())
        actual = con.execute(f"""
            SELECT icustay_id, starttime, endtime, duration_hours
            FROM mimiciii_derived.{name} ORDER BY icustay_id, starttime
        """).fetchall()
        expected = [
            (stay, origin + timedelta(hours=start), origin + timedelta(hours=end), end - start)
            for stay, start, end in [(1, 0, 14), (1, 16, 18), (2, 1, 6), (3, 0, 2), (3, 20, 22)]
        ]
        assert actual == expected
