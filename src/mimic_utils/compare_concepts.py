"""Cross-engine equivalence check for the generated MIMIC-IV derived concepts.

Builds the derived concepts in PostgreSQL and DuckDB (done by the caller / CI),
then compares every table in the derived schema row-for-row.

Each table is compared on:
  * presence in both engines,
  * row count,
  * content -- rows are canonicalised (numeric columns rounded, then all columns
    sorted) and aligned, then compared cell-by-cell with a float tolerance.

The comparison returns a non-zero exit code if any non-ignored table differs, so
it can gate CI.

Usage (via the mimic_utils CLI):
    mimic_utils compare_concepts \
        --pg "host=localhost dbname=mimic user=postgres" \
        --duckdb /path/to/mimic4.db \
        [--schema mimiciv_derived] [--rtol 1e-6] [--atol 1e-9] \
        [--ignore table_a,table_b]
"""
import numpy as np
import pandas as pd


def _fetch_df(cursor_or_rel, table, schema, engine):
    """Read ``schema.table`` from one engine into a DataFrame with lower-cased columns."""
    if engine == "postgres":
        cursor_or_rel.execute(f'SELECT * FROM {schema}."{table}"')
        cols = [c[0] for c in cursor_or_rel.description]
        df = pd.DataFrame(cursor_or_rel.fetchall(), columns=cols)
    else:  # duckdb
        df = cursor_or_rel.sql(f'SELECT * FROM {schema}."{table}"').df()
    df.columns = [c.lower() for c in df.columns]
    return df


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


def _as_numeric(series):
    """Return a float Series if every non-null value coerces, else None."""
    if _is_datetime_like_series(series):
        return None
    coerced = pd.to_numeric(series, errors="coerce")
    if coerced.isna().sum() == series.isna().sum():
        return coerced.astype(float)
    return None


def _is_datetime_like_series(series):
    """Return True when values are already datetimes, even if stored as object dtype."""
    if pd.api.types.is_datetime64_any_dtype(series.dtype) or pd.api.types.is_datetime64tz_dtype(series.dtype):
        return True
    non_null = series.dropna()
    if non_null.empty:
        return False
    sample = non_null.iloc[0]
    return isinstance(sample, (pd.Timestamp, np.datetime64)) or hasattr(sample, "tzinfo")


def _as_datetime(series):
    """Return a datetime Series if every non-null value parses, else None."""
    import warnings
    with warnings.catch_warnings():
        warnings.simplefilter("ignore")  # silence per-element parse fallback notices
        coerced = pd.to_datetime(series, errors="coerce")
    if coerced.isna().sum() == series.isna().sum():
        if pd.api.types.is_datetime64tz_dtype(coerced.dtype):
            coerced = coerced.dt.tz_localize(None)
        return coerced
    return None


def _column_kinds(pg_df, dk_df):
    """Classify each column jointly as 'num', 'dt' or 'str' (numeric tried first
    so integer ids are not mistaken for datetimes)."""
    kinds = {}
    for col in pg_df.columns:
        if _as_numeric(pg_df[col]) is not None and _as_numeric(dk_df[col]) is not None:
            kinds[col] = "num"
        elif _as_datetime(pg_df[col]) is not None and _as_datetime(dk_df[col]) is not None:
            kinds[col] = "dt"
        else:
            kinds[col] = "str"
    return kinds


def _canon(series, kind, decimals):
    """Canonical, type-correct representation used for both sorting and comparison."""
    if kind == "num":
        return _as_numeric(series).round(decimals)
    if kind == "dt":
        return _as_datetime(series)
    return series.astype("string").fillna("\x00")


def compare_table(pg_df, duck_df, rtol, atol):
    """Return (ok, message) for one table's two DataFrames."""
    if set(pg_df.columns) != set(duck_df.columns):
        only_pg = sorted(set(pg_df.columns) - set(duck_df.columns))
        only_dk = sorted(set(duck_df.columns) - set(pg_df.columns))
        return False, f"column mismatch (pg-only={only_pg}, duckdb-only={only_dk})"

    if len(pg_df) != len(duck_df):
        return False, f"row count differs: postgres={len(pg_df)} duckdb={len(duck_df)}"

    duck_df = duck_df[pg_df.columns]  # align column order
    kinds = _column_kinds(pg_df, duck_df)
    # round numerics to a tolerance-consistent #decimals so tiny float diffs do
    # not reorder rows during the sort-align step
    decimals = max(0, int(round(-np.log10(atol)))) if atol > 0 else 9

    pg_c = pd.DataFrame({c: _canon(pg_df[c], kinds[c], decimals) for c in pg_df.columns})
    dk_c = pd.DataFrame({c: _canon(duck_df[c], kinds[c], decimals) for c in pg_df.columns})

    order = list(pg_c.columns)
    pg_c = pg_c.sort_values(by=order, kind="mergesort", na_position="first").reset_index(drop=True)
    dk_c = dk_c.sort_values(by=order, kind="mergesort", na_position="first").reset_index(drop=True)

    mismatched_cells = 0
    bad_cols = []
    for col in order:
        a, b = pg_c[col], dk_c[col]
        if kinds[col] == "num":
            close = np.isclose(a.to_numpy(float), b.to_numpy(float), rtol=rtol, atol=atol, equal_nan=True)
        elif kinds[col] == "dt":
            close = (a.to_numpy() == b.to_numpy()) | (a.isna().to_numpy() & b.isna().to_numpy())
        else:
            close = (a == b).to_numpy()
        n_bad = int((~close).sum())
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
