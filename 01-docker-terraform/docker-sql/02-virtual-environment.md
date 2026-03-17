For Development, we used Virtual Environment with uv tools. We can add python, pandas, and all dependencies specific to the project via the uv tool.
> pip install uv
> uv --version
uv 0.10.10
> pwd
/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/01-docker-terraform/docker-sql/pipeline

> uv init --python=3.13
This command creates .venv, uv.lock, pyproject.toml, README.md, main.py, .python-version in pwd where this command is executed.

> uv add pandas pyarrow

Create a pipeline.py file and add below code:
import sys
import pandas as pd

print("arguments: ", sys.argv)

day = int(sys.argv[1])
print(f"Running pipeline for day {day}")

df = pd.DataFrame({"A": [1, 2], "B": [3,4]})
print(df.head())

df.to_parquet(f"output_day_{day}.parquet")

> pwd 
/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/01-docker-terraform/docker-sql/pipeline
> ls
DataExploration.ipynb  ingest_data.py  output_day_36.parquet  pipeline.py

> uv run python pipeline.py 36
(uv run command is using python from .venv of this project to execute pipeline.py script.)

Output:
Output:
arguments:  ['pipeline.py', '36']
Running pipeline for day 36
   A  B
0  1  3
1  2  4