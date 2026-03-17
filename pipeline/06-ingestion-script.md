Creating the Data Ingestion Script
# This ingest_data.py is static script just useful to ingest single file yellow_tripdata_2021-01.csv.gz
Let's make it more useful by paramitarizing the script using click for command-line argument parsing:

import click

@click.command()
@click.option('--pg-user', default='root', help='PostgreSQL user')
@click.option('--pg-pass', default='root', help='PostgreSQL password')
@click.option('--pg-host', default='localhost', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--target-table', default='yellow_taxi_data', help='Target table name')
@click.option('--year', default=2021, type=int, help='Year of the data')
@click.option('--month', default=1, type=int, help='Month of the data')
@click.option('--chunksize', default=100000, type=int, help='Chunk size for reading CSV')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table):
    # Ingestion logic here
    pass

# Running the Paramitarized Script
The script reads data in chunks (100,000 rows at a time) to handle large files efficiently without running out of memory.

Let's run below command:
> uv run python ingest_data.py \
  --pg-user=root \
  --pg-pass=root \
  --pg-host=localhost \
  --pg-port=5432 \
  --pg-db=ny_taxi \
  --target-table=yellow_taxi_trips
Output:
0it [00:00, ?it/s]Table created
Inserted: 100000
1it [00:08,  8.63s/it]Inserted: 100000
2it [00:16,  8.08s/it]Inserted: 100000
3it [00:23,  7.85s/it]Inserted: 100000
4it [00:31,  7.82s/it]Inserted: 100000
5it [00:39,  7.66s/it]Inserted: 100000
6it [00:46,  7.64s/it]Inserted: 100000
7it [00:54,  7.61s/it]Inserted: 100000
8it [01:02,  7.75s/it]Inserted: 100000
9it [01:10,  7.97s/it]Inserted: 100000
10it [01:18,  8.03s/it]Inserted: 100000
11it [01:26,  7.84s/it]Inserted: 100000
12it [01:33,  7.67s/it]Inserted: 100000
13it [01:41,  7.61s/it]Inserted: 69765
14it [01:45,  7.55s/it]

Now let's check in database:
root@localhost:ny_taxi> \dt
+--------+-------------------+-------+-------+
| Schema | Name              | Type  | Owner |
|--------+-------------------+-------+-------|
| public | yellow_taxi_data  | table | root  |
| public | yellow_taxi_trips | table | root  |
+--------+-------------------+-------+-------+
SELECT 2
Time: 0.004s

Here you can see, our parametrized ingest_data.py created new table 'yellow_taxi_trips' and inserted all data.
root@localhost:ny_taxi> SELECT count(1) from yellow_taxi_trips;
+---------+
| count   |
|---------|
| 1369765 |
+---------+
SELECT 1
Time: 0.183s



Now let's convert the DataExploration.ipynb notebook to a Python script.

# Convert Notebook to Script
> pwd
/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp
> ls
Dockerfile  README.md  main.py  pipeline  pipeline.py  pyproject.toml  uv.lock

Our DataExploration.ipynb is inside pipeline folder. 
> cd pipeline
> ls
04-postgres-docker.md  05-data-ingestion.md  06-ingestion-script.md  DataExploration.ipynb

Now we see our file, let's run below command:
> uv run jupyter nbconvert --to=script DataExploration.ipynb
[NbConvertApp] Converting notebook DataExploration.ipynb to script
[NbConvertApp] Writing 1534 bytes to DataExploration.py

> mv DataExploration.py ingest_data.py
(Renaming to ingest_data.py)

# Now let's reorganize code with in ingest_data.py
Remove all # In[1]: comments

put all imports in top of the file:

import pandas as pd
from sqlalchemy import create_engine

Now let's run this ingest_data.py from terminal

> uv run ingest_data.py
0it [00:00, ?it/s]Table created
Inserted: 100000
1it [00:07,  7.55s/it]Inserted: 100000
2it [00:14,  7.47s/it]Inserted: 100000
3it [00:22,  7.66s/it]Inserted: 100000
4it [00:30,  7.65s/it]Inserted: 100000
5it [00:38,  7.69s/it]Inserted: 100000
6it [00:45,  7.48s/it]Inserted: 100000
7it [00:52,  7.37s/it]Inserted: 100000
8it [00:59,  7.40s/it]Inserted: 100000
9it [01:07,  7.39s/it]Inserted: 100000
10it [01:16,  8.08s/it]Inserted: 100000
11it [01:25,  8.13s/it]Inserted: 100000
12it [01:31,  7.74s/it]Inserted: 100000
13it [01:39,  7.59s/it]Inserted: 69765
14it [01:43,  7.42s/it]

Let's check in database:
> uv run pgcli -h localhost -u root -p 5432 -d ny_taxi
Password for root: 
Using local time zone Etc/UTC (server uses Etc/UTC)
Use `set time zone <TZ>` to override, or set `use_local_timezone = False` in the config
Server: PostgreSQL 18.3 (Debian 18.3-1.pgdg13+1)
Version: 4.4.0
Home: http://pgcli.com
root@localhost:ny_taxi> \dt
+--------+------------------+-------+-------+
| Schema | Name             | Type  | Owner |
|--------+------------------+-------+-------|
| public | yellow_taxi_data | table | root  |
+--------+------------------+-------+-------+
SELECT 1
Time: 0.010s
root@localhost:ny_taxi> SELECT count(1) from yellow_taxi_data;
+---------+
| count   |
|---------|
| 1369765 |
+---------+
SELECT 1
Time: 0.345s
root@localhost:ny_taxi>
