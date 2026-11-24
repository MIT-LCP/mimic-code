from datetime import datetime, timedelta, timezone
from decimal import Decimal
from unittest.mock import Mock

import pandas as pd
import pytest

from mimic_utils.compare_concepts import compare_concepts, compare_table


def test_compare_table_treats_same_wall_time_as_equal_across_timezones():
    pg = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 3, 30, tzinfo=timezone(timedelta(hours=2)))]})
    duck = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 3, 30)]})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (True, "1 rows OK")


def test_compare_table_flags_different_wall_times_even_if_instants_match():
    pg = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 3, 30, tzinfo=timezone(timedelta(hours=2)))]})
    duck = pd.DataFrame({"charttime": [datetime(2150, 1, 1, 1, 30)]})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (
        False,
        "1 differing cells in columns: charttime(1)",
    )


@pytest.mark.parametrize(
    "column, pg_value, duck_value",
    [
        ("hadm_id", 20_000_000, 20_000_001),
        ("code", "001", "1"),
        ("label", "2025-01-01", "2025-01-01 00:00:00"),
    ],
)
def test_discrete_values_match_exactly_with_default_tolerance(column, pg_value, duck_value):
    pg = pd.DataFrame({column: [pg_value]})
    duck = pd.DataFrame({column: [duck_value]})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (
        False, f"1 differing cells in columns: {column}(1)"
    )


def test_reordered_rows_with_nullable_ids_and_text_still_match():
    pg = pd.DataFrame({
        "stay_id": pd.array([23, None, 23], dtype="Int32"),
        "code": ["01", "1", None],
    })
    duck = pg.iloc[::-1].astype({"stay_id": "Int64"})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (True, "3 rows OK")


def test_nullable_hadm_id_inferred_as_float_still_matches_exactly():
    pg = pd.DataFrame({"hadm_id": [20_000_000, None]})
    duck = pd.DataFrame({"hadm_id": [20_000_001, None]})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (
        False, "1 differing cells in columns: hadm_id(1)"
    )


def test_nullable_float_measurements_keep_their_tolerance():
    pg = pd.DataFrame({"value": pd.Series([37.12345, None], dtype=object)})
    duck = pd.DataFrame({"value": pd.Series([None, 37.12345], dtype="float32")})

    assert compare_table(pg, duck, 1e-6, 1e-9) == (True, "2 rows OK")


def test_reordered_precise_decimal_values_match_with_absolute_tolerance():
    pg = pd.DataFrame({"value": [
        Decimal("12345678901234567890.0000000001"),
        Decimal("12345678901234567890.0000000002"),
    ]})
    duck = pg.iloc[::-1]

    assert compare_table(pg, duck, rtol=0, atol=1e-13) == (True, "2 rows OK")


@pytest.mark.parametrize(
    "pg_value, duck_value, rtol, atol, expected",
    [
        (1.0, 1.0000000004, 0, 0, False),
        (1.0, 1.0000000004, 0, 1e-9, True),
        (Decimal("37"), 37.000001, 1e-6, 1e-9, True),
        (Decimal("2.5"), 2.5, 0, 0, True),
        (Decimal("1.00000000000000000000000000001"), Decimal("0"), 0, 1, False),
    ],
)
def test_measurement_tolerance(pg_value, duck_value, rtol, atol, expected):
    pg = pd.DataFrame({"value": [pg_value]})
    duck = pd.DataFrame({"value": [duck_value]})

    ok, _ = compare_table(pg, duck, rtol, atol)
    assert ok == expected


@pytest.mark.parametrize(
    "sql_type, pg_oid, pg_value, duck_value, equal",
    [
        ("BIGINT", 20, 2**53 + 1, 2**53, False),
        ("BIGINT", 20, 2**53, 2**53 + 1, False),
        ("DECIMAL(25,10)", 1700,
         Decimal("1234567890.0000000001"), Decimal("1234567890.0000000002"), False),
        ("JSON", 114, [1, 2], "[1, 2]", True),
        ("JSON", 3802, None, "null", False),
        ("JSON", 114, 1000, "1e3", True),
        ("UUID", 2950, "00000000-0000-0000-0000-000000000001",
         "00000000-0000-0000-0000-000000000001", True),
        ("UUID", 2950, "00000000-0000-0000-0000-000000000001",
         "00000000-0000-0000-0000-000000000002", False),
        ("TIMESTAMP_NS", 1114, datetime(2150, 1, 2, 3, 4, 5, 123456),
         "2150-01-02 03:04:05.123456000", True),
        ("TIMESTAMP_NS", 1114, datetime(2150, 1, 2, 3, 4, 5, 123456),
         "2150-01-02 03:04:05.123456001", False),
    ],
)
def test_database_reads_preserve_exact_values_with_nulls(
    tmp_path, monkeypatch, capsys, sql_type, pg_oid, pg_value, duck_value, equal
):
    duckdb = pytest.importorskip("duckdb")
    psycopg2 = pytest.importorskip("psycopg2")
    path = tmp_path / "concepts.duckdb"
    with duckdb.connect(str(path)) as conn:
        if sql_type == "JSON":
            # Some old DuckDB distributions ship JSON as a separate extension.
            conn.execute("SET autoinstall_known_extensions = false")
            try:
                conn.execute("SELECT CAST('{}' AS JSON)").fetchone()
            except duckdb.Error as exc:
                pytest.skip(f"DuckDB JSON extension unavailable: {exc}")
        conn.execute("CREATE SCHEMA derived")
        conn.execute(f"CREATE TABLE derived.sample (value {sql_type})")
        if sql_type == "TIMESTAMP_NS":
            # Older DuckDB releases truncate a timestamp string on input.
            stamps = pd.Series([duck_value, None], dtype="datetime64[ns]")
            conn.register("stamps", stamps.to_frame("value"))
            conn.execute("INSERT INTO derived.sample SELECT value FROM stamps")
        else:
            conn.execute("INSERT INTO derived.sample VALUES (?), (NULL)", [duck_value])

    # Use the native values and column description a psycopg2 cursor returns.
    pg = Mock()
    cursor = pg.cursor.return_value
    cursor.description = [psycopg2.extensions.Column("value", pg_oid)]
    cursor.fetchall.side_effect = [[("sample",)], [(pg_value,), (None,)]]
    monkeypatch.setattr(psycopg2, "connect", lambda dsn: pg)

    result = compare_concepts("", str(path), "derived", rtol=0, atol=0)
    assert result == (0 if equal else 1)
    message = "2 rows OK" if equal else "1 differing cells in columns: value(1)"
    assert message in capsys.readouterr().out
