# Getting MIMIC-IV up and running with Postgres and Docker
Use these scripts to quickly get setup with a containerized version of MIMIC-IV

## Steps
1. Install Docker
2. Download mimic data from PhysioNet by running the `download_data.sh` script. this will store the files in ./mimic-data/
3. Edit `POSTGRES_USER` and `POSTGRES_PASSWORD` as needed. Optionally, you can
   change the host paths for the volume mounts if you would like to change where
   the data are stored on the host machine.
4. Build and run the container by running `docker compose up`. This may take awhile. 

Once complete you should have a containerized postgres instance containing MIMIC-IV data in the `mimiciv` database.

## Using the database

```bash
# spin up a container and detach
docker compose up -d

# you should now see a running container...e.g docker-mimic-db-1
docker ps

# if you have psql installed on the host machine you can do...password required
psql -U <username> -d mimiciv -h localhost

# if you do not have psql installed on host machine you can do...password not
# required
docker exec -it docker-mimic-db-1 psql -U <username> -d mimiciv

# psql on host machine...run profile script
psql -U <username> -d mimiciv -h localhost -f ../validate.sql

# psql not on host machine...need to mv validate into mount director so it can
# be accessed from container
cp ../validate.sql ./mimic-data/
docker exec -it docker-mimic-db-1 psql -U <username> -d mimiciv -f /data/validate.sql
```
