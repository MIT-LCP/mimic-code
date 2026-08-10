# Image for the job that builds MIMIC-IV into a DuckDB file.
# Writes a .db file into a mounted directory and exits.
#
# The build context is the mimic-iv/ directory, and the repository layout is
# kept intact inside the image so that build_mimic.sh finds the shared postgres
# schema beside it and the concepts two directories up.
#
# There is no official DuckDB image, so the CLI is fetched from the pinned
# GitHub release. DUCKDB_VERSION decides which one; see docker-compose.yml.
ARG DUCKDB_VERSION=1.4.5

FROM debian:stable-slim

# Repeated because the ARG above the first FROM is outside the build stage.
ARG DUCKDB_VERSION
# Set automatically by buildkit: amd64 or arm64. DuckDB publishes both under
# exactly these names.
ARG TARGETARCH

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl unzip \
    && rm -rf /var/lib/apt/lists/* \
    && curl -fsSL -o /tmp/duckdb.zip \
        "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-${TARGETARCH}.zip" \
    && unzip -q /tmp/duckdb.zip -d /usr/local/bin \
    && rm /tmp/duckdb.zip \
    && chmod +x /usr/local/bin/duckdb \
    && duckdb --version

COPY buildmimic/duckdb/build_mimic.sh /mimic/buildmimic/duckdb/
# create.sql, validate.sql and validate_demo.sql are shared with the postgres
# build; build_mimic.sh reads them from ../postgres.
COPY buildmimic/postgres/create.sql buildmimic/postgres/validate*.sql /mimic/buildmimic/postgres/
COPY concepts_duckdb/ /mimic/concepts_duckdb/

# The database is written here.
WORKDIR /out

ENTRYPOINT ["/mimic/buildmimic/duckdb/build_mimic.sh"]
CMD ["/data"]
