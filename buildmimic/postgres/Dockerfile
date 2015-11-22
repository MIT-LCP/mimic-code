FROM postgres:latest

MAINTAINER Aaron J. Masino

ENV BUILD_MIMIC 0

RUN apt-get update

RUN apt-get install -y vim

RUN mkdir /mimic_data

ADD setup.sh /docker-entrypoint-initdb.d/

ADD mimic_build_files /docker-entrypoint-initdb.d/mimic_build_files

