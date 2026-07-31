#!/usr/bin/env bash
# Local mirror of .github/workflows/lint_sqlfluff.yml for changed concept SQL.
set -euo pipefail
BASE_REF="${1:-origin/main}"
files="$(git diff --name-only --diff-filter=AM "${BASE_REF}...HEAD" -- 'mimic-iv/concepts/' \
  | grep -E '[.]sql$' || true)"
if [[ -z "${files}" ]]; then
  echo "No changed mimic-iv/concepts SQL files versus ${BASE_REF}."
  exit 0
fi
# shellcheck disable=SC2086
sqlfluff lint ${files}
