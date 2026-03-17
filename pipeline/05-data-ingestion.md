NY Taxi Dataset and Data Ingestion

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