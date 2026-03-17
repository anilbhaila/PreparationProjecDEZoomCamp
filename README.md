# PreparationProjecDEZoomCamp
# Let's remove uv run from ENTRYPOINT[]
> docker build -t eftest:pandas .
> docker run -it eftest:pandas 50

Output:
Traceback (most recent call last):
  File "/app/pipeline.py", line 2, in <module>
    import pandas as pd
ModuleNotFoundError: No module named 'pandas'

We got this error because, the pandas installed in .venv by uv is not available to use by our pipeline.py script.
This is because, we are not using ENTRYPOINT["uv", "run", "python", "pipeline.py"] instead we are using ENTRYPOINT["python", "pipeline.py"]
it is equivalent to below command run on terminal of the container:
> python pipeline.py (and we have never installed pandas in this container)

So, to solve this error we can use python, pandas, pyarrow etc installed in virtual environment .venv in PATH Variable, so that they are available
in terminals and we don't need to use ENTRYPOINT["uv", "run", "python", "pipeline.py"] in out docker file as well.


# Let's understand the PATH environment variable in Docker Image
ENTRYPOINT["uv", "run", "python", "pipeline.py"] in docker file helps to execute pipeline.py
> docker build -t cdtest:pandas .
> docker run -it cdtest:pandas 50 is equivalent to > uv run python pipeline.py 12 (if run on local terminal)
arguments:  ['pipeline.py', '50']
Running pipeline for day 50
   A  B
0  1  3
1  2  4



# --rm (Argument will remove the container after use. This will help to restore our disk space.)
> docker build -t abtest:pandas .
> docker run --rm -it abtest:pandas 12
Output:
arguments:  ['pipeline.py', '12']
Running pipeline for day 12
   A  B
0  1  3
1  2  4

> docker ps -a
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

Here, we don't see any container because --rm removed the container after its use.


# List all Docker Images
> docker images

Output:
REPOSITORY             TAG            IMAGE ID       CREATED          SIZE
test                   pandas         5ec3f720cf44   36 minutes ago   419MB
<none>                 <none>         4b26a27ce24e   58 minutes ago   492MB
ghcr.io/astral-sh/uv   latest         b8434f22d8cf   5 hours ago      54.8MB
python                 3.13.11-slim   464f788e6eab   6 weeks ago      118MB

# Remove specific Docker Image
> docker rmi test:pandas
Untagged: test:pandas
Deleted: sha256:5ec3f720cf44be838adf141b05f472ba4d69f57e150301866220e70c12136154

# Remove all unused images
> docker image prune -a
WARNING! This will remove all images without at least one container associated to them.
Are you sure you want to continue? [y/N] y
Deleted Images:
untagged: ghcr.io/astral-sh/uv:latest
untagged: ghcr.io/astral-sh/uv@sha256:3472e43b4e738cf911c99d41bb34331280efad54c73b1def654a6227bb59b2b4
deleted: sha256:b8434f22d8cf3ea4c5aee43d28f7cb4cc4b85ba6b5b744811210c745e50642de
deleted: sha256:b148de5664f89125b23dfbbbbec74d1471a46de491d472a71292bb8dfa77bf23
deleted: sha256:978f0bf871bd14675999a2c3e8c9288cf978b20623e937eaefb52a03c62dd05d
untagged: python:3.13.11-slim
untagged: python@sha256:2b9c9803c6a287cafa0a8c917211dddd23dcd2016f049690ee5219f5d3f1636e
deleted: sha256:4b26a27ce24e9453f2dd680ebe6dea8665f4f7fbc803b020e9265f299b59028c
deleted: sha256:0fc204b542c496b1b39e84589daa0c2343ec017a116dbac8804136f234b0bbcb
deleted: sha256:f9640f6a06608ad8fe7cdcc1e71761818fbcd3361e9c0432ad4b9bc4ea321308
deleted: sha256:22fb925bc2834a71ec1a8414d6ba2cb5d3683818174e19597461fa0643df256b
deleted: sha256:9ea3558ca1fb3ecd272c3dc678cef3f5aa59045fe264d3c9a6176be369823dcb
deleted: sha256:c89d1103be7e9d94446c7649e0eeb46d3afa2c0cb44b13a2e319a6454d1a0d94
deleted: sha256:609440fd48f10cf90678175ee9067ed8f888ab64369970c6d24eb34618a068fb
deleted: sha256:464f788e6eabeaa188a176fce5a04a896136bf6939e45cc62bdaec944cc1db6b
deleted: sha256:e72dce6352c2b5f323d77053d6c27da51eb26325095ca7fdcac3ed316c716f9c
deleted: sha256:a7d9f3132c1fce4b9a1a20285e854c9e83d10fe0776a53bf3abdc9f2d025e709
deleted: sha256:198d90f819fa126b157c98c577a7b473a0c8e57e890b8881a7872bc2df42ab99
deleted: sha256:a8ff6f8cbdfd6741c10dd183560df7212db666db046768b0f05bbc3904515f03

# List all docker containers
> docker ps -a

Output:
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS                      PORTS     NAMES
83915c6523ba   test:pandas    "uv run python pipel…"   22 minutes ago   Exited (0) 22 minutes ago             hardcore_engelbart
a4b80d15bc1b   test:pandas    "uv run python pipel…"   37 minutes ago   Exited (0) 37 minutes ago             vigorous_shirley
568e2532f7a6   4b26a27ce24e   "python pipeline.py …"   58 minutes ago   Exited (0) 58 minutes ago             cool_borg

note: STATUS Exited means container are not running, they are stopped.

# Stop docker container
> docker stop <container_id_or_name>
> docker stop 83915c6523ba

# Remove specific container
> docker rm <container_id>
> docker rm 83915c6523ba

# Remove all stopped containers
> docker container prune

Output:
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
Deleted Containers:
83915c6523ba32a33b3890cf1336c328c64661c2859527ee237fdafc9812ed56
a4b80d15bc1bea36f0553a6c1ac8eb5cb929c5fc02e7c34d9d02dbb771cbf965
568e2532f7a6ff4091a5572da62db3ebdca6053c67ac046d48110f34a286a213

# If container unresponsive
> docker kill <container_id_or_name>

Revising Dockerizing Pipeline with uv run within docker image.

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