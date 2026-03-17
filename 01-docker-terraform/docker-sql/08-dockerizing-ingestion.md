# Dockerizing the Ingestion Script

Now let's containerize the ingestion script so we can run it in Docker.

We have below ENTRYPOINT code in Dockerfile, which we created while learning about dockerizing pipeline.py
COPY pipeline.py pipeline.py

ENTRYPOINT ["python", "pipeline.py"]

Now we can use same Dockerfile, to dockerize our ingest_data.py by changing the ENTRYPOINT and copying ingest_data.py to the docker container working directory i.e. /app

COPY pipeline/ingest_data.py ./

ENTRYPOINT ["python", "ingest_data.py"]


# build the docker image
> ls
> DataExploration.ipynb  Dockerfile  README.md  ingest_data.py  main.py  output_day_36.parquet  pipeline.py  pyproject.toml  uv.lock

> docker build -t yellow_taxi_ingest:v001 .
This command will build a docker image 
Output:
Step 8/8 : ENTRYPOINT ["python", "ingest_data.py"]
 ---> Running in 6b272a7e64b9
Removing intermediate container 6b272a7e64b9
 ---> 085f202c251c
Successfully built 085f202c251c
Successfully tagged yellow_taxi_ingest:v001

> docker image ls
REPOSITORY             TAG            IMAGE ID       CREATED             SIZE
yellow_taxi_ingest     v001           085f202c251c   About an hour ago   665MB
ghcr.io/astral-sh/uv   latest         b8434f22d8cf   19 hours ago        54.8MB
postgres               18             9865660c92d4   20 hours ago        456MB
dpage/pgadmin4         latest         7bb0af60a271   2 weeks ago         501MB
python                 3.13.11-slim   464f788e6eab   6 weeks ago         118MB

Now let's run the container and pass our arguments.
> docker run --rm -it \
  --network=pg-network \
  yellow_taxi_ingest:v001 \
    --pg-user=root \
    --pg-pass=root \
    --pg-host=pgdatabase \
    --pg-port=5432 \
    --pg-db=ny_taxi \
    --target-table=yellow_taxi_data_from_docker

Output:
0it [00:00, ?it/s]Table created
Inserted: 100000
1it [00:10, 10.04s/it]Inserted: 100000
2it [00:23, 11.91s/it]Inserted: 100000
3it [00:38, 13.21s/it]Inserted: 100000
4it [00:48, 12.15s/it]Inserted: 100000
5it [00:58, 11.23s/it]Inserted: 100000
6it [01:07, 10.54s/it]Inserted: 100000
7it [01:16, 10.15s/it]Inserted: 100000
8it [01:26,  9.92s/it]Inserted: 100000
9it [01:35,  9.63s/it]Inserted: 100000
10it [01:44,  9.54s/it]Inserted: 100000
11it [01:53,  9.40s/it]Inserted: 100000
12it [02:03,  9.53s/it]Inserted: 100000
13it [02:21, 12.09s/it]Inserted: 69765
14it [02:33, 10.97s/it]

Let's check in database
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
Time: 0.013s
root@localhost:ny_taxi> SELECT count(1) from yellow_taxi_data_from_docker;
+---------+
| count   |
|---------|
| 1369765 |
+---------+
SELECT 1
Time: 0.232s
root@localhost:ny_taxi> \q
Goodbye!

Important Notes
    We need to provide the network for Docker to find the Postgres container. It goes before the name of the image.
    Since Postgres is running on a separate container, the host argument will have to point to the container name of Postgres (pgdatabase).
    You can drop the table in pgAdmin beforehand if you want, but the script will automatically replace the pre-existing table.