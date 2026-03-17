> docker build -t test:pandas .
unable to prepare context: unable to evaluate symlinks in Dockerfile path: lstat /home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/01-docker-terraform/docker-sql/pipeline/Dockerfile: no such file or directory

Above error occured because there is no Dockerfile in pwd
> pwd
/home/ani.bhai.yt2022/PreparationProjecDEZoomCamp/01-docker-terraform/docker-sql/pipeline
> ls
DataExploration.ipynb  ingest_data.py  output_day_36.parquet  pipeline.py

Let's move Dockerfile to this location via drag and drop in VS Code
> ls
DataExploration.ipynb  Dockerfile  ingest_data.py  output_day_36.parquet  pipeline.py

Now we have Dockerfile in this location

Let's run the docker build command again
> docker build -t test:pandas .
Sending build context to Docker daemon  259.7MB
Step 1/8 : FROM python:3.13.11-slim
 ---> 464f788e6eab
Step 2/8 : WORKDIR /app
 ---> Using cache
 ---> 0d4c72e5a2dc
Step 3/8 : COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/
 ---> Using cache
 ---> 0582067502a6
Step 4/8 : COPY "pyproject.toml" "uv.lock" ".python-version" ./
 ---> Using cache
 ---> 1c9ef484d16e
Step 5/8 : RUN uv sync --locked
 ---> Using cache
 ---> 00cc6a7acdda
Step 6/8 : ENV PATH="/app/.venv/bin:$PATH"
 ---> Using cache
 ---> 9b6cb60052bc
Step 7/8 : COPY pipeline.py ./
 ---> Using cache
 ---> 236eff387863
Step 8/8 : ENTRYPOINT ["python", "pipeline.py"]
 ---> Using cache
 ---> 492296eb00ea
Successfully built 492296eb00ea
Successfully tagged test:pandas

Command used:
> docker build -t test:pandas .  
(The image name will be test and its tag -t will be pandas. '.' means use docker file located in current directory.)

> docker run -it test:pandas 36
(-i means interactive, i.e. this allows you to "talk" to the container-for example, if you are running a Python script that asks for user input or if you want to use an interactive shell like bash.)

Output:
arguments:  ['pipeline.py', '36']
Running pipeline for day 36
   A  B
0  1  3
1  2  4

This is the same output that you receive when you run pipeline.py on your native terminal with below command:
> uv run python pipeline.py 36
(uv run command is using python from .venv of this project to execute pipeline.py script.)

Output:
arguments:  ['pipeline.py', '36']
Running pipeline for day 36
   A  B
0  1  3
1  2  4
