Till now we build our own two docker image 
> docker build -t test:pandas
> docker build -t yellow_taxi_ingest:v001

And we used pgAdmin and postgres:18 docker images.
Everytime, we need to run docker run seperately for all images.

Imagin if we have 100 docker images needed for our project. It will be a nightmare to run them mannually. 

SO, we have solution for this: Docker Compose

> docker-compose allows us to lunch multiple containers using a single configuration file, so that we don't have to run multiple complex docker run commands separately.

Docker compose makes use of YAML files. 

services:
  pgdatabase:
    image: postgres:18
    environment:
      POSTGRES_USER: "root"
      POSTGRES_PASSWORD: "root"
      POSTGRES_DB: "ny_taxi"
    volumes:
      - "ny_taxi_postgres_data:/var/lib/postgresql"
    ports:
      - "5432:5432"

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: "admin@admin.com"
      PGADMIN_DEFAULT_PASSWORD: "root"
    volumes:
      - "pgadmin_data:/var/lib/pgadmin"
    ports:
      - "8085:80"


volumes:
  ny_taxi_postgres_data:
  pgadmin_data:

Explanation
We don't have to specify a network because docker compose takes care of it: every single container (or "service", as the file states) will run within the same network and will be able to find each other according to their names (pgdatabase and pgadmin in this example).
All other details from the docker run commands (environment variables, volumes and ports) are mentioned accordingly in the file following YAML syntax.

Let's run the commands:

> docker ps -a
CONTAINER ID   IMAGE            COMMAND                  CREATED       STATUS       PORTS                                            NAMES
38578cd7fae5   dpage/pgadmin4   "/entrypoint.sh"         2 hours ago   Up 2 hours   443/tcp, 0.0.0.0:8085->80/tcp, :::8085->80/tcp   pgadmin
d355e77a1a63   postgres:18      "docker-entrypoint.s…"   2 hours ago   Up 2 hours   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp        pgdatabase

> docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
7768ac497768   bridge       bridge    local
79c5a238eb76   host         host      local
449d2c4dded4   none         null      local
6ce72fb92da6   pg-network   bridge    local

Let's remove all containers and networks
> docker network rm pg-network
Error response from daemon: error while removing network: network pg-network id 6ce72fb92da67abe9553eaec54338552299c2a2a9d30c24b994d6516d2953ec4 has active endpoints

You cannot remove network first while pgAdmin and postgres database is running in two different containers.
you need to stop them first.

> docker stop d355e77a1a63
d355e77a1a63
> docker stop 38578cd7fae5
38578cd7fae5
> docker network rm pg-network
pg-network

No error. So successfully removed.

Now let's run all containers by docker-compose
Start Services with Docker Compose
> docker-compose up
bash: docker-compose: command not found

We got this error, because we have not installed docker-compose before

We used below command to install docker
> sudo apt update && sudo apt install docker.io
> docker --version
Docker version 20.10.24_dfsgl, build 297e128

The issue is that the docker.io package on Ubuntu/Debian installs the core Docker engine but does not include Docker Compose by default. 
You have two ways to fix this, depending on which version of Compose you want to use:
Option 1: Use the Modern Command (Recommended)
Modern Docker uses docker compose (with a space) instead of the old docker-compose (with a hyphen). To get this working, install the Compose plugin:
> sudo apt update
> sudo apt install docker-compose-v2

After this, run your command as:
> docker compose up

Option 2: Install the Legacy "Hyphenated" Version
> sudo apt update
> sudo apt install docker-compose
docker-compose version 1.29.2, build unknown

Let's run docker-compose up
> docker-compose up
ERROR: 
        Can't find a suitable configuration file in this directory or any
        parent. Are you in the right directory?

        Supported filenames: docker-compose.yml, docker-compose.yaml, compose.yml, compose.yaml

This error occured because ther is no docker-compose.yaml file defined in pwd.
> ls
Dockerfile  README.md  main.py  pipeline  pipeline.py  pyproject.toml  uv.lock

Let's create one and add below code to it:
services:
  pgdatabase:
    image: postgres:18
    environment:
      POSTGRES_USER: "root"
      POSTGRES_PASSWORD: "root"
      POSTGRES_DB: "ny_taxi"
    volumes:
      - "ny_taxi_postgres_data:/var/lib/postgresql"
    ports:
      - "5432:5432"

  pgadmin:
    image: dpage/pgadmin4
    environment:
      PGADMIN_DEFAULT_EMAIL: "admin@admin.com"
      PGADMIN_DEFAULT_PASSWORD: "root"
    volumes:
      - "pgadmin_data:/var/lib/pgadmin"
    ports:
      - "8085:80"


volumes:
  ny_taxi_postgres_data:
  pgadmin_data:


We can now run Docker compose by running the following command from the same directory where docker-compose.yaml is found. Make sure that all previous containers aren't running anymore:

> docker-compose up

Detached Mode
If you want to run the containers again in the background rather than in the foreground (thus freeing up your terminal), you can run them in detached mode:

> docker-compose up -d
Creating network "preparationprojecdezoomcamp_default" with the default driver
Creating volume "preparationprojecdezoomcamp_ny_taxi_postgres_data" with default driver
Creating volume "preparationprojecdezoomcamp_pgadmin_data" with default driver
Creating preparationprojecdezoomcamp_pgdatabase_1 ... done
Creating preparationprojecdezoomcamp_pgadmin_1    ... done

Our project folder name is "Preparationprojectdezoomcamp"
So, this folder name is preppended on all the services created.
Try to access: http://localhost:8085
if not opened pgAdmin Web UI, you might need to forward the port in VS code PORTS tab.

Now if you are able to access pgAdmin WebUI,
Add New Server:
pgdatabase => Databases(2) => ny_taxi => Schemas(1) => public => Tables => 0
We do not see any tables why?

We are supposed to see three tables:
+--------+------------------------------+-------+-------+
| Schema | Name                         | Type  | Owner |
|--------+------------------------------+-------+-------|
| public | yellow_taxi_data             | table | root  |
| public | yellow_taxi_data_from_docker | table | root  |
| public | yellow_taxi_trips            | table | root  |
+--------+------------------------------+-------+-------+

Let's check from pgcli as well:
> uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
Password for root: 
Using local time zone Etc/UTC (server uses Etc/UTC)
Use `set time zone <TZ>` to override, or set `use_local_timezone = False` in the config
Server: PostgreSQL 18.3 (Debian 18.3-1.pgdg13+1)
Version: 4.4.0
Home: http://pgcli.com
root@localhost:ny_taxi> \dt
+--------+------+------+-------+
| Schema | Name | Type | Owner |
|--------+------+------+-------|
+--------+------+------+-------+
SELECT 0
Time: 0.010s


We are not able to see our tables. WHY?
Look at the docker-compose.yaml below code are found at bottom:

volumes:
  ny_taxi_postgres_data:
  pgadmin_data:

If we do not mention, driver and name for volumes, docker-compose will create is internal volumes and perform mappings.
> docker volumes ls
DRIVER    VOLUME NAME
local     ny_taxi_postgres_data
local     pgadmin_data
local     preparationprojecdezoomcamp_ny_taxi_postgres_data
local     preparationprojecdezoomcamp_pgadmin_data

Here we see two volumes has been created by docker-compose up
Thus, our previous tables were not found.

Now let's add below code in docker-compose.yaml file:
volumes:
  ny_taxi_postgres_data:
    driver: local
    name: ny_taxi_postgres_data
  pgadmin_data:
    driver: local
    name: pgadmin_data

Let's re-run below command:
> docker-compose down
> docker-compose up -d

> uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
Password for root: 
Using local time zone Etc/UTC (server uses Etc/UTC)
Use `set time zone <TZ>` to override, or set `use_local_timezone = False` in the config
Server: PostgreSQL 18.3 (Debian 18.3-1.pgdg13+1)
Version: 4.4.0
Home: http://pgcli.com
root@localhost:ny_taxi> \dt
+--------+------------------------------+-------+-------+
| Schema | Name                         | Type  | Owner |
|--------+------------------------------+-------+-------|
| public | yellow_taxi_data             | table | root  |
| public | yellow_taxi_data_from_docker | table | root  |
| public | yellow_taxi_trips            | table | root  |
+--------+------------------------------+-------+-------+
SELECT 3
Time: 0.010s

Look now we see our old tables back.

Stop Services
You will have to press Ctrl+C in order to shut down the containers when running in foreground mode. The proper way of shutting them down is with this command:

> docker-compose down

Other Useful Commands

# View logs
> docker-compose logs

# Stop and remove volumes
> docker-compose down -v

Benefits of Docker Compose
Single command to start all services
Automatic network creation
Easy configuration management
Declarative infrastructure

Running the Ingestion Script with Docker Compose
If you want to re-run the dockerized ingest script when you run Postgres and pgAdmin with docker compose, you will have to find the name of the virtual network that Docker compose created for the containers.

# check the network link:
> docker network ls
NETWORK ID     NAME                                  DRIVER    SCOPE
7768ac497768   bridge                                bridge    local
79c5a238eb76   host                                  host      local
449d2c4dded4   none                                  null      local
2e47a59e0112   preparationprojecdezoomcamp_default   bridge    local

# it's preparationprojecdezoomcamp_default (or similar based on directory name)
# now run the script:
> docker run -it --rm\
  --network=preparationprojecdezoomcamp_default \
  yellow_taxi_ingest:v001 \
    --pg-user=root \
    --pg-pass=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data_with_docker-compose

    Output:
    0it [00:00, ?it/s]Table created
Inserted: 100000
1it [00:09,  9.49s/it]Inserted: 100000
2it [00:18,  8.93s/it]Inserted: 100000
3it [00:26,  8.71s/it]Inserted: 100000
4it [00:34,  8.48s/it]Inserted: 100000
5it [00:43,  8.48s/it]Inserted: 100000
6it [00:51,  8.54s/it]Inserted: 100000
7it [01:00,  8.64s/it]Inserted: 100000
8it [01:09,  8.66s/it]Inserted: 100000
9it [01:17,  8.55s/it]Inserted: 100000
10it [01:28,  9.28s/it]Inserted: 100000
11it [01:37,  9.24s/it]Inserted: 100000
12it [01:46,  9.00s/it]Inserted: 100000
13it [01:54,  8.79s/it]Inserted: 69765
14it [02:04,  8.92s/it]

Let's check in database
> uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
Password for root: 
Using local time zone Etc/UTC (server uses Etc/UTC)
Use `set time zone <TZ>` to override, or set `use_local_timezone = False` in the config
Server: PostgreSQL 18.3 (Debian 18.3-1.pgdg13+1)
Version: 4.4.0
Home: http://pgcli.com
root@localhost:ny_taxi> \dt
+--------+--------------------------------------+-------+-------+
| Schema | Name                                 | Type  | Owner |
|--------+--------------------------------------+-------+-------|
| public | yellow_taxi_data                     | table | root  |
| public | yellow_taxi_data_from_docker         | table | root  |
| public | yellow_taxi_data_with_docker-compose | table | root  |
| public | yellow_taxi_trips                    | table | root  |
+--------+--------------------------------------+-------+-------+
SELECT 4
Time: 0.009s
root@localhost:ny_taxi> select count(1) from "yellow_taxi_data_with_docker-compose";
+---------+
| count   |
|---------|
| 1369765 |
+---------+
SELECT 1
Time: 0.217s
root@localhost:ny_taxi> \q
Goodbye!

Here you can see yellow_taxi_data_with_docker-compse table created.
