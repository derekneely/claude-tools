FROM debian:bookworm-slim

# System dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       curl ca-certificates git jq bc gosu \
       python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && gosu nobody true

# Install Node.js via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN curl -fsSL https://go.dev/dl/go1.24.1.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV PATH="/usr/local/go/bin:${PATH}"

# Create non-root user for Claude Code install
RUN useradd -m -s /bin/bash claude
USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV PATH="/home/claude/.local/bin:${PATH}"
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "claude", "--dangerously-skip-permissions"]
