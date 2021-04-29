FROM postgres:latest

# in the docker initialization, we do not build the data
ENV BUILD_MIMIC 0

RUN apt-get update \
 && apt-get install -y git \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /mimic-code /mimic_data \
 && cd /mimic-code \
 # clone the postgres build scripts into a local folder
 && git init \
 && git remote add -f origin https://github.com/MIT-lcp/mimic-code \
 && git config core.sparseCheckout true \
 && echo "buildmimic/postgres/" >> .git/info/sparse-checkout \
 && echo "buildmimic/docker/"   >> .git/info/sparse-checkout \
 && git pull origin master \
 # copy the build scripts into a different folder and remove the temp folder
 && cp -r buildmimic /docker-entrypoint-initdb.d/ \
 && cp buildmimic/docker/setup.sh /docker-entrypoint-initdb.d/ \
 && rm -rf /mimic-code
