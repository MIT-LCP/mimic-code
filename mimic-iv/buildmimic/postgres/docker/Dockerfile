# Image for the one-shot job that builds MIMIC-IV into the database. The
# database itself runs the stock postgres image; see docker-compose.yml.
#
# The build context is the mimic-iv/ directory, and the repository layout is
# kept intact inside the image so that build_mimic.sh finds the SQL beside it
# and the concepts two directories up. Nothing is duplicated.
#
# PostgreSQL 16, 17 and 18 are all supported.
ARG PG_VERSION=16
FROM postgres:${PG_VERSION}

COPY buildmimic/postgres/*.sql buildmimic/postgres/build_mimic.sh /mimic/buildmimic/postgres/
COPY concepts_postgres/ /mimic/concepts_postgres/

# Replaces the postgres image's own entrypoint: this container is a psql client,
# not a server. The data directory is passed as the command.
ENTRYPOINT ["/mimic/buildmimic/postgres/build_mimic.sh"]
CMD ["/data"]
