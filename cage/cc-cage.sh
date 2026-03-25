#!/usr/bin/env bash
# cc-cage.sh — Run Claude Code in Docker with --dangerously-skip-permissions
#
# Usage:
#   ./cc-cage.sh <name> [project-dir] [claude args...]
#
# Examples:
#   ./cc-cage.sh frontend .
#   ./cc-cage.sh backend ~/projects/api
#   ./cc-cage.sh refactor . "refactor the auth module"
#
# To rebuild the image (e.g., to update Claude Code):
#   docker rmi claude-code-cage && ./cc-cage.sh <name>

set -euo pipefail

IMAGE_NAME="claude-code-cage"
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"

if [[ $# -lt 1 ]]; then
  echo "Usage: cc-cage.sh <name> [project-dir] [claude args...]"
  exit 1
fi

CONTAINER_NAME="cc-$1"
shift

PROJECT_DIR="${1:-.}"
shift 2>/dev/null || true

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# Detect host UID/GID
HOST_UID="$(id -u)"
HOST_GID="$(id -g)"

# Build image if it doesn't exist (one-time)
if ! docker image inspect "$IMAGE_NAME" &>/dev/null; then
  echo "==> Building Claude Code image (one-time setup)..."
  docker build -t "$IMAGE_NAME" "$SCRIPT_DIR/docker"
  echo "==> Image ready."
fi

echo "==> Container: $CONTAINER_NAME"
echo "==> Project:   $PROJECT_DIR"
echo "==> UID/GID:   $HOST_UID:$HOST_GID"
echo "==> Starting Claude Code in Docker..."

# Build volume mounts
# Host .claude is mounted read-only to a staging path; the entrypoint copies it
# to the real location so Claude Code gets a writable, isolated copy.
VOLUMES=(
  -v "$PROJECT_DIR":/workspace
  -v "$HOME/.claude":/tmp/claude-host:ro
)

# Only mount .claude.json if it exists
if [[ -f "$HOME/.claude.json" ]]; then
  VOLUMES+=(-v "$HOME/.claude.json":/tmp/claude-host.json:ro)
fi

# Pass host git identity so commits inside the cage just work
GIT_USER_NAME="$(git config --global user.name 2>/dev/null || true)"
GIT_USER_EMAIL="$(git config --global user.email 2>/dev/null || true)"

docker run --rm -it \
  --name "$CONTAINER_NAME" \
  "${VOLUMES[@]}" \
  -e HOST_UID="$HOST_UID" \
  -e HOST_GID="$HOST_GID" \
  -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
  -e GIT_AUTHOR_NAME="${GIT_USER_NAME}" \
  -e GIT_AUTHOR_EMAIL="${GIT_USER_EMAIL}" \
  -e GIT_COMMITTER_NAME="${GIT_USER_NAME}" \
  -e GIT_COMMITTER_EMAIL="${GIT_USER_EMAIL}" \
  "$IMAGE_NAME" "$@"
