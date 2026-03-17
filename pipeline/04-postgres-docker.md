
# Use containerized versin of Postgres that doesn't require any installation steps. You only need to provide a few environment variables to it as well as a volume for storing data.

# Connecting to PostgresSQL running in docker container.

Once the container is running, we can log into our database with pgcli (Postgres Command line Interface)
Install pgcli in our virtual environment .venv within our current project:
> uv add --dev pgcli

The --dev flag marks this as a development dependency (not needed in production). It will be added to the [dependency-groups] section of 
pyproject.toml instead of the main dependencies section.

[dependency-groups]
dev = [
    "pgcli>=4.4.0",
]

above code has been added into pyproject.toml

Now use it to connect Postgres:
> docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                      PORTS                                       NAMES
7c5c631bbe6a   postgres:18   "docker-entrypoint.s…"   2 minutes ago    Up 2 minutes                0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   hungry_gates

Above command shows, postgress:18 is running.
If you cannot find postgress:18 container running, you need to run it first using docker run command shown below.

Let's connect our pgci from our host machine to postgresql database running in postgress:18 docker container:
> uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
Traceback (most recent call last):
  File "/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/.venv/bin/pgcli", line 4, in <module>
    from pgcli.main import cli
  File "/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/.venv/lib/python3.13/site-packages/pgcli/main.py", line 3, in <module>
    from pgspecial.namedqueries import NamedQueries
  File "/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/.venv/lib/python3.13/site-packages/pgspecial/__init__.py", line 14, in <module>
    from . import dbcommands, iocommands  # noqa
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/.venv/lib/python3.13/site-packages/pgspecial/dbcommands.py", line 7, in <module>
    from psycopg.sql import SQL
  File "/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/.venv/lib/python3.13/site-packages/psycopg/__init__.py", line 9, in <module>
    from . import pq  # noqa: F401 import early to stabilize side effects
    ^^^^^^^^^^^^^^^^
  File "/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/.venv/lib/python3.13/site-packages/psycopg/pq/__init__.py", line 114, in <module>
    import_from_libpq()
    ~~~~~~~~~~~~~~~~~^^
  File "/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/.venv/lib/python3.13/site-packages/psycopg/pq/__init__.py", line 108, in import_from_libpq
            raise ImportError(f"""\
    ...<2 lines>...
    {sattempts}""")
ImportError: no pq wrapper available.
Attempts made:
- couldn't import psycopg 'c' implementation: No module named 'psycopg_c'
- couldn't import psycopg 'binary' implementation: No module named 'psycopg_binary'
- couldn't import psycopg 'python' implementation: libpq library not found

We got above error, because pgcli needs dependency psycopg-binary. Add it in uv
> uv add psycopg-binary

Let's connect again:
> uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
Password for root: 
Using local time zone Etc/UTC (server uses Etc/UTC)
Use `set time zone <TZ>` to override, or set `use_local_timezone = False` in the config
Server: PostgreSQL 18.3 (Debian 18.3-1.pgdg13+1)
Version: 4.4.0
Home: http://pgcli.com
root@localhost:ny_taxi>

Successfully connected pgcli. 
# Run Basic SQL Commands
\dt (List tables)

(Create a test table)
CREATE TABLE test (id INTEGER, name VARCHAR(50));

(Insert data)
INSERT INTO test VALUES (1, 'Hello Docker');

(Query data)
SELECT * FROM test;

(Exit)
\q

root@localhost:ny_taxi> \dt
+--------+------+------+-------+
| Schema | Name | Type | Owner |
|--------+------+------+-------|
+--------+------+------+-------+
SELECT 0
Time: 0.006s

root@localhost:ny_taxi> \q
Goodbye!
>

We ran postgres:18 docker container in another bash terminal.
so, Ctl+c will shut down the container and return to command prompt

Example output for Ctl+c
2026-03-17 14:26:43.882 UTC [70] LOG:  checkpoint starting: shutdown immediate
2026-03-17 14:26:43.892 UTC [70] LOG:  checkpoint complete: wrote 0 buffers (0.0%), wrote 0 SLRU buffers; 0 WAL file(s) added, 0 removed, 0 recycled; write=0.001 s, sync=0.001 s, total=0.013 s; sync files=0, longest=0.000 s, average=0.000 s; distance=0 kB, estimate=286 kB; lsn=0/1BEF710, redo lsn=0/1BEF710
2026-03-17 14:26:43.913 UTC [1] LOG:  database system is shut down
> 

# Running PostgresSQL in a Container

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


