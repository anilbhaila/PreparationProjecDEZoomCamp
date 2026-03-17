Creating the Data Ingestion Script

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

