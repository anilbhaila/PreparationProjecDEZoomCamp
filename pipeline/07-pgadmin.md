pgAdmin - Database Management Tool Web UI

pgcli is a handy tool to quickly check data from command line interface. But it's not useful for complex queries and database management task.
pgAdmin is a web-based tool that makes it more convenient to access and manage our databases.

It's possible to run pgAdmin as a container along with the Postgres container, but both containers will have to be in the same virtual network so that they can find each other.

Run pgAdmin Container
> docker run --rm -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  dpage/pgadmin4

  Output:
  postfix/postfix-script: starting the Postfix mail system
[2026-03-17 16:39:52 +0000] [1] [INFO] Starting gunicorn 23.0.0
[2026-03-17 16:39:52 +0000] [1] [INFO] Listening at: http://[::]:80 (1)
[2026-03-17 16:39:52 +0000] [1] [INFO] Using worker: gthread
[2026-03-17 16:39:52 +0000] [124] [INFO] Booting worker with pid: 124
/venv/lib/python3.14/site-packages/sshtunnel.py:1040: SyntaxWarning: 'return' in a 'finally' block
  return (ssh_host,

[2026-03-17 16:41:26 +0000] [1] [INFO] Handling signal: winch
[2026-03-17 16:41:26 +0000] [1] [INFO] Handling signal: winch



The -v pgadmin_data:/var/lib/pgadmin volume mapping saves pgAdmin settings (server connections, preferences) so you don't have to reconfigure it every time you restart the container.

Parameters Explained
The container needs 2 environment variables: a login email and a password. We use admin@admin.com and root in this example.
    pgAdmin is a web app and its default port is 80; we map it to 8085 in our localhost to avoid any possible conflicts.
    The actual image name is dpage/pgadmin4.
Note: This won't work yet because pgAdmin can't see the PostgreSQL container. They need to be on the same Docker network!

Docker Networks
Let's create a virtual Docker network called pg-network:

> docker network create pg-network
6ce72fb92da67abe9553eaec54338552299c2a2a9d30c24b994d6516d2953ec4

You can look at the existing networks with
> docker network ls
NETWORK ID     NAME         DRIVER    SCOPE
7768ac497768   bridge       bridge    local
79c5a238eb76   host         host      local
449d2c4dded4   none         null      local
6ce72fb92da6   pg-network   bridge    local

You can remove the network later with the command 
> docker network rm pg-network

Now let's run Containers on the Same Network
Stop both containers and re-run them with the network configuration:

# Run PostgreSQL on the network
> docker run --rm -it \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  --network=pg-network \
  --name pgdatabase \
  postgres:18

Output:
docker: Error response from daemon: driver failed programming external connectivity on endpoint pgdatabase (3cf0677616ec43e7ec63e362c9bf47c1c69d9b110983dcd18d0d8ceec5fbe52b): Bind for 0.0.0.0:5432 failed: port is already allocated.
ERRO[0000] error waiting for container: context canceled 

You need to remove previously created containers
> docker container prune
> docker kill <container_id>
> docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

Let's run the pgdatabase container again
Output:
2026-03-17 16:51:20.197 UTC [31] LOG:  checkpoint complete: wrote 16206 buffers (98.9%), wrote 3 SLRU buffers; 0 WAL file(s) added, 18 removed, 3 recycled; write=0.626 s, sync=0.238 s, total=0.984 s; sync files=12, longest=0.100 s, average=0.020 s; distance=343410 kB, estimate=343410 kB; lsn=0/6B1FDFF8, redo lsn=0/6B1FDFF8
2026-03-17 16:51:20.209 UTC [1] LOG:  database system is ready to accept connections


# In another terminal, run pgAdmin on the same network
> docker run --rm -it \
  -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" \
  -e PGADMIN_DEFAULT_PASSWORD="root" \
  -v pgadmin_data:/var/lib/pgadmin \
  -p 8085:80 \
  --network=pg-network \
  --name pgadmin \
  dpage/pgadmin4

  Let's run the container pgadmin in another terminal
  Output:
  postfix/postfix-script: starting the Postfix mail system
[2026-03-17 16:39:52 +0000] [1] [INFO] Starting gunicorn 23.0.0
[2026-03-17 16:39:52 +0000] [1] [INFO] Listening at: http://[::]:80 (1)
[2026-03-17 16:39:52 +0000] [1] [INFO] Using worker: gthread
[2026-03-17 16:39:52 +0000] [124] [INFO] Booting worker with pid: 124
/venv/lib/python3.14/site-packages/sshtunnel.py:1040: SyntaxWarning: 'return' in a 'finally' block
  return (ssh_host,

[2026-03-17 16:41:26 +0000] [1] [INFO] Handling signal: winch
[2026-03-17 16:41:26 +0000] [1] [INFO] Handling signal: winch

# Now these containers will find each other
Just like with the Postgres container, we specify a network and a name for pgAdmin.
The container names (pgdatabase and pgadmin) allow the containers to find each other within the network.

# Connect pgAdmin to PostgreSQL

You should now be able to load pgAdmin on a web browser by browsing to http://localhost:8085
Use the same email and password you used for running the container to log in.

    Open browser and go to http://localhost:8085
    Login with email: admin@admin.com, password: root
    Right-click "Servers" → Register → Server
    Configure:
        General tab: Name: Local Docker
        Connection tab:
            Host: pgdatabase (the container name)
            Port: 5432
            Username: root
            Password: root
    Save
Now you can explore the database using the pgAdmin interface!

If you cannot reach localhost:8085, then you need to Forward Port 8085 in VS Code.
What this means is, data packets designated to port 8085 from you host machine is forwarded to port 80, so that container can access the datapacket.

Now you will be able to access pgAdmin Web UI at
http://localhost:8085

Now, you can add "Servers" with above instruction.
Then you will see, pgdatabase=>Databases=>ny_taxi=>Schemas=>public=>Tables=>yellow_taxi_data, yellow_taxi_trips

