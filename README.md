# PreparationProjecDEZoomCamp

Revising Dockerizing Pipeline with pip

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