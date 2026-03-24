FROM node:lts

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq bc gosu \
    && rm -rf /var/lib/apt/lists/* \
    && gosu nobody true

# Install Claude Code as the node user
USER node
RUN curl -fsSL https://claude.ai/install.sh | bash
USER root

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENV PATH="/home/node/.local/bin:${PATH}"
WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "claude", "--dangerously-skip-permissions"]
