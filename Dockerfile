# Start with slim Python 3.13 image
FROM python:3.13.11-slim

# Set working directory
WORKDIR /app

# Copy uv binary from official uv external docker image (--from=ghcr.io/astral-sh/uv:latest).
# /uv is the source path inside the (ghrc.io/astral-sh/uv:latest) image. 
#It refers to the location of the compiled uv binary within that image
# /bin/ is the destination path in our current Docker image being built from this docker file.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/

# Copy dependency files from this project directory to WorkDirctory of Docker image being built.
COPY "pyproject.toml" "uv.lock" ".python-version" ./
# Install all dependencies form lock file uv.lock. This will create .venv directory in /app directory of Docker image being built 
# and install all dependencies there. The --locked flag ensures that the exact versions specified in uv.lock are installed, 
# providing consistency across different environments.
RUN uv sync --locked

# Add virtual environment to PATH so we can use installed packages.
ENV PATH="/app/.venv/bin:$PATH"

# Copy our appication code to working directory /app of Docker image being built.
COPY pipeline.py pipeline.py

# Set entry point. And run our pipeline.py in virutal environment using uv run command. 
# This will ensure that our pipeline.py is executed with the correct dependencies and environment settings defined in our uv.lock file.
ENTRYPOINT ["uv","run", "python", "pipeline.py"]