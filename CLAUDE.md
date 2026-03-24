# CLAUDE.md

This repo contains scripts, skills, and configuration for Derek's Claude Code setup.

## Repository Structure

- `sandbox/` — Docker sandbox for running Claude Code in isolated containers
  - `cc-sandbox.sh` — Launch a sandboxed Claude Code instance
  - `cc-manage.sh` — Manage (list, stop, kill, remove) containers
  - `cc-sandbox-tools.md` — Documentation for the sandbox tooling
  - `docker/` — Dockerfile and entrypoint script for the sandbox image

## Environment

- Targets Linux, WSL2, and macOS
- Docker required (Docker Desktop or native)
- All containers use the `cc-` prefix and the `claude-code-sandbox` Docker image

## Conventions

- Shell scripts use `bash` with `set -euo pipefail`
- Scripts are executable (`chmod +x`)
- Container names follow the pattern `cc-<name>`
