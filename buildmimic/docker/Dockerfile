FROM postgres:latest

# in the docker initialization, we do not build the data
ENV BUILD_MIMIC 0

RUN apt-get update
RUN apt-get install -y vim git

# clone the postgres build scripts into a local folder
RUN mkdir mimic-code
RUN cd mimic-code
RUN git init
RUN git remote add -f origin https://github.com/MIT-lcp/mimic-code
RUN git config core.sparseCheckout true
RUN echo "buildmimic/postgres/" >> .git/info/sparse-checkout
RUN git pull origin master

# copy the build scripts into a different folder
RUN cp -r buildmimic /docker-entrypoint-initdb.d/

# make a directory for the data
RUN mkdir /mimic_data

ADD setup.sh /docker-entrypoint-initdb.d/
