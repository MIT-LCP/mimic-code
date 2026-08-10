#!/bin/bash
# Build MIMIC-IV in DuckDB: create the schema, load the data, then derive the
# concepts.
#
# Usage:
#   ./build_mimic.sh <mimic_data_dir> [output_db]
#
# <mimic_data_dir> is the directory holding the hosp/ and icu/ subfolders.
# Compressed (.csv.gz) and uncompressed (.csv) data are both supported; DuckDB
# decompresses by file extension, so no separate loader is needed.
#
# Each step is recorded in a progress table once it completes, so an
# interrupted build will resume where it stopped. The table lives inside the
# database file, so the resume state travels with it.
#
# Environment:
#   MIMIC_DATA_DIR       used when <mimic_data_dir> is not given
#   MIMIC_DB             used when [output_db] is not given (default mimic4.db)
#   MIMIC_MAKE_CONCEPTS  derive the concepts into mimiciv_derived (default true)
#   MIMIC_VALIDATE       check tables against expected row counts (default true)
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR
readonly CONCEPTS_DIR="${SCRIPT_DIR}/../../concepts_duckdb"
# The schema and the row count checks are shared with the postgres build rather
# than duplicated. create.sql needs the patches in patch_create_sql below;
# validate.sql is plain ANSI SQL and runs unmodified.
readonly POSTGRES_DIR="${SCRIPT_DIR}/../postgres"
readonly PROGRESS_TABLE=mimiciv_build_progress

DATA_DIR=""
DB=""

# -f tells DuckDB to stop at the first failing statement and exit non-zero.
duckdb_run() { duckdb "${DB}" -f "$1"; }
duckdb_cmd() { duckdb "${DB}" -c "$1"; }
duckdb_val() { duckdb "${DB}" -noheader -list -c "$1"; }

# Lowercase string before checking value
is_true() { [ "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" = "true" ]; }

usage() {
    echo "Usage: $(basename "$0") <mimic_data_dir> [output_db]" >&2
    echo "       mimic_data_dir  the directory containing the hosp/ and icu/ subfolders" >&2
    echo "       output_db       filename for the duckdb file (default mimic4.db)" >&2
}

step_done() {
    [ "$(duckdb_val "SELECT EXISTS (SELECT 1 FROM ${PROGRESS_TABLE} WHERE step = '$1')")" = "true" ]
}

run_step() {
    local step=$1
    shift
    if step_done "${step}"; then
        echo "== ${step}: already done, skipping"
        return
    fi
    echo "== ${step}: starting"
    "$@"
    duckdb_cmd "INSERT INTO ${PROGRESS_TABLE} (step) VALUES ('${step}') ON CONFLICT DO NOTHING" >/dev/null
    echo "== ${step}: done"
}

# The schema is defined once, in the postgres build. Three things in it are not
# valid or not desirable in DuckDB:
#  1. TIMESTAMP(NN) -- DuckDB does not accept a precision argument.
#  2. NOT NULL on mimiciv_hosp.microbiologyevents.spec_type_desc -- there is one
#     (!) zero-length string, which the import treats as NULL.
#  3. NOT NULL on mimiciv_hosp.prescriptions.drug -- likewise, zero-length
#     strings treated as NULL.
patch_create_sql() {
    sed -E \
        -e 's/TIMESTAMP\([0-9]+\)/TIMESTAMP/g' \
        -e 's/spec_type_desc(.+)NOT NULL/spec_type_desc\1/g' \
        -e 's/drug +(VARCHAR.+)NOT NULL/drug \1/g' \
        "${POSTGRES_DIR}/create.sql"
}

create_schema() {
    patch_create_sql | duckdb "${DB}"
}

# hosp/admissions.csv.gz -> mimiciv_hosp.admissions
make_table_name() {
    local path=$1 basename dirname
    basename=${path##*/}
    dirname=${path%/*}
    dirname=${dirname##*/}
    printf 'mimiciv_%s.%s' "${dirname}" "${basename%%.*}"
}

# A COPY is a single transaction, so a table is either fully loaded or empty.
# Even a single row indicates completion of the data load.
table_has_rows() {
    [ "$(duckdb_val "SELECT EXISTS (SELECT 1 FROM $1 LIMIT 1)")" = "true" ]
}

load_data() {
    local file table
    while IFS= read -r file; do
        table=$(make_table_name "${file}")

        # A file with no matching table in create.sql is reported and skipped
        # rather than failing the whole build.
        if ! duckdb_val "SELECT 1 FROM ${table} LIMIT 0" >/dev/null 2>&1; then
            echo "   ${table}: not in the schema, skipping ${file##*/}"
            continue
        fi
        if table_has_rows "${table}"; then
            echo "   ${table}: already loaded, skipping"
            continue
        fi
        echo "   ${table}: loading"
        duckdb_cmd "COPY ${table} FROM '${file}' (HEADER, DELIM ',', QUOTE '\"', ESCAPE '\"')" >/dev/null
    done < <(find "${DATA_DIR}"/hosp "${DATA_DIR}"/icu -type f \
                  \( -name '*.csv' -o -name '*.csv.gz' \) | sort)
}

make_concepts() {
    # duckdb.sql pulls in the individual concepts with .read, which resolves
    # relative to the working directory rather than to the script.
    cd "${CONCEPTS_DIR}"
    duckdb "${DB}" -f duckdb.sql
}

validate() {
    # default validate the full DB
    local script=validate.sql

    # The demo is a 100 patient subset of MIMIC-IV, so it has its own set of
    # expected row counts.
    if [ "$(duckdb_val 'SELECT count(*) FROM mimiciv_hosp.patients')" -eq 100 ]; then
        echo "   100 patients found, validating against the MIMIC-IV demo counts"
        script=validate_demo.sql
    fi

    local output
    output=$(duckdb "${DB}" -f "${POSTGRES_DIR}/${script}")
    echo "${output}"

    # Mismatches indicate (1) failure to load (zero rows) or (2) mismatch mimic version
    if echo "${output}" | grep -q FAILED; then
        echo "WARNING: some tables do not have the expected number of rows." >&2
    fi
}

resolve_data_dir() {
    local dir=${1:-${MIMIC_DATA_DIR:-}}

    if [ -z "${dir}" ]; then
        usage
        exit 1
    fi
    if [ ! -d "${dir}/hosp" ] || [ ! -d "${dir}/icu" ]; then
        echo "ERROR: ${dir} must contain the hosp/ and icu/ subfolders of MIMIC-IV." >&2
        exit 1
    fi
    if [ -z "$(find "${dir}/hosp" -maxdepth 1 \( -name '*.csv' -o -name '*.csv.gz' \) -print -quit)" ]; then
        echo "ERROR: no .csv or .csv.gz files found in ${dir}/hosp." >&2
        exit 1
    fi

    DATA_DIR=$(cd -- "${dir}" && pwd)
}

# make_concepts has to cd into the concepts directory, so a relative path here
# would resolve against the wrong directory and silently build a second,
# empty database.
resolve_db() {
    local db=${1:-${MIMIC_DB:-mimic4.db}}
    local dir=${db%/*}

    [ "${dir}" = "${db}" ] && dir=.
    if [ ! -d "${dir}" ]; then
        echo "ERROR: ${dir} does not exist, cannot create ${db} in it." >&2
        exit 1
    fi

    DB="$(cd -- "${dir}" && pwd)/${db##*/}"
}

main() {
    case "${1:-}" in
        -h|--help) usage; exit 0 ;;
    esac

    resolve_data_dir "${1:-}"
    resolve_db "${2:-}"
    echo "Loading from ${DATA_DIR} into ${DB} using DuckDB $(duckdb --version)"

    duckdb_cmd "CREATE TABLE IF NOT EXISTS ${PROGRESS_TABLE} (
        step text PRIMARY KEY,
        completed_at timestamptz NOT NULL DEFAULT now()
    )" >/dev/null

    run_step create create_schema
    run_step load load_data

    if is_true "${MIMIC_MAKE_CONCEPTS:-true}"; then
        run_step concepts make_concepts
    else
        echo "== concepts: MIMIC_MAKE_CONCEPTS is not 'true', skipping"
    fi

    if is_true "${MIMIC_VALIDATE:-true}"; then
        run_step validate validate
    else
        echo "== validate: MIMIC_VALIDATE is not 'true', skipping"
    fi

    echo "MIMIC-IV build complete: ${DB}"
}

main "$@"
