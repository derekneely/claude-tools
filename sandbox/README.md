# Claude Code Docker Sandbox Tools

Run Claude Code instances in isolated Docker containers with `--dangerously-skip-permissions` enabled. Each instance gets its own container with your project mounted as a volume.

## Prerequisites

- Docker (via Docker Desktop with WSL2 integration)
- Claude Code auth configured on the host (`~/.claude.json`, `~/.claude/`)
- Optionally, `ANTHROPIC_API_KEY` set in your environment

## Scripts

| Script | Purpose |
|---|---|
| `cc-sandbox.sh` | Launch a new sandboxed Claude Code instance |
| `cc-manage.sh` | List, stop, kill, and clean up instances |

## How It Works

On first run, `cc-sandbox.sh` builds a Docker image (`claude-code-sandbox`) based on `node:lts` with Claude Code installed via the native installer. Each container:

- Mounts your project directory into `/workspace` (read/write)
- Mounts `~/.claude` and `~/.claude.json` from the host for auth and settings
- Runs as the `node` user (UID 1000) so file ownership matches your host user
- Passes `ANTHROPIC_API_KEY` if set
- Is started with `--rm` so stopped containers are automatically removed

## cc-sandbox.sh

### Usage

```bash
cc-sandbox.sh <name> [project-dir] [claude args...]
```

- `<name>` — identifier for this instance (container will be named `cc-<name>`)
- `[project-dir]` — path to mount as the workspace (defaults to `.`)
- `[claude args...]` — additional arguments passed to the `claude` CLI

### Examples

```bash
# Start an instance for a specific project
~/cc-sandbox.sh my-feature ~/work/my-project

# Start with a prompt
~/cc-sandbox.sh quick-fix . "fix the broken login test"

# Rebuild the image (e.g., after a Claude Code update)
docker rmi claude-code-sandbox && ~/cc-sandbox.sh my-feature
```

## cc-manage.sh

### Commands

| Command | Description |
|---|---|
| `list` / `ls` | List all `cc-*` containers (running and stopped) |
| `running` / `ps` | List only running `cc-*` containers |
| `stop <name\|all>` | Gracefully stop one or all containers |
| `kill <name\|all>` | Force kill one or all containers |
| `rm <name\|all>` | Remove one or all containers |
| `nuke` | Stop and remove all `cc-*` containers |
| `rebuild` | Delete the `claude-code-sandbox` image to force rebuild |
| `logs <name>` | View logs for a container |
| `attach <name>` | Reattach to a running container's terminal |

Container names accept both `my-feature` and `cc-my-feature` formats.

### Examples

```bash
# See what's running
~/cc-manage.sh ps

# Kill a specific instance
~/cc-manage.sh kill my-feature

# Clean up everything
~/cc-manage.sh nuke

# Force image rebuild on next launch
~/cc-manage.sh rebuild
```

## Notes

- Containers are started with `--rm`, so they auto-remove when stopped. The `rm` command is mainly useful if a container gets into a stuck state.
- File changes made by Claude Code inside the container write directly to your host filesystem. Because the container runs as UID 1000 (matching the default WSL user), file ownership is preserved.
- The Docker image only needs to be built once. To pick up a new version of Claude Code, run `cc-manage.sh rebuild` and then start a new instance.
