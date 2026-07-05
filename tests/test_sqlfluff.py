"""SQLFluff linting of the mimic-iv/concepts folder."""
import json
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
CONCEPTS_DIR = REPO_ROOT / "mimic-iv" / "concepts"
CONCEPT_FILES = sorted(CONCEPTS_DIR.rglob("*.sql"))

sqlfluff = pytest.importorskip("sqlfluff")


@pytest.fixture(scope="session")
def lint_results():
    """Run ``sqlfluff lint`` once over the whole concepts folder.

    Returns a mapping of absolute file path -> list of violation dicts. Using
    a single invocation (across all cores) is far faster than spawning
    sqlfluff per file, while the per-file parametrization below still gives a
    granular failure for whichever file is at fault.
    """
    proc = subprocess.run(
        [
            sys.executable, "-m", "sqlfluff", "lint",
            "--format", "json",
            "--processes", "0",
            str(CONCEPTS_DIR),
        ],
        cwd=REPO_ROOT,
        capture_output=True,
        text=True,
    )
    # sqlfluff exits non-zero when violations are found; that is expected and
    # is asserted per file below. A missing/empty payload means it crashed.
    if not proc.stdout.strip():
        raise RuntimeError(
            f"sqlfluff produced no output (exit {proc.returncode}):\n{proc.stderr}"
        )
    results = json.loads(proc.stdout)
    return {
        str((REPO_ROOT / entry["filepath"]).resolve()): entry.get("violations", [])
        for entry in results
    }


@pytest.mark.skipif(not CONCEPT_FILES, reason="concept SQL files not found")
@pytest.mark.parametrize(
    "sql_file", CONCEPT_FILES, ids=lambda p: str(p.relative_to(CONCEPTS_DIR))
)
def test_concept_passes_sqlfluff(sql_file, lint_results):
    violations = lint_results.get(str(sql_file.resolve()), [])
    if violations:
        lines = "\n".join(
            f"  L:{v['start_line_no']} P:{v['start_line_pos']} "
            f"{v['code']} {v['description']}"
            for v in violations
        )
        pytest.fail(
            f"{sql_file.relative_to(REPO_ROOT)} has SQLFluff violations:\n{lines}"
        )
