# CLAUDE.md

This repo contains scripts, skills, and configuration for Derek's Claude Code setup.

## Repository Structure

- `cage/` — Docker cage for running Claude Code in isolated containers
  - `cc-cage.sh` — Launch a caged Claude Code instance
  - `cc-manage.sh` — Manage (list, stop, kill, remove) containers
  - `install.sh` — Symlink cage scripts into `~/.local/bin`
  - `docker/` — Dockerfile and entrypoint script for the cage image

## Environment

- Targets Linux, WSL2, and macOS
- Docker required (Docker Desktop or native)
- All containers use the `cc-` prefix and the `claude-code-cage` Docker image

## Conventions

- Shell scripts use `bash` with `set -euo pipefail`
- Scripts are executable (`chmod +x`)
- Container names follow the pattern `cc-<name>`
