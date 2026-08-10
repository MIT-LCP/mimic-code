#!/bin/bash
# Build MIMIC-IV in PostgreSQL: create the schema, load the data, add the
# constraints and indexes, then derive the concepts.
#
# Usage:
#   ./build_mimic.sh <mimic_data_dir>
#
# <mimic_data_dir> is the directory holding the hosp/ and icu/ subfolders.
# Compressed (.csv.gz) and uncompressed (.csv) data are both supported.
#
# Each step is recorded in a progress table once it completes, so an
# interrupted build will resume where it stopped.
#
# Environment:
#   MIMIC_DATA_DIR       used when <mimic_data_dir> is not given
#   MIMIC_MAKE_CONCEPTS  derive the concepts into mimiciv_derived (default true)
#   MIMIC_VALIDATE       check tables against expected row counts (default true)
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_DIR
readonly CONCEPTS_DIR="${SCRIPT_DIR}/../../concepts_postgres"
readonly PROGRESS_TABLE=public.mimiciv_build_progress

# load.sql and load_gz.sql set this for their session; the load is run statement
# by statement here, so set it for every connection instead.
export PGCLIENTENCODING=UTF8

DATA_DIR=""
LOADER=""

psql_run() { psql -v ON_ERROR_STOP=1 --quiet "$@"; }
psql_val() { psql -v ON_ERROR_STOP=1 -Atq -c "$1"; }

# Lowercase string before checking value
is_true() { [ "$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')" = "true" ]; }

usage() {
    echo "Usage: $(basename "$0") <mimic_data_dir>" >&2
    echo "       the directory containing the hosp/ and icu/ subfolders" >&2
}

# Completed steps are recorded in a table located on the public schema.
step_done() {
    [ "$(psql_val "SELECT EXISTS (SELECT 1 FROM ${PROGRESS_TABLE} WHERE step = '$1')")" = "t" ]
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
    psql_run -c "INSERT INTO ${PROGRESS_TABLE} (step) VALUES ('${step}') ON CONFLICT DO NOTHING"
    echo "== ${step}: done"
}

create_schema() {
    psql_run -f "${SCRIPT_DIR}/create.sql"
}

# To reduce redundancy, this script reads the \COPY statements to determine
# the tables to build, and builds them in order.
parse_copy_statements() {
    awk -F' ' '
        /^\\cd / {
            dir = $2
            if (dir ~ /^:/) { cur = "" }                 # \cd :mimic_data_dir
            else { sub(/^\.\.\//, "", dir); cur = dir }  # \cd hosp, \cd ../icu
            next
        }
        /^\\COPY / { print cur "\t" $2 "\t" $0 }
    ' "${SCRIPT_DIR}/${LOADER}"
}

# A \COPY is a single statement, so a table is either fully loaded or empty.
# Even a single row indicates completion of the data load.
table_has_rows() {
    [ "$(psql_val "SELECT EXISTS (SELECT 1 FROM $1 LIMIT 1)")" = "t" ]
}

load_data() {
    local subdir table statement
    while IFS=$'\t' read -r subdir table statement; do
        if table_has_rows "${table}"; then
            echo "   ${table}: already loaded, skipping"
            continue
        fi
        echo "   ${table}: loading"
        (cd "${DATA_DIR}/${subdir}" && printf '%s\n' "${statement}" | psql_run)
    done < <(parse_copy_statements)
}

add_constraints() {
    psql_run -f "${SCRIPT_DIR}/constraint.sql"
}

build_indexes() {
    psql_run -f "${SCRIPT_DIR}/index.sql"
}

make_concepts() {
    # postgres-make-concepts.sql pulls in the individual concepts with \i, which
    # resolves relative to the working directory rather than to the script.
    cd "${CONCEPTS_DIR}"
    psql_run -f postgres-make-concepts.sql
}

validate() {
    # default validate the full DB
    local script=validate.sql

    # The demo is a 100 patient subset of MIMIC-IV, so it has its own set of
    # expected row counts.
    if [ "$(psql_val 'SELECT count(*) FROM mimiciv_hosp.patients')" -eq 100 ]; then
        echo "   100 patients found, validating against the MIMIC-IV demo counts"
        script=validate_demo.sql
    fi

    local output
    output=$(psql -v ON_ERROR_STOP=1 -f "${SCRIPT_DIR}/${script}")
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

    DATA_DIR=$(cd -- "${dir}" && pwd)
}

# Prefer the compressed data (the default distribution format).
select_loader() {
    if [ -n "$(find "${DATA_DIR}/hosp" -maxdepth 1 -name '*.csv.gz' -print -quit)" ]; then
        LOADER=load_gz.sql
    elif [ -n "$(find "${DATA_DIR}/hosp" -maxdepth 1 -name '*.csv' -print -quit)" ]; then
        LOADER=load.sql
    else
        echo "ERROR: no .csv or .csv.gz files found in ${DATA_DIR}/hosp." >&2
        exit 1
    fi
    echo "Loading from ${DATA_DIR} using ${LOADER}"
}

main() {
    case "${1:-}" in
        -h|--help) usage; exit 0 ;;
    esac

    resolve_data_dir "${1:-}"
    select_loader

    psql_run -c "CREATE TABLE IF NOT EXISTS ${PROGRESS_TABLE} (
        step text PRIMARY KEY,
        completed_at timestamptz NOT NULL DEFAULT now()
    )"

    run_step create create_schema
    run_step load load_data
    run_step constraint add_constraints
    run_step index build_indexes

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

    echo "MIMIC-IV build complete."
}

main "$@"
