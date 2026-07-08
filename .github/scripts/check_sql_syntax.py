#!/usr/bin/env python3
"""Validate that every BigQuery concept SQL file parses with sqlglot.

Usage: ``python .github/scripts/check_sql_syntax.py [ROOT ...]``
(defaults to ``mimic-iv/concepts``). Exits non-zero if any file fails to parse.
"""
from __future__ import annotations

import sys
from pathlib import Path

import sqlglot
from sqlglot.errors import ParseError


def main(argv: list[str]) -> int:
    roots = [Path(p) for p in argv[1:]] or [Path("mimic-iv/concepts")]
    files = sorted({f for root in roots for f in root.rglob("*.sql")})
    if not files:
        print(f"::error::No .sql files found under: {', '.join(map(str, roots))}")
        return 1

    failures = 0
    for f in files:
        try:
            sqlglot.parse_one(f.read_text(), read="bigquery")
        except ParseError as exc:
            failures += 1
            # Keep the GitHub annotation to a single line so it anchors to the
            # file; the full multi-line message follows in the log.
            first_line = str(exc).splitlines()[0]
            print(f"::error file={f}::sqlglot failed to parse: {first_line}")
            print(str(exc))
        else:
            print(f"OK  {f}")

    print()
    if failures:
        print(f"{failures} of {len(files)} concept file(s) failed to parse.")
        return 1
    print(f"All {len(files)} concept file(s) parsed successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
