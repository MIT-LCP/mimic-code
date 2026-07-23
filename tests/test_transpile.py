"""Unit tests for the BigQuery -> {PostgreSQL, DuckDB} transpiler.

Includes:

1. Unit tests assert the exact SQL produced for each transform.
2. A validity sweep transpiles every real concept and parses the output back,
   catching anything that produces unparseable SQL.
3. Custom functions implemented in the dialects.
"""
import re
from pathlib import Path

import pytest

from mimic_utils.transpile import transpile_query

REPO_ROOT = Path(__file__).resolve().parent.parent
CONCEPTS_DIR = REPO_ROOT / "mimic-iv" / "concepts"
CONCEPTS_III_DIR = REPO_ROOT / "mimic-iii" / "concepts"
# folders/files not part of the transpiled MIMIC-III concepts (see the
# transpile-concepts action): tutorials, per-dialect code, analysis helpers,
# and one concept that has never been runnable on any engine.
CONCEPTS_III_EXCLUDED_DIRS = {"cookbook", "other-languages", "functions"}
CONCEPTS_III_EXCLUDED_FILES = {"pivot/pivoted_oasis.sql"}
MIMIC_III_SCHEMA_MAP = {"mimiciii_clinical": "mimiciii", "mimiciii_notes": "mimiciii"}


def t(bq: str, dialect: str) -> str:
    """Transpile and collapse whitespace, for stable comparison against goldens."""
    return re.sub(r"\s+", " ", transpile_query(bq, "bigquery", dialect)).strip()


# (name, bigquery input, dialect, expected normalized output)
TEST_CASES = [
    # catalog stripping (dialect-agnostic AST walk)
    ("catalog_pg", "SELECT * FROM `physionet-data.mimiciv_derived.icustay_times` it",
     "postgres", "SELECT * FROM mimiciv_derived.icustay_times AS it"),
    ("catalog_duckdb", "SELECT * FROM `physionet-data.mimiciv_icu.chartevents` ce",
     "duckdb", "SELECT * FROM mimiciv_icu.chartevents AS ce"),

    # DATETIME_DIFF -> integer boundary count (postgres)
    ("diff_hour_pg", "SELECT DATETIME_DIFF(a.outtime, a.intime, HOUR) FROM t a", "postgres",
     "SELECT CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', a.outtime) "
     "- DATE_TRUNC('hour', a.intime)) / 3600 AS BIGINT) FROM t AS a"),
    ("diff_minute_pg", "SELECT DATETIME_DIFF(a.b, a.c, MINUTE) FROM t a", "postgres",
     "SELECT CAST(EXTRACT(EPOCH FROM DATE_TRUNC('minute', a.b) "
     "- DATE_TRUNC('minute', a.c)) / 60 AS BIGINT) FROM t AS a"),
    ("diff_second_pg", "SELECT DATETIME_DIFF(a.b, a.c, SECOND) FROM t a", "postgres",
     "SELECT CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', a.b) "
     "- DATE_TRUNC('second', a.c)) / 1 AS BIGINT) FROM t AS a"),
    ("diff_day_pg", "SELECT DATETIME_DIFF(a.dischtime, a.admittime, DAY) FROM t a", "postgres",
     "SELECT (CAST(a.dischtime AS DATE) - CAST(a.admittime AS DATE)) FROM t AS a"),
    ("diff_year_pg", "SELECT DATETIME_DIFF(a.b, a.c, YEAR) FROM t a", "postgres",
     "SELECT CAST(EXTRACT(YEAR FROM a.b) - EXTRACT(YEAR FROM a.c) AS BIGINT) FROM t AS a"),
    # DuckDB handles DATETIME_DIFF natively (boundary count), operands swapped
    ("diff_hour_duckdb", "SELECT DATETIME_DIFF(a.outtime, a.intime, HOUR) FROM t a", "duckdb",
     "SELECT DATE_DIFF('HOUR', a.intime, a.outtime) FROM t AS a"),

    # DATETIME_ADD / DATETIME_SUB -> interval arithmetic (postgres)
    ("sub_literal_pg", "SELECT DATETIME_SUB(ie.intime, INTERVAL '6' HOUR) FROM t ie", "postgres",
     "SELECT ie.intime - INTERVAL '6' HOUR FROM t AS ie"),
    ("add_literal_pg", "SELECT DATETIME_ADD(x, INTERVAL 1 HOUR) FROM t", "postgres",
     "SELECT x + INTERVAL '1' HOUR FROM t"),
    ("add_expr_pg", "SELECT DATETIME_ADD(endtime, INTERVAL CAST(h AS INT64) HOUR) FROM t", "postgres",
     "SELECT endtime + CAST(h AS BIGINT) * INTERVAL '1' HOUR FROM t"),

    # DATETIME_TRUNC -> DATE_TRUNC with quoted unit (postgres)
    ("trunc_pg", "SELECT DATETIME_TRUNC(it.intime_hr, HOUR) FROM t it", "postgres",
     "SELECT DATE_TRUNC('hour', it.intime_hr) FROM t AS it"),

    # GENERATE_ARRAY -> ARRAY(SELECT ... GENERATE_SERIES) (postgres)
    ("generate_array_pg", "SELECT GENERATE_ARRAY(-24, 5) AS hrs FROM t", "postgres",
     "SELECT ARRAY(SELECT * FROM GENERATE_SERIES(-24, 5)) AS hrs FROM t"),
    # GENERATE_ARRAY -> list via generate_series (duckdb); must stay list for UNNEST
    ("generate_array_duckdb", "SELECT GENERATE_ARRAY(-24, 5) AS hrs FROM t", "duckdb",
     "SELECT (SELECT list(g) FROM generate_series(-24, 5) AS t(g)) AS hrs FROM t"),

    # handled natively by sqlglot 30.x (regression guards)
    ("datetime_date_pg", "SELECT DATETIME(me.chartdate) FROM t me", "postgres",
     "SELECT CAST(me.chartdate AS TIMESTAMP) FROM t AS me"),
    ("datetime_parts_pg", "SELECT DATETIME(pat.anchor_year, 1, 1, 0, 0, 0) FROM t pat", "postgres",
     "SELECT MAKE_TIMESTAMP(pat.anchor_year, 1, 1, 0, 0, 0) FROM t AS pat"),
    ("int64_cast_pg", "SELECT CAST(hr AS INT64) AS hr FROM t", "postgres",
     "SELECT CAST(hr AS BIGINT) AS hr FROM t"),

    # BigQuery NUMERIC == DECIMAL(38, 9), so both target dialects must pin the
    # precision and scale explicitly to preserve BigQuery semantics.
    ("numeric_cast_pg", "SELECT CAST(x AS NUMERIC) FROM t", "postgres",
     "SELECT CAST(x AS DECIMAL(38, 9)) FROM t"),
    ("numeric_cast_duckdb", "SELECT CAST(x AS NUMERIC) FROM t", "duckdb",
     "SELECT CAST(x AS DECIMAL(38, 9)) FROM t"),

    # REGEXP_EXTRACT: BigQuery returns the first capturing group if present
    # (whole match otherwise) and NULL when there is no match.
    # PostgreSQL's SUBSTRING(str FROM pattern) has identical semantics.
    ("regexp_extract_pg", r"SELECT REGEXP_EXTRACT(ne.text, 'Height: ([0-9]+)') FROM t ne", "postgres",
     r"SELECT SUBSTRING(ne.text FROM 'Height: ([0-9]+)') FROM t AS ne"),
    # DuckDB needs an explicit group index, and returns '' (not NULL) on no match.
    ("regexp_extract_group_duckdb", r"SELECT REGEXP_EXTRACT(ne.text, 'Height: ([0-9]+)') FROM t ne", "duckdb",
     r"SELECT NULLIF(REGEXP_EXTRACT(ne.text, 'Height: ([0-9]+)', 1), '') FROM t AS ne"),
    ("regexp_extract_nogroup_duckdb", r"SELECT REGEXP_EXTRACT(ne.text, '[0-9]+ cm') FROM t ne", "duckdb",
     r"SELECT NULLIF(REGEXP_EXTRACT(ne.text, '[0-9]+ cm'), '') FROM t AS ne"),

    # PARSE_DATETIME returns a timezone-naive DATETIME in BigQuery; the
    # PostgreSQL TO_TIMESTAMP result must be cast back to a naive TIMESTAMP.
    ("parse_datetime_pg", "SELECT PARSE_DATETIME('%Y-%m-%d %H:%M:%S', x) FROM t", "postgres",
     "SELECT CAST(TO_TIMESTAMP(x, 'YYYY-MM-DD HH24:MI:SS') AS TIMESTAMP) FROM t"),
    ("parse_datetime_duckdb", "SELECT PARSE_DATETIME('%Y-%m-%d %H:%M:%S', x) FROM t", "duckdb",
     "SELECT STRPTIME(x, '%Y-%m-%d %H:%M:%S') FROM t"),

    # BigQuery ROUND(float, n) has no direct PostgreSQL equivalent (two-arg
    # ROUND is only defined for NUMERIC), so the operand gains a cast...
    ("round_scale_pg", "SELECT ROUND(x, 2) FROM t", "postgres",
     "SELECT ROUND(CAST(x AS NUMERIC), 2) FROM t"),
    # ...unless it is already a decimal, as in the MIMIC-IV concepts.
    ("round_cast_pg", "SELECT ROUND(CAST(x AS NUMERIC), 2) FROM t", "postgres",
     "SELECT ROUND(CAST(x AS DECIMAL(38, 9)), 2) FROM t"),
    ("round_noscale_pg", "SELECT ROUND(x) FROM t", "postgres",
     "SELECT ROUND(x) FROM t"),
]


@pytest.mark.parametrize("name,bq,dialect,expected", TEST_CASES, ids=[g[0] for g in TEST_CASES])
def test_cases_with_expected_output(name, bq, dialect, expected):
    assert t(bq, dialect) == expected


def test_unnest_alias_preserved():
    # GENERATE_ARRAY column unnested downstream must stay an array + valid alias
    bq = "SELECT h FROM a CROSS JOIN UNNEST(a.hrs) AS h"
    for dialect in ("postgres", "duckdb"):
        assert "UNNEST(a.hrs)" in t(bq, dialect)


def test_duckdb_comments_stripped():
    # DuckDB does not accept /* */ block comments
    bq = "/* a comment */ SELECT 1 AS x"
    assert "/*" not in transpile_query(bq, "bigquery", "duckdb")
    assert "/*" in transpile_query(bq, "bigquery", "postgres")


@pytest.mark.parametrize(
    "bq",
    [
        "SELECT TIMESTAMP('2150-01-01 00:00:00') AS ts",
        "SELECT CAST(DATETIME '2150-01-01 00:00:00' AS TIMESTAMP) AS ts",
    ],
)
def test_timestamp_outputs_stay_timezone_naive(bq):
    for dialect in ("postgres", "duckdb"):
        assert "TIMESTAMPTZ" not in transpile_query(bq, "bigquery", dialect)


def test_unsupported_dialect_raises():
    with pytest.raises(ValueError):
        transpile_query("SELECT 1", "bigquery", "mysql")


def test_schema_map_renames_dataset():
    # MIMIC-III datasets map onto the single `mimiciii` schema used by the
    # local database builds; the derived dataset is left untouched.
    bq = ("SELECT * FROM `physionet-data.mimiciii_clinical.icustays` ie "
          "INNER JOIN `physionet-data.mimiciii_derived.icustay_times` it "
          "ON ie.icustay_id = it.icustay_id")
    out = re.sub(r"\s+", " ", transpile_query(bq, "bigquery", "postgres", MIMIC_III_SCHEMA_MAP))
    assert "FROM mimiciii.icustays AS ie" in out
    assert "JOIN mimiciii_derived.icustay_times AS it" in out


# ---------------------------------------------------------------------------
# 2. Every concept transpiles and the output parses back
# ---------------------------------------------------------------------------

CONCEPT_FILES = sorted(CONCEPTS_DIR.rglob("*.sql"))

CONCEPT_III_FILES = [
    f for f in sorted(CONCEPTS_III_DIR.rglob("*.sql"))
    if not CONCEPTS_III_EXCLUDED_DIRS & set(f.relative_to(CONCEPTS_III_DIR).parts[:-1])
    and f.relative_to(CONCEPTS_III_DIR).as_posix() not in CONCEPTS_III_EXCLUDED_FILES
]


@pytest.mark.skipif(not CONCEPT_FILES, reason="concept SQL files not found")
@pytest.mark.parametrize("dialect", ["postgres", "duckdb"])
@pytest.mark.parametrize("sql_file", CONCEPT_FILES, ids=lambda p: str(p.relative_to(CONCEPTS_DIR)))
def test_concept_transpiles_and_reparses(sql_file, dialect):
    import sqlglot
    out = transpile_query(sql_file.read_text(), "bigquery", dialect)
    # parse-back: the generated SQL must be syntactically valid in the target dialect
    sqlglot.parse_one(out, read=dialect)


@pytest.mark.skipif(not CONCEPT_III_FILES, reason="mimic-iii concept SQL files not found")
@pytest.mark.parametrize("dialect", ["postgres", "duckdb"])
@pytest.mark.parametrize(
    "sql_file", CONCEPT_III_FILES, ids=lambda p: str(p.relative_to(CONCEPTS_III_DIR))
)
def test_mimic_iii_concept_transpiles_and_reparses(sql_file, dialect):
    import sqlglot
    out = transpile_query(
        sql_file.read_text(encoding="utf-8-sig"), "bigquery", dialect, MIMIC_III_SCHEMA_MAP
    )
    parsed = sqlglot.parse_one(out, read=dialect)
    # every table reference must use the mapped schema names (comments may
    # still mention the BigQuery dataset names)
    schemas = {t.args["db"].name for t in parsed.find_all(sqlglot.exp.Table) if t.args.get("db")}
    assert schemas <= {"mimiciii", "mimiciii_derived"}, schemas


# ---------------------------------------------------------------------------
# 3. Custom function checks.
# ---------------------------------------------------------------------------

# date-diff comparison
# (end, start, unit, expected BigQuery boundary-count result)
DIFF_CASES = [
    ("2150-01-01 02:10:00", "2150-01-01 01:50:00", "HOUR", 1),   # crosses 02:00
    ("2150-01-01 01:59:00", "2150-01-01 01:01:00", "HOUR", 0),   # no boundary
    ("2150-01-02 01:00:00", "2150-01-01 23:00:00", "DAY", 1),    # crosses midnight
    ("2150-01-01 23:00:00", "2150-01-01 01:00:00", "DAY", 0),    # same day
    ("2155-06-15 00:00:00", "2150-01-01 00:00:00", "YEAR", 5),
    ("2150-01-01 00:01:00", "2150-01-01 00:00:59", "MINUTE", 1),
    ("2150-01-01 00:00:30", "2150-01-01 00:00:10", "SECOND", 20),
    ("2150-01-01 01:00:00", "2150-01-01 03:00:00", "HOUR", -2),  # negative direction
]


@pytest.mark.parametrize("end,start,unit,expected", DIFF_CASES)
def test_datetime_diff_semantics_duckdb(end, start, unit, expected):
    duckdb = pytest.importorskip("duckdb")
    bq = f"SELECT DATETIME_DIFF(DATETIME '{end}', DATETIME '{start}', {unit}) AS d"
    sql = transpile_query(bq, "bigquery", "duckdb")
    assert duckdb.sql(sql).fetchone()[0] == expected
