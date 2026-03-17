
# Use containerized versin of Postgres that doesn't require any installation steps. You only need to provide a few environment variables to it as well as a volume for storing data.

Running PostgresSQL in a Container

Create a folder anywhere you'd like for Postgres to store data in you Machine. We will use the example folder ny_taxi_postgres_data. Here's how to run the container:

> docker images
Output:
REPOSITORY   TAG       IMAGE ID   CREATED   SIZE

There is no any images. i.e. we don't have any existing postgres:18 image.


> docker run -it --rm \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  postgres:18

Explanation of Parameters
-e sets environment variables (user, password, database name)
-v ny_taxi_postgres_data:/var/lib/postgresql creates a named volume
    Docker manages this volume automatically
    Data persists even after container is removed
    Volume is stored in Docker's internal storage
-p 5432:5432 maps port 5432 from container to host
postgres:18 uses PostgreSQL version 18 (latest as of Dec 2025)


Note:
Docker will create ny_taxi_postgres_data volume, within Docker's internal storage, this volume is mapped to /var/lib/postgresql folder of your postgresql docker container.
Even if you remove your postgresql container, your data stored in /var/lib/postgresql folder by your postgresql docker container will still be available in ny_taxi_postgres_data volume.

> docker volume ls
Output:
DRIVER    VOLUME NAME
local     ny_taxi_postgres_data

# Alternative Apporach - Bind Mount
First create the directory, then map it:

> pwd
/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp

> mkdir ny_taxi_postgres_data

> docker run -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  postgres:18

Named Volume vs Bind Mount
    Named volume (name:/path): Managed by Docker, easier
    Bind mount (/host/path:/container/path): Direct mapping to host filesystem, more control

Even after running postgresql container with Bind Mount, when we list docker volumes with below command, we can't find any internal volumes created. it is because Bind mount ceated direct mapping to your host filesystem and gives more control.

> docker volume ls
DRIVER    VOLUME NAME


# Docker Command related to volumes
> docker volume ls
DRIVER    VOLUME NAME
local     ny_taxi_postgres_data

> docker volume rm ny_taxi_postgres_data

> docker volume ls
DRIVER    VOLUME NAME

# Rmove all unused volumes
> docker volume prune


