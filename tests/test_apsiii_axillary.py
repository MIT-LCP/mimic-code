"""Regression checks for APS III axillary temperature correction.

APACHE III / APS III raises axillary temperatures by 1 degree Celsius before
scoring (Knaus et al., Chest 1991). Mimic-iv apsiii.sql applies that adjustment
per vitalsign row before first-day min/max aggregation.
"""
from pathlib import Path

import duckdb
import pytest

APSIII = Path(__file__).resolve().parent.parent / "mimic-iv" / "concepts" / "score" / "apsiii.sql"

# Mirrors the CASE expression used in mimic-iv/concepts/score/apsiii.sql
ADJUST_SQL = """
SELECT
    MIN(
        CASE
            WHEN LOWER(temperature_site) LIKE '%axillary%'
                THEN temperature + 1.0
            ELSE temperature
        END
    ) AS temperature_min,
    MAX(
        CASE
            WHEN LOWER(temperature_site) LIKE '%axillary%'
                THEN temperature + 1.0
            ELSE temperature
        END
    ) AS temperature_max
FROM readings
"""


def test_apsiii_source_applies_axillary_correction():
    sql = APSIII.read_text(encoding="utf-8")
    assert "vital_temp" in sql
    assert "LIKE '%axillary%'" in sql
    assert "temperature + 1.0" in sql
    assert "TODO: add 1 degree to axillary" not in sql


@pytest.mark.parametrize(
    "rows,expected_min,expected_max",
    [
        # Oral only: no bump
        ([("Oral", 36.0), ("Oral", 38.5)], 36.0, 38.5),
        # Axillary only: both bumped
        ([("Axillary", 35.0), ("Axillary", 37.0)], 36.0, 38.0),
        # Mixed sites: axillary rows bumped before min/max
        ([("Oral", 36.2), ("Axillary", 35.5), ("Rectal", 37.1)], 36.2, 37.1),
        # Null site: untreated
        ([((None), 35.0), ("axillary", 34.0)], 35.0, 35.0),
        # Case-insensitive site match
        ([("AXILLARY", 36.0)], 37.0, 37.0),
    ],
)
def test_axillary_adjustment_case(rows, expected_min, expected_max):
    con = duckdb.connect()
    con.execute("CREATE TABLE readings (temperature_site VARCHAR, temperature DOUBLE)")
    con.executemany("INSERT INTO readings VALUES (?, ?)", rows)
    result = con.execute(ADJUST_SQL).fetchone()
    assert result == pytest.approx((expected_min, expected_max))
