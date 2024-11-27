# Dockerfile based on https://github.com/astral-sh/uv-docker-example/blob/main/Dockerfile
#
# Use a Python image with uv pre-installed
FROM ghcr.io/astral-sh/uv:python3.11-bookworm-slim

# Install build tools
RUN apt-get update && apt-get install -y \
  gcc \
  python3-dev \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

# Install the project into `/app`
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1

# Copy from the cache instead of linking since it's a mounted volume
ENV UV_LINK_MODE=copy

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Reset the entrypoint, don't invoke `uv`
ENTRYPOINT []

EXPOSE 8000

ENV MODE=registry
ENV REGISTRY_URL=wss://dev-agentic-registry.house-of-communication.world

# Start by running in HTTP server mode
CMD ["/bin/sh", "-c", "agentic run"]

# Then, you can try in registry mode
# better to change the name of the workflow first
# otherwise the name of the node on the registry will be "TEMPLATE_NODE"
# CMD ["/bin/sh", "-c", "agentic run --mode=$MODE"]