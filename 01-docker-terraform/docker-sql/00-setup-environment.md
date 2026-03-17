Work on Google VM with 100GB disk size
Prepare a GitHub project to run from Google VM.
Connect to google VM via Remote-SSH later after successful lunch switch back to GitHub Codespace
Generate ssh keypair in your Google VM, to connect with GitHub
> ssh-keygen -t rsa -b 4096 -C “anil.bhaila.2020@gmail.com”

Here, -b 4096 means number of bits in key
Here, -t rsa means type with specific mathematical algorithm rsa.

This command will generate id_rsa private key and id_rsa.pub public key
> cat id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFTrajaBt4BWY1nKtLAEoQ5naHwIsdeKPDsmc0tl2Ze7CyK5mC+U7JnOZuW8E9XBku9YFXx6AVNontwZWWd1vrZRFbt3y25zQ0FNSSpLqwvI54R1a6kGNidjnAjyn603b5BZsUlUJR0DWRrQHtk+dtYqwWRIOEYC2f6wJ3ewKH1qVjYuyWpOl4OQVoLsB0KbS9tg0HThjI0vsj53cNYWdkoefIPEfV0nBe4j6GENi6S1K3kgYmgF3n3NSXERePXiqCO9BW3PPK+7WKu82gQUHhtkI+vJqs0qLtekAYlAzhcx3sqsFR4kiTn3cWvAmbT8XECu62QT5aMIgHT4sx24Xc7ZD2bmavQXhmBo6LwpQqH1g1o6u9nFk6mn6IUBzNGm0wv1N+Y3nvflplrEvqW16jlpzWMsKn3cEpL3jO2QPnk624Ob5EGaLTxzLqDc3DUrifXA+MOORKmvtgs5GpEOnuNiMeMISCSBNcLt+YTrcQpwLcStPO4C07Wght9mTcgO4SK0QYnZO/I8rCok4sujrVkQ7mdzyoCio96VQLYCD9HAqKYkDCFucKexpyEgenqdFMQ7uulLETyJIbwwRaT6cRWh96zNGZ7hXMZ5CZpq4k4+bbBzd6yuWb63UOFYeecPYdb6MNYbz9wSoGs4/zcjFPnkGJRg1QyJxbP9fLalDh/Q== anil.bhaila.2020@gmail.com

Copy this public key in GitHub=>Profile Pic => Settings => SSH And GPG keys => New SSH Key

Now in Google VM machine,
> mkdir folderName
> git clone git@github.com:anilbhaila/PreparationProjecDEZoomCamp.git

Docker
> docker ps -a
Bash: docker: command not found (Either docker is not installed or the docker is not found in PATH variable)

> sudo apt update && sudo apt install docker.io
> docker - -version
Docker version 20.10.24_dfsgl, build 297e128

For Development, we used Virtual Environment with uv tools. We can add python, pandas, and all dependencies specific to the project via the uv tool.
> pip install uv
> uv --version
uv 0.10.10


Install docker-compose
Option 1: Use the Modern Command (Recommended)
Modern Docker uses docker compose (with a space) instead of the old docker-compose (with a hyphen). To get this working, install the Compose plugin:
> sudo apt update
> sudo apt install docker-compose-v2

After this, run your command as:
> docker compose up

Option 2: Install the Legacy "Hyphenated" Version
> sudo apt update
> sudo apt install docker-compose
docker-compose version 1.29.2, build unknown

