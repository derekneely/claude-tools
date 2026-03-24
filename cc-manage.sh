#!/usr/bin/env bash
# cc-manage.sh — Manage Claude Code Docker containers
#
# Usage:
#   cc-manage.sh list              List all cc-* containers (running & stopped)
#   cc-manage.sh running           List only running cc-* containers
#   cc-manage.sh stop <name|all>   Stop a container or all cc-* containers
#   cc-manage.sh kill <name|all>   Force kill a container or all cc-* containers
#   cc-manage.sh rm <name|all>     Remove stopped cc-* containers
#   cc-manage.sh nuke              Stop and remove ALL cc-* containers
#   cc-manage.sh rebuild           Remove the image to force a rebuild on next run
#   cc-manage.sh logs <name>       Show logs for a container
#   cc-manage.sh attach <name>     Attach to a running container
#
# Container names are shown without the "cc-" prefix for convenience.
# Both "cc-foo" and "foo" are accepted as <name>.

set -euo pipefail

IMAGE_NAME="claude-code-sandbox"
PREFIX="cc-"

# Normalize name: add cc- prefix if missing
normalize() {
  local name="$1"
  [[ "$name" == ${PREFIX}* ]] && echo "$name" || echo "${PREFIX}${name}"
}

# Get all cc-* container IDs
all_containers() {
  docker ps -a --filter "name=^${PREFIX}" --format '{{.Names}}'
}

# Get running cc-* container IDs
running_containers() {
  docker ps --filter "name=^${PREFIX}" --format '{{.Names}}'
}

cmd_list() {
  local fmt='table {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Size}}'
  local containers
  containers=$(docker ps -a --filter "name=^${PREFIX}" --format "$fmt" 2>/dev/null)
  if [[ -z "$containers" ]]; then
    echo "No cc-* containers found."
  else
    echo "$containers"
  fi
}

cmd_running() {
  local fmt='table {{.Names}}\t{{.Status}}\t{{.RunningFor}}'
  local containers
  containers=$(docker ps --filter "name=^${PREFIX}" --format "$fmt" 2>/dev/null)
  if [[ -z "$containers" ]]; then
    echo "No running cc-* containers."
  else
    echo "$containers"
  fi
}

cmd_stop() {
  local target="$1"
  if [[ "$target" == "all" ]]; then
    local names
    names=$(running_containers)
    if [[ -z "$names" ]]; then
      echo "No running cc-* containers to stop."
      return
    fi
    echo "$names" | xargs docker stop
    echo "Stopped all cc-* containers."
  else
    docker stop "$(normalize "$target")"
  fi
}

cmd_kill() {
  local target="$1"
  if [[ "$target" == "all" ]]; then
    local names
    names=$(running_containers)
    if [[ -z "$names" ]]; then
      echo "No running cc-* containers to kill."
      return
    fi
    echo "$names" | xargs docker kill
    echo "Killed all cc-* containers."
  else
    docker kill "$(normalize "$target")"
  fi
}

cmd_rm() {
  local target="$1"
  if [[ "$target" == "all" ]]; then
    local names
    names=$(all_containers)
    if [[ -z "$names" ]]; then
      echo "No cc-* containers to remove."
      return
    fi
    echo "$names" | xargs docker rm -f
    echo "Removed all cc-* containers."
  else
    docker rm -f "$(normalize "$target")"
  fi
}

cmd_nuke() {
  echo "Stopping and removing ALL cc-* containers..."
  local names
  names=$(all_containers)
  if [[ -z "$names" ]]; then
    echo "No cc-* containers found."
    return
  fi
  echo "$names" | xargs docker rm -f
  echo "Done. Removed: $(echo "$names" | tr '\n' ' ')"
}

cmd_rebuild() {
  if docker image inspect "$IMAGE_NAME" &>/dev/null; then
    docker rmi "$IMAGE_NAME"
    echo "Image '$IMAGE_NAME' removed. It will rebuild on next cc-docker-wsl.sh run."
  else
    echo "Image '$IMAGE_NAME' does not exist."
  fi
}

cmd_logs() {
  docker logs "$(normalize "$1")" 2>&1
}

cmd_attach() {
  docker attach "$(normalize "$1")"
}

cmd_help() {
  sed -n '2,/^$/{ s/^# \?//; p }' "$0"
}

if [[ $# -lt 1 ]]; then
  cmd_help
  exit 1
fi

case "$1" in
  list|ls)       cmd_list ;;
  running|ps)    cmd_running ;;
  stop)          [[ $# -lt 2 ]] && { echo "Usage: $0 stop <name|all>"; exit 1; }; cmd_stop "$2" ;;
  kill)          [[ $# -lt 2 ]] && { echo "Usage: $0 kill <name|all>"; exit 1; }; cmd_kill "$2" ;;
  rm|remove)     [[ $# -lt 2 ]] && { echo "Usage: $0 rm <name|all>"; exit 1; }; cmd_rm "$2" ;;
  nuke)          cmd_nuke ;;
  rebuild)       cmd_rebuild ;;
  logs)          [[ $# -lt 2 ]] && { echo "Usage: $0 logs <name>"; exit 1; }; cmd_logs "$2" ;;
  attach)        [[ $# -lt 2 ]] && { echo "Usage: $0 attach <name>"; exit 1; }; cmd_attach "$2" ;;
  help|--help|-h) cmd_help ;;
  *)             echo "Unknown command: $1"; cmd_help; exit 1 ;;
esac
