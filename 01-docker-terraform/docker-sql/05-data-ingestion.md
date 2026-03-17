# NY Taxi Dataset and Data Ingestion

Ingesting Data into Postgres
# In the Jupyter notebook, we create code to:

Download the CSV file
Read it in chunks with pandas
Convert datetime columns
Insert data into PostgreSQL using SQLAlchemy

Install SQLAlchemy
> uv add sqlalchemy "psycopg[binary,pool]"

Create Database Connection. Run below code in notebook.
from sqlalchemy import create_engine
engine = create_engine('postgresql+psycopg://root:root@localhost:5432/ny_taxi')

Get DDL Schema
print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))

if you get OperationalError, check if postgres:18 container is running or not
> docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

It did't list any postgres:18 container running. Thus giving error.
Let's run it:
> docker run -d --rm \
  -e POSTGRES_USER="root" \
  -e POSTGRES_PASSWORD="root" \
  -e POSTGRES_DB="ny_taxi" \
  -v ny_taxi_postgres_data:/var/lib/postgresql \
  -p 5432:5432 \
  postgres:18
  
Here:
  -d means detached mode, so that we get out bash prompt back to us, while running container in background.

Output:
006d6b487b416a5f96d6e59bcc064072cfecb648155adea2051310baedf4d8f2

Now let's check if postgres:18 container is running.
> docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                                       NAMES
006d6b487b41   postgres:18   "docker-entrypoint.s…"   40 seconds ago   Up 39 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   elastic_antonelli

Let's run above notebook code again:
# Create Database Connection. Run below code in notebook.
from sqlalchemy import create_engine
engine = create_engine('postgresql+psycopg://root:root@localhost:5432/ny_taxi')

# Get DDL Schema
print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))

Output:
CREATE TABLE yellow_taxi_data (
	"VendorID" BIGINT, 
	tpep_pickup_datetime TEXT, 
	tpep_dropoff_datetime TEXT, 
	passenger_count BIGINT, 
	trip_distance FLOAT(53), 
	"RatecodeID" BIGINT, 
	store_and_fwd_flag TEXT, 
	"PULocationID" BIGINT, 
	"DOLocationID" BIGINT, 
	payment_type BIGINT, 
	fare_amount FLOAT(53), 
	extra FLOAT(53), 
	mta_tax FLOAT(53), 
	tip_amount FLOAT(53), 
	tolls_amount FLOAT(53), 
	improvement_surcharge FLOAT(53), 
	total_amount FLOAT(53), 
	congestion_surcharge FLOAT(53)
)

No error at all.
But we found one issue, datetime datatype is shown as TEXT. we need to fix it.
    tpep_pickup_datetime TEXT, 
	tpep_dropoff_datetime TEXT, 

We need to specify dtype in pandas dataframe:
prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/'

dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]

df = pd.read_csv(
    prefix + 'yellow_tripdata_2021-01.csv.gz',
    nrows=100,
    dtype=dtype,
    parse_dates=parse_dates
)
# Create Database Connection. Run below code in notebook.
from sqlalchemy import create_engine
engine = create_engine('postgresql+psycopg://root:root@localhost:5432/ny_taxi')

# Get DDL Schema
print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))

Output:
CREATE TABLE yellow_taxi_data (
	"VendorID" BIGINT, 
	tpep_pickup_datetime TIMESTAMP WITHOUT TIME ZONE, 
	tpep_dropoff_datetime TIMESTAMP WITHOUT TIME ZONE, 
	passenger_count BIGINT, 
	trip_distance FLOAT(53), 
	"RatecodeID" BIGINT, 
	store_and_fwd_flag TEXT, 
	"PULocationID" BIGINT, 
	"DOLocationID" BIGINT, 
	payment_type BIGINT, 
	fare_amount FLOAT(53), 
	extra FLOAT(53), 
	mta_tax FLOAT(53), 
	tip_amount FLOAT(53), 
	tolls_amount FLOAT(53), 
	improvement_surcharge FLOAT(53), 
	total_amount FLOAT(53), 
	congestion_surcharge FLOAT(53)
)

Not it got fixed:

Connect postgres database via pgcli:
> uv run pgcli -h localhost -p 5432 -u root -d ny_taxi
Password for root: 
Using local time zone Etc/UTC (server uses Etc/UTC)
Use `set time zone <TZ>` to override, or set `use_local_timezone = False` in the config
Server: PostgreSQL 18.3 (Debian 18.3-1.pgdg13+1)
Version: 4.4.0
Home: http://pgcli.com
root@localhost:ny_taxi>

Check in database:
root@localhost:ny_taxi> \dt
+--------+------+------+-------+
| Schema | Name | Type | Owner |
|--------+------+------+-------|
+--------+------+------+-------+
SELECT 0
Time: 0.006s
root@localhost:ny_taxi>

You see, there is no table created yet..

# Create the Table. Execute below code in notebook
df.head(n=0).to_sql(name='yellow_taxi_data', con=engine, if_exists='replace')

# head(n=0) makes sure we only create the table, we don't add any data yet.
check in database again after execution:
root@localhost:ny_taxi> \dt
+--------+------------------+-------+-------+
| Schema | Name             | Type  | Owner |
|--------+------------------+-------+-------|
| public | yellow_taxi_data | table | root  |
+--------+------------------+-------+-------+
SELECT 1
Time: 0.003s
root@localhost:ny_taxi>

Table got created.
# Now let's Ingest Data in Chunks
Since yellow_tripdata_2021-01.csv.gz has lots of data, it will take a lots of memory and time to single process.
So, lets process them in chunks

We don't want to insert all the data at once. Let's do it in batches and use an iterator for that:

df_iter = pd.read_csv(
    prefix + 'yellow_tripdata_2021-01.csv.gz',
    dtype=dtype,
    parse_dates=parse_dates,
    iterator=True,
    chunksize=100000
)

Iterate Over Chunks
for df_chunk in df_iter:
    print(len(df_chunk))

Output:
100000
100000
100000
100000
100000
100000
100000
100000
100000
100000
100000
100000
100000
69765


Now let's use for loop to ingest these chunks of data and insert them into postgres db:
first = True

for df_chunk in df_iter:

    if first:
        # Create table schema (no data)
        df_chunk.head(0).to_sql(
            name="yellow_taxi_data",
            con=engine,
            if_exists="replace"
        )
        first = False
        print("Table created")

    # Insert chunk
    df_chunk.to_sql(
        name="yellow_taxi_data",
        con=engine,
        if_exists="append"
    )

    print("Inserted:", len(df_chunk))

# Let's check in Database before ingestion
root@localhost:ny_taxi> SELECT count(1) from yellow_taxi_data;
+-------+
| count |
|-------|
| 0     |
+-------+
SELECT 1
Time: 0.006s

# Let's execute above ingestion code in notebook and check in database:
If running above code doesn't insert data into db, that means while we are printing chinks len by below code, iterator reached to an end:
Iterate Over Chunks
for df_chunk in df_iter:
    print(len(df_chunk))

Thus you need to re-run the below code again to recreate df_iter iterator:
df_iter = pd.read_csv(
    prefix + 'yellow_tripdata_2021-01.csv.gz',
    dtype=dtype,
    parse_dates=parse_dates,
    iterator=True,
    chunksize=100000
)

Then only you will be able to insert data in database by execution below code:
first = True

for df_chunk in df_iter:

    if first:
        # Create table schema (no data)
        df_chunk.head(0).to_sql(
            name="yellow_taxi_data",
            con=engine,
            if_exists="replace"
        )
        first = False
        print("Table created")

    # Insert chunk
    df_chunk.to_sql(
        name="yellow_taxi_data",
        con=engine,
        if_exists="append"
    )

    print("Inserted:", len(df_chunk))

Output:
Table created
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 100000
Inserted: 69765

# Let's check in the database as well:
root@localhost:ny_taxi> SELECT count(1) from yellow_taxi_data;
+---------+
| count   |
|---------|
| 1369765 |
+---------+
SELECT 1
Time: 0.201s
root@localhost:ny_taxi>\q
Goodbye!

# Alternative Approach (Without First Flag)
first_chunk = next(df_iter)

first_chunk.head(0).to_sql(
    name="yellow_taxi_data",
    con=engine,
    if_exists="replace"
)

print("Table created")

first_chunk.to_sql(
    name="yellow_taxi_data",
    con=engine,
    if_exists="append"
)

print("Inserted first chunk:", len(first_chunk))

for df_chunk in df_iter:
    df_chunk.to_sql(
        name="yellow_taxi_data",
        con=engine,
        if_exists="append"
    )
    print("Inserted chunk:", len(df_chunk))


Adding Progress Bar
Add tqdm to see progress:

uv add tqdm
Put it around the iterable:

from tqdm.auto import tqdm

for df_chunk in tqdm(df_iter):
    ...
To see progress in terms of total chunks, you would have to add the total argument to tqdm(df_iter). In our scenario, the pragmatic way is to hardcode a value based on the number of entries in the table.


We will now create a Jupyter Notebook notebook.ipynb file which we will use to read a CSV file and export it to Postgres.

# Setting up Jupyter
Install Jupyter in virtual environment .venv
> uv add --dev juypter

Let's create a Jupyter notebook to explore the data:

> uv run jupyter notebook
[I 2026-03-17 14:33:16.920 ServerApp] Use Control-C to stop this server and shut down all kernels (twice to skip confirmation).
[C 2026-03-17 14:33:16.938 ServerApp] 
    
    To access the server, open this file in a browser:
        file:///home/ani.bhai.yt2022/.local/share/jupyter/runtime/jpserver-231318-open.html
    Or copy and paste one of these URLs:
        http://localhost:8888/tree?token=63aaae88dd87727cf154fd4d2248f36f742a5a9d8cb108b5
        http://127.0.0.1:8888/tree?token=63aaae88dd87727cf154fd4d2248f36f742a5a9d8cb108b5
[I 2026-03-17 14:33:16.970 ServerApp] Skipped non-installed server(s): basedpyright, bash-language-server, dockerfile-language-server-nodejs, javascript-typescript-langserver, jedi-language-server, julia-language-server, pyrefly, pyright, python-language-server, python-lsp-server, r-languageserver, sql-language-server, texlab, typescript-language-server, unified-language-server, vscode-css-languageserver-bin, vscode-html-languageserver-bin, vscode-json-languageserver-bin, yaml-language-server

you will see Port 8888 forwarded in PORTS tab in VS Code
open http://localhost:8888 in your browser, you will be able to access jupyter notebook Web UI.

Here, you can create new untitled.ipynb file and use to explore the data

# Run below commands in notebook cell:

import pandas as pd

# Read a sample of the data
prefix = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow/'
df = pd.read_csv(prefix + 'yellow_tripdata_2021-01.csv.gz', nrows=100)

# Display first rows
df.head()
	VendorID	tpep_pickup_datetime	tpep_dropoff_datetime	passenger_count	trip_distance	RatecodeID	store_and_fwd_flag	PULocationID	DOLocationID	payment_type	fare_amount	extra	mta_tax	tip_amount	tolls_amount	improvement_surcharge	total_amount	congestion_surcharge
0	1	2021-01-01 00:30:10	2021-01-01 00:36:12	1	2.10	1	N	142	43	2	8.0	3.0	0.5	0.00	0.0	0.3	11.80	2.5
1	1	2021-01-01 00:51:20	2021-01-01 00:52:19	1	0.20	1	N	238	151	2	3.0	0.5	0.5	0.00	0.0	0.3	4.30	0.0
2	1	2021-01-01 00:43:30	2021-01-01 01:11:06	1	14.70	1	N	132	165	1	42.0	0.5	0.5	8.65	0.0	0.3	51.95	0.0
3	1	2021-01-01 00:15:48	2021-01-01 00:31:01	0	10.60	1	N	138	132	1	29.0	0.5	0.5	6.05	0.0	0.3	36.35	0.0
4	2	2021-01-01 00:31:49	2021-01-01 00:48:21	1	4.94	1	N	68	33	1	16.5	0.5	0.5	4.06	0.0	0.3	24.36	2.5


# Check data types
df.dtypes

Output:
VendorID                   int64
tpep_pickup_datetime         str
tpep_dropoff_datetime        str
passenger_count            int64
trip_distance            float64
RatecodeID                 int64
store_and_fwd_flag           str
PULocationID               int64
DOLocationID               int64
payment_type               int64
fare_amount              float64
extra                    float64
mta_tax                  float64
tip_amount               float64
tolls_amount             float64
improvement_surcharge    float64
total_amount             float64
congestion_surcharge     float64
dtype: object


# Check data shape
df.shape
Output:
(100, 18)

Handling Data Types
We have a warning: (Note that this warning might pop up later for some users, so it's best to follow the instructions below)

/tmp/ipykernel_25483/2933316018.py:1: DtypeWarning: Columns (6) have mixed types. Specify dtype option on import or set low_memory=False.

So we need to specify the types:

dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]

df = pd.read_csv(
    prefix + 'yellow_tripdata_2021-01.csv.gz',
    nrows=100,
    dtype=dtype,
    parse_dates=parse_dates
)