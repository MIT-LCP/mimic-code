# MIMIC-IV with PostgreSQL and Docker

Build a containerized PostgreSQL database containing MIMIC-IV.
The docker container uses build scripts in the parent folder.
It creates the schema, loads the data, adds the constraints and indexes,
(optionally, default true) derives the concepts from
[concepts_postgres](../../../concepts_postgres), and validates the result.

There are two services. `mimic-db` is a stock postgres image holding the data.
`mimic-build` is a single job that populates it and then exits. They share the
PostgreSQL unix socket, so the bulk `COPY` does not cross the container network.

## Requirements

* Docker, with Compose v2.
* The dataset (`../../download_data.sh` is a convenience for downloading data from PhysioNet)
* Disk space. The compressed download is about 10 GB, but the loaded database is
  considerably larger: roughly 140 GB for `mimiciv_hosp` and `mimiciv_icu` with
  their indexes, plus about 10 GB if you build the concepts. On macOS and
  Windows this space is taken from the Docker Desktop virtual disk, so raise
  that limit in Settings first.

## Quickstart

```bash
# 1. Configure. The defaults should work as-is.
# Make sure MIMIC_DATA_DIR has the hosp/ and icu/ subfolders.
cp .env.example .env

# 2. Download the data, if you do not already have it (about 10 GB).
../../download_data.sh

# 3. Build. Runs in the foreground so you can watch it; add -d to detach.
docker compose up
```

Loading takes several hours for the full dataset, plus about an hour for the
concepts. The database accepts connections throughout, so an empty or partial
result simply means the build is still running. Watch it with:

```bash
docker compose logs -f mimic-build
```

## Notes

### `download_data.sh`

`download_data.sh` is a convenience wrapper around `wget`. If you already have
MIMIC-IV, skip it and point `MIMIC_DATA_DIR` in `.env` at your copy. Any
directory containing the `hosp/` and `icu/` subfolders will work, including the
[demo dataset](https://physionet.org/content/mimic-iv-demo/), which is a useful
way to try this out without downloading the full 10 GB.

### If the build is interrupted

Run `docker compose up` again. The build records each step as it completes and
skips tables that are already populated, so it resumes rather than starting
over. This matters mostly for `chartevents`, the largest table.

Resuming is safe because a `\COPY` is a single statement: a table is either fully loaded or empty. Progress is tracked in the
`mimiciv_build_progress` table, which you can inspect:

```bash
docker compose exec mimic-db psql -U postgres -d mimiciv -c 'TABLE mimiciv_build_progress'
```

To discard everything and start clean:

```bash
docker compose down -v
docker compose up --build
```

Use `--build` whenever you change the SQL or the postgres version, otherwise
Compose reuses the existing image.

### Settings

All are set in `.env`; see `.env.example` for the defaults.

| Variable | Default | Purpose |
| --- | --- | --- |
| `PG_VERSION` | `16` | PostgreSQL major version. 16, 17 and 18 are supported. |
| `POSTGRES_DB` | `mimiciv` | Database name. |
| `POSTGRES_USER` | `postgres` | Database user. |
| `POSTGRES_PASSWORD` | `postgres` | Database password. |
| `POSTGRES_PORT` | `5432` | Host port to publish. |
| `MIMIC_DATA_DIR` | `./mimic-data` | Directory holding `hosp/` and `icu/`. |
| `MIMIC_MAKE_CONCEPTS` | `true` | Derive the concepts into `mimiciv_derived`. |
| `MIMIC_VALIDATE` | `true` | Check the loaded tables against expected row counts. |

## Using the database

```bash
# from the host, if you have psql installed
psql -h localhost -U postgres -d mimiciv

# otherwise, from inside the container
docker compose exec mimic-db psql -U postgres -d mimiciv
```
