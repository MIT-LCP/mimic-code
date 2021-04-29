# Building the MIMIC database with Docker

A Docker file is provided that can be used to build a
[Docker](https://www.docker.com/) image and subsequently deploy a Docker container (i.e.
a lightweight virtual machine) with PostgreSQL installed and the MIMIC database tables
loaded automatically as described below.

This documentation assumes you have Docker installed on your host machine. Docker
installation instructions can be found [here](https://docs.docker.com/). Note that
the Docker install sometimes requires a reboot (in order for the Daemon to start properly).
You can ensure your docker is working correctly on Linux/OS X using `docker images`.

## Step 0: Clone this repository to your host machine

This document assumes that this .git repo has been cloned to your host in the directory
`/mimic_code`

## Step 1: Obtain the MIMIC csv data files

To obtain access to the MIMIC data files, please follow
[these instructions](http://mimic.physionet.org/gettingstarted/access/).

Once, access has been granted, download all of the .csv files
[from here](https://physionet.org/content/mimiciii/).

Place all of the files in a directory on your host machine. This document will assume
they are in the directory `/HOST/mimic/csv`. The docker build can be done using either
plain-text `.csv` files, or compressed `.csv.gz files`. Specifically, the build will
check for `ADMISSIONS.csv.gz`: if this file exists, it will build using compressed files,
otherwise it will build using plain `csv` files. It's likely easier to keep the files
compressed, and move on to step 2.

If you choose to unzip all the files (or already have), be sure to set permissions to read and write for all groups and users
(this is necessary to allow the container postgres server to read the files for loading into the database).
On Linux and MAC systems, a script to automtically to automatically unzip and set the appropriate permissions
is provided in this directory: `unzip_csv.sh`.
Run this at a terminal command line by entering the following:

    cd /mimic_code/buildmimic/docker
    source unzip_csv.sh /HOST/mimic/csv

... where `/HOST/mimic/csv` is the data folder you would like to work in. Remember this folder name for later.

## Step 2: Build the Docker image

Assuming Docker is installed on your host, you can build the image by entering the
following at a terminal command line (or Docker Quickstart Terminal on Windows):

    cd /mimic_code/buildmimic/docker
    docker build -t postgres/mimic .

Please note the "." at the end is necessary.

To see that the docker image was successfully generated, enter

    docker images

at the command line. The output should include an entry similar to the following:

    REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
    postgres/mimic                  latest              a664dd0d7238        2 minutes ago       349.4 MB

## Step 3: Deploy the container

Once the image has been built, it is necessary to start a Docker container (essentially a
running instance of the image). The following example command can be used to start the
container and build the MIMIC III database from the CSV data files. When the container
starts, a bash script is automatically executed that will run the SQL scripts in the
`mimic_build_files` directory (if BUILD_MIMIC=1, see below). These scripts create
the `mimic` user and create the `mimic` database, with a `mimiciii` schema, create all
of the tables in the `mimiciii` schema and copy the data from the CSV files. The `mimic` user
is the owner of the `mimic` database. Note that these scripts may take several hours to complete.

    docker run \
    --name mimic \
    -p HOST_PORT:5432 \
    -e BUILD_MIMIC=1 \
    -e POSTGRES_PASSWORD=POSTGRES_USER_PASSWORD \
    -e MIMIC_PASSWORD=MIMIC_USER_PASSWORD \
    -v /HOST/mimic_data/csv:/mimic_data \
    -v /HOST/PGDATA_DIR:/var/lib/postgresql/data \
    -d postgres/mimic

In detail, this command:

* names the container `mimic`

* maps the container's port 5432 to the `HOST_PORT` (replace this with appropriate port number)
to enable remote connections to the DB

* sets the container's `BUILD_MIMIC` environment variable to 1 which indicates that the MIMIC database
tables need to be created and that the data from the CSV files should be loaded to the database. If the
CSV data has been previously loaded to the Postgres database and the container just needs to connect
to it, use `BUILD_MIMIC=0` in the above command.

* sets the `postgres` user password to POSTGRES_USER_PASSWORD

* sets the `mimic` user password to MIMIC_USER_PASSWORD

* maps the container's `/mimic_data` directory to the host's `/HOST/mimic_data/csv` directory
so that it can find the MIMIC III CSV data files.

* maps the container's /var/lib/postgresql/data directory to the host's `/HOST/PG_DATA`
directory so that data is persisted on the host (not the container). This is to
prevent data loss if the container is removed and restarted later.

Note that on Windows systems, the host paths will need to be prefixed by an extra forward slash. Here is an example of a working command on Windows 7 running Docker v1.9.1:

    docker run \
    --name mimic \
    -p 5555:5432 \
    -e BUILD_MIMIC=1 \
    -e POSTGRES_PASSWORD=postgres \
    -e MIMIC_PASSWORD=mimic \
    -v //d/mimic/v1.2:/mimic_data \
    -v //d/mimic/pgdata:/var/lib/postgresql/data \
    -d postgres/mimic

... and here is an example of a working command on Ubuntu 16.04 running Docker v1.12.1:

    docker run \
    --name mimic \
    -p 5555:5432 \
    -e BUILD_MIMIC=1 \
    -e POSTGRES_PASSWORD=postgres \
    -e MIMIC_PASSWORD=mimic \
    -v /data/mimic3/version_1_4:/mimic_data \
    -v /data/docker/mimic:/var/lib/postgresql/data \
    -d postgres/mimic

To view the Docker log file for this container (and monitor progress of the SQL scripts that
load the data to the database from the CSV files) enter the following at the command line

    docker ps -a

This will generate output that contains something similar to

    CONTAINER ID        IMAGE             COMMAND                CREATED       STATUS        PORTS                             NAMES
    YOUR_CONTAINER_ID   postgres/mimic    "/docker-entrypoint.   3 days ago    Up 3 days     0.0.0.0:32777->5432/tcp           mimic

You can remove containers by running `docker rm <hash or image name>`, and images using `docker rmi <hash or image name>`.
This is useful if you receive an error stating that the name "mimic" is already in use, or if you are rebuilding the image/containers.

To view the log files, enter the following:

    docker logs -f YOUR_CONTAINER_ID

Finally, it is possible to log on to the container with

    sudo docker exec -it YOUR_CONTAINER_ID /bin/bash
