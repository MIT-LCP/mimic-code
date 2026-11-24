"""Cross-engine equivalence check for the generated MIMIC-IV derived concepts.

Builds the derived concepts in PostgreSQL and DuckDB (done by the caller / CI),
then compares every table in the derived schema row-for-row.

Each table is compared on:
  * presence in both engines,
  * row count,
  * content -- rows are aligned and compared cell-by-cell. Integers and text
    are compared exactly. Tolerances apply to continuous numeric values.

The comparison returns a non-zero exit code if any non-ignored table differs, so
it can gate CI.

Usage (via the mimic_utils CLI):
    mimic_utils compare_concepts \
        --pg "host=localhost dbname=mimic user=postgres" \
        --duckdb /path/to/mimic4.db \
        [--schema mimiciv_derived] [--rtol 1e-6] [--atol 1e-9] \
        [--ignore table_a,table_b]
"""
from decimal import Decimal
from fractions import Fraction

import numpy as np
import pandas as pd


def _fetch_df(cursor_or_rel, table, schema, engine):
    """Read ``schema.table`` from one engine into a DataFrame with lower-cased columns."""
    if engine == "postgres":
        cursor_or_rel.execute(f'SELECT * FROM {schema}."{table}"')
        cols = [c[0] for c in cursor_or_rel.description]
        # Inference turns an integer column containing NULL into float64.
        df = pd.DataFrame(cursor_or_rel.fetchall(), columns=cols, dtype=object)
    else:  # duckdb
        rel = cursor_or_rel.sql(f'SELECT * FROM {schema}."{table}"')
        # NumPy narrows DECIMAL and wide integers (including nullable BIGINT
        # in older DuckDB). Keep df() for columns such as TIMESTAMP_NS.
        converters = {
            "decimal": Decimal, "bigint": int, "ubigint": int,
            "hugeint": int, "uhugeint": int, "bignum": int,
            "uuid": str,  # psycopg2 returns UUID as text by default.
        }
        restore = {}
        replacements = []
        for name, sql_type in zip(rel.columns, rel.types):
            if str(sql_type) == "JSON":
                # psycopg2 decodes JSON numbers, while DuckDB returns text.
                # Only an unquoted JSON number gets numeric comparison.
                restore[name] = _json_number_or_text
            elif sql_type.id in converters:
                quoted = '"' + name.replace('"', '""') + '"'
                replacements.append(f"CAST({quoted} AS VARCHAR) AS {quoted}")
                restore[name] = converters[sql_type.id]
        if replacements:
            rel = rel.project(f"* REPLACE ({', '.join(replacements)})")
        df = rel.df()
        for name, convert in restore.items():
            df[name] = pd.Series(
                [None if pd.isna(v) else convert(v) for v in df[name]], dtype=object, index=df.index
            )
    df.columns = [c.lower() for c in df.columns]
    return df


def _json_number_or_text(value):
    return Decimal(value) if value.lstrip().startswith(tuple("-0123456789")) else value


def _list_tables_pg(cur, schema):
    cur.execute(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = %s ORDER BY table_name",
        (schema,),
    )
    return [r[0] for r in cur.fetchall()]


def _list_tables_duckdb(con, schema):
    rows = con.execute(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = ? ORDER BY table_name",
        [schema],
    ).fetchall()
    return [r[0] for r in rows]


def _comparison_kind(left, right):
    # Classify native values from the drivers. A VARCHAR that looks like a
    # number or date is still text; integer widths can differ across engines.
    # DataFrames with a nullable identifier can arrive with a float dtype.
    if isinstance(left.name, str) and left.name.endswith("_id"):
        return "exact"
    # Some pandas versions infer mixed-integer-float for native floats plus None.
    kinds = {pd.api.types.infer_dtype(s.dropna()) for s in (left, right)} - {"empty"}
    if "mixed" in kinds or "mixed-integer" in kinds:
        # Lists, mappings and other driver objects need sortable values.
        return "string"
    if kinds and kinds <= {"date", "datetime", "datetime64"}:
        return "datetime"
    if kinds and kinds <= {"floating", "decimal"}:
        return "decimal" if "decimal" in kinds else "float"
    return "exact"


def _wall_time(series):
    if pd.api.types.is_datetime64_any_dtype(series.dtype):
        return series.dt.tz_localize(None)
    return series.map(lambda value: pd.Timestamp(value).tz_localize(None), na_action="ignore")


def _align_rows(frame, kinds, atol, use_tolerance):
    aligned = frame.copy(deep=False)
    for col, kind in kinds.items():
        if kind == "datetime":
            aligned[col] = _wall_time(frame[col])
        elif kind == "string":
            aligned[col] = frame[col].astype("string")

    # Exact columns identify rows before approximate measurements break ties.
    order = sorted(kinds, key=lambda col: kinds[col] in {"float", "decimal"})

    def sort_key(series):
        if use_tolerance and kinds[series.name] in {"float", "decimal"}:
            decimals = max(0, int(round(-np.log10(atol)))) if atol > 0 else 9
            return series.astype(float).round(decimals)
        return series

    # Start in native value order so that rounded-key ties are independent
    # of the input order. Compare the original values after alignment.
    aligned = aligned.sort_values(by=order, kind="mergesort", na_position="first")
    if use_tolerance and any(k in {"float", "decimal"} for k in kinds.values()):
        aligned = aligned.sort_values(by=order, key=sort_key, kind="mergesort", na_position="first")
    return aligned.reset_index(drop=True)


def _decimal_close(a, b, rtol, atol):
    # Subtract before narrowing either operand to a binary float. A DECIMAL
    # can have many more significant digits than float64.
    a = a if isinstance(a, Decimal) else Decimal.from_float(float(a))
    b = b if isinstance(b, Decimal) else Decimal.from_float(float(b))
    if a == b:
        return True
    if not (a.is_finite() and b.is_finite()):
        return False
    # Decimal arithmetic rounds to the active context (usually 28 digits).
    # The stored operands and the tolerance boundary can exceed that precision.
    a, b = Fraction(a), Fraction(b)
    return abs(a - b) <= atol + rtol * abs(b)


def compare_table(pg_df, duck_df, rtol, atol):
    """Return (ok, message) for one table's two DataFrames."""
    if set(pg_df.columns) != set(duck_df.columns):
        only_pg = sorted(set(pg_df.columns) - set(duck_df.columns))
        only_dk = sorted(set(duck_df.columns) - set(pg_df.columns))
        return False, f"column mismatch (pg-only={only_pg}, duckdb-only={only_dk})"

    if len(pg_df) != len(duck_df):
        return False, f"row count differs: postgres={len(pg_df)} duckdb={len(duck_df)}"

    duck_df = duck_df[pg_df.columns]  # align column order
    kinds = {col: _comparison_kind(pg_df[col], duck_df[col]) for col in pg_df}
    use_tolerance = rtol != 0 or atol != 0
    pg_c = _align_rows(pg_df, kinds, atol, use_tolerance)
    dk_c = _align_rows(duck_df, kinds, atol, use_tolerance)

    mismatched_cells = 0
    bad_cols = []
    for col, kind in kinds.items():
        a, b = pg_c[col], dk_c[col]
        missing_a, missing_b = a.isna(), b.isna()
        n_bad = int((missing_a != missing_b).sum())
        present = ~(missing_a | missing_b)
        a, b = a[present], b[present]
        if use_tolerance and kind == "float":
            close = np.isclose(a.to_numpy(float), b.to_numpy(float), rtol=rtol, atol=atol)
            n_bad += int((~close).sum())
        elif use_tolerance and kind == "decimal":
            rel, abs_tol = Fraction(float(rtol)), Fraction(float(atol))
            n_bad += sum(not _decimal_close(x, y, rel, abs_tol) for x, y in zip(a, b))
        else:
            # Object comparison avoids promoting int64 or Decimal to float64
            # when the other engine returned a different numeric type.
            n_bad += int((a.astype(object) != b.astype(object)).sum())
        if n_bad:
            mismatched_cells += n_bad
            bad_cols.append(f"{col}({n_bad})")

    if mismatched_cells:
        return False, f"{mismatched_cells} differing cells in columns: {', '.join(bad_cols)}"
    return True, f"{len(pg_df)} rows OK"


def compare_concepts(pg, duckdb_path, schema="mimiciv_derived", rtol=1e-6, atol=1e-9, ignore=""):
    """Compare every table in ``schema`` between PostgreSQL and DuckDB.

    Returns 1 if any non-ignored table differs (or is missing from one engine),
    else 0, so the caller can use it as a process exit code.
    """
    import duckdb
    import psycopg2

    ignore = {t.strip() for t in ignore.split(",") if t.strip()}

    pg_conn = psycopg2.connect(pg)
    pg_conn.set_session(readonly=True, autocommit=True)
    cur = pg_conn.cursor()
    duck = duckdb.connect(duckdb_path, read_only=True)

    pg_tables = set(_list_tables_pg(cur, schema))
    duck_tables = set(_list_tables_duckdb(duck, schema))
    all_tables = sorted(pg_tables | duck_tables)

    print(f"Comparing schema '{schema}': "
          f"{len(pg_tables)} postgres tables, {len(duck_tables)} duckdb tables "
          f"(rtol={rtol}, atol={atol})\n")

    failures, skipped, passed = [], [], []
    for table in all_tables:
        if table in ignore:
            skipped.append(table)
            print(f"  SKIP  {table}")
            continue
        if table not in pg_tables or table not in duck_tables:
            where = "duckdb only" if table in duck_tables else "postgres only"
            failures.append(table)
            print(f"  FAIL  {table}: missing ({where})")
            continue
        try:
            pg_df = _fetch_df(cur, table, schema, "postgres")
            dk_df = _fetch_df(duck, table, schema, "duckdb")
            ok, msg = compare_table(pg_df, dk_df, rtol, atol)
        except Exception as e:  # noqa: BLE001 - report and continue
            ok, msg = False, f"error during comparison: {type(e).__name__}: {e}"
        (passed if ok else failures).append(table)
        print(f"  {'OK  ' if ok else 'FAIL'}  {table}: {msg}")

    print(f"\nSummary: {len(passed)} matched, {len(failures)} failed, {len(skipped)} skipped")
    if failures:
        print("FAILED tables: " + ", ".join(failures))
        return 1
    print("All compared concepts are equivalent across PostgreSQL and DuckDB.")
    return 0
