# MIMIC-IV with DuckDB and Docker

Build a MIMIC-IV DuckDB database in a container. The build scripts live in the
parent folder. It creates the schema, loads the data, (optionally, default true)
derives the concepts from [concepts_duckdb](../../../concepts_duckdb), and
validates the result. The container is only used to reproducibly build the
database: it is not necessary for analyzing it afterward.

## Requirements

* Docker, with Compose v2.
* The dataset (`../../download_data.sh` is a convenience for downloading data from PhysioNet).
* Disk space. The compressed download is about 10 GB; the resulting `.db` file
  is roughly 25 GB, plus a few GB if you build the concepts. The
  database is written to a bind mount on your host, so this space comes from
  your disk rather than the Docker Desktop virtual disk, but the *load* still
  needs Docker to have room to work.

## Quickstart

```bash
# 1. Configure. Set DUCKDB_VERSION to match your local duckdb.
# Make sure MIMIC_DATA_DIR has the hosp/ and icu/ subfolders.
cp .env.example .env

# 2. Download the data, if you do not already have it (about 10 GB).
../../download_data.sh

# 3. Build. Runs in the foreground so you can watch it; add -d to detach.
docker compose up
```

## Notes

### DuckDB version

The container's DuckDB and the `duckdb` on your machine are two separate installs.
The container has 1.4.5 which is the LTS version. `duckdb` is mostly backward
compatible but be aware of differences.

Check what you have:

```bash
duckdb --version
```

and set `DUCKDB_VERSION` in `.env` to match before building. If you later see an
error about the storage version when opening the file, the fix is to upgrade
your local DuckDB or rebuild with a lower `DUCKDB_VERSION`.

The result is `./mimic-db/mimic4.db`. Change `MIMIC_OUTPUT_DIR` and
`MIMIC_DB_NAME` in `.env` to put it somewhere else.

Loading takes on the order of an hour for the full dataset on a reasonable
machine, plus time for the concepts. Watch it with:

```bash
docker compose logs -f mimic-build
```

### If the build is interrupted

Run `docker compose up` again. The build records each step as it completes and
skips tables that are already populated, so it resumes rather than starting
over. Progress is tracked in the `mimiciv_build_progress` table inside the
database file.

```bash
duckdb ./mimic-db/mimic4.db -c 'TABLE mimiciv_build_progress'
```

To discard everything and start clean, delete the file:

```bash
rm ./mimic-db/mimic4.db
docker compose up --build
```

Use `--build` whenever you change the SQL or `DUCKDB_VERSION`, otherwise
Compose reuses the existing image.

### Settings

All are set in `.env`; see `.env.example` for the defaults.

| Variable | Default | Purpose |
| --- | --- | --- |
| `DUCKDB_VERSION` | `1.4.5` | DuckDB version to build with. Match your local `duckdb`. |
| `MIMIC_DATA_DIR` | `./mimic-data` | Directory holding `hosp/` and `icu/`. |
| `MIMIC_OUTPUT_DIR` | `./mimic-db` | Host directory the database is written to. |
| `MIMIC_DB_NAME` | `mimic4.db` | Filename of the database. |
| `MIMIC_MAKE_CONCEPTS` | `true` | Derive the concepts into `mimiciv_derived`. |
| `MIMIC_VALIDATE` | `true` | Check the loaded tables against expected row counts. |

## Using the database

```bash
# from the host, with your own duckdb
duckdb ./mimic-db/mimic4.db

# otherwise, from inside a throwaway container using the pinned version (not recommended)
docker compose run --rm --entrypoint duckdb mimic-build /out/mimic4.db
```
