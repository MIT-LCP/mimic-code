# Style guide for the MIMIC Code Repository

## Overview

This guide provides some general guidelines on formatting code for the MIMIC Code Repository. Maintaining a consistent-ish style across the repository should make the code simpler to read and reuse.

## Required header information

Please include the following header information at the top of your code:

```
-- ------------------------------------------------------------------
-- Title: Short descriptive title.
-- Description: More detailed description explaining the purpose.
-- ------------------------------------------------------------------
```

We would also recommend adding in any relevant references or usage notes in the top of the query.

## SQL

- Always use uppercase for the reserved keywords like SELECT and WHERE.
- Use lower case for other words such as table and column names.

For more detail, following the guidelines at: http://www.sqlstyle.guide/

## Python

Following PEP8 guidelines is recommended. Read more here: https://www.python.org/dev/peps/pep-0008/

## SQL style checking

Pull requests that change `mimic-iv/concepts/**/*.sql` are linted by the SQLFluff GitHub Action (`.github/workflows/lint_sqlfluff.yml`). Findings are posted as pull-request annotations when the workflow has permission to write checks.

## Unit tests

Lightweight helpers (for example MIMIC-III SQLite CSV discovery) are checked on every pull request by `.github/workflows/unit-tests.yml`.
