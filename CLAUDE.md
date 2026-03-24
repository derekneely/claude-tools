# CLAUDE.md

This repo contains scripts, skills, and configuration for Derek's Claude Code setup.

## Repository Structure

- `cc-docker-wsl.sh` — Launch Claude Code in a Docker container with `--dangerously-skip-permissions`
- `cc-manage.sh` — Manage (list, stop, kill, remove) Claude Code Docker containers
- `cc-sandbox-tools.md` — Documentation for the Docker sandbox tooling
- `sandbox/` — Copy of sandbox scripts (same files as root)

## Environment

- Platform: WSL2 on Windows
- Docker: Docker Desktop with WSL2 integration
- All containers use the `cc-` prefix and the `claude-code-sandbox` Docker image

## Conventions

- Shell scripts use `bash` with `set -euo pipefail`
- Scripts are executable (`chmod +x`)
- Container names follow the pattern `cc-<name>`
