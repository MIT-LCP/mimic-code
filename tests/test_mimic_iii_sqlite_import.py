"""Unit tests for MIMIC-III SQLite CSV discovery helpers."""

import importlib.util
import sys
from pathlib import Path


def _load_import_module():
    path = (
        Path(__file__).resolve().parents[1]
        / "mimic-iii"
        / "buildmimic"
        / "sqlite"
        / "import.py"
    )
    spec = importlib.util.spec_from_file_location("mimic_iii_sqlite_import", path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    # Avoid executing the __main__ import path; load definitions only.
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_table_name_from_csv_literal_suffix():
    mod = _load_import_module()
    assert mod._table_name_from_csv("ADMISSIONS.csv") == "admissions"
    assert mod._table_name_from_csv("ADMISSIONS.csv.gz") == "admissions"
    # Literal suffix: do not strip trailing characters that happen to match
    # letters inside ".csv" (historical str.strip bug class).
    assert mod._table_name_from_csv("notacsvfile.csv") == "notacsvfile"


def test_data_files_prefer_csv_gz_over_plain_csv():
    mod = _load_import_module()
    mapping = mod._data_files_by_table(
        csv_paths=["ADMISSIONS.csv", "PATIENTS.csv"],
        csv_gz_paths=["ADMISSIONS.csv.gz"],
    )
    assert mapping["admissions"] == "ADMISSIONS.csv.gz"
    assert mapping["patients"] == "PATIENTS.csv"


def test_data_files_include_plain_csv_only_tables():
    mod = _load_import_module()
    mapping = mod._data_files_by_table(
        csv_paths=["CHARTEVENTS.csv"],
        csv_gz_paths=[],
    )
    assert mapping == {"chartevents": "CHARTEVENTS.csv"}
