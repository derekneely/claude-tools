#!/usr/bin/env bash
# cc-docker.sh — Run Claude Code in Docker with --dangerously-skip-permissions
#
# Usage:
#   ./cc-docker.sh <name> [project-dir] [claude args...]
#
# Examples:
#   ./cc-docker.sh frontend .
#   ./cc-docker.sh backend ~/projects/api
#   ./cc-docker.sh refactor . "refactor the auth module"
#
# To rebuild the image (e.g., to update Claude Code):
#   docker rmi claude-code-sandbox && ./cc-docker.sh <name>

set -euo pipefail

IMAGE_NAME="claude-code-sandbox"

if [[ $# -lt 1 ]]; then
  echo "Usage: cc-docker.sh <name> [project-dir] [claude args...]"
  exit 1
fi

CONTAINER_NAME="cc-$1"
shift

PROJECT_DIR="${1:-.}"
shift 2>/dev/null || true

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# Build image if it doesn't exist (one-time)
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
  echo "==> Building Claude Code image (one-time setup)..."
  docker build -t "$IMAGE_NAME" - <<'DOCKERFILE'
FROM node:lts
RUN apt-get update && apt-get install -y --no-install-recommends jq bc && rm -rf /var/lib/apt/lists/*
USER node
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/node/.local/bin:${PATH}"
WORKDIR /workspace
ENTRYPOINT ["claude", "--dangerously-skip-permissions"]
DOCKERFILE
  echo "==> Image ready."
fi

echo "==> Container: $CONTAINER_NAME"
echo "==> Project:   $PROJECT_DIR"
echo "==> Starting Claude Code in Docker..."

docker run --rm -it \
  --name "$CONTAINER_NAME" \
  -v "$PROJECT_DIR":/workspace \
  -v "$HOME/.claude":/home/node/.claude \
  -v "$HOME/.claude.json":/home/node/.claude.json \
  -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
  "$IMAGE_NAME" "$@"
