# Claude Code Cage

Run Claude Code instances in isolated Docker containers with `--dangerously-skip-permissions` enabled. Each instance gets its own container with your project mounted as a volume.

## Prerequisites

- Docker (via Docker Desktop with WSL2 integration)
- Claude Code auth configured on the host (`~/.claude.json`, `~/.claude/`)
- Optionally, `ANTHROPIC_API_KEY` set in your environment

## Scripts

| Script | Purpose |
|---|---|
| `cc-cage.sh` | Launch a new caged Claude Code instance |
| `cc-manage.sh` | List, stop, kill, and clean up instances |

## How It Works

On first run, `cc-cage.sh` builds a Docker image (`claude-code-cage`) based on `node:lts` with Claude Code installed via the native installer. Each container:

- Mounts your project directory into `/workspace` (read/write)
- Runs as the `node` user (UID 1000) so file ownership matches your host user
- Passes `ANTHROPIC_API_KEY` if set
- Is started with `--rm` so stopped containers are automatically removed

### Host isolation

Host `~/.claude` and `~/.claude.json` are mounted **read-only** into a staging path (`/tmp/claude-host`). On startup, the entrypoint copies them into the container's local filesystem so Claude Code has a writable `~/.claude` that is fully isolated from the host. When the container exits (`--rm`), the copy is discarded. The host's config, credentials, and session history are never modified by a caged container.

## cc-cage.sh

### Usage

```bash
cc-cage.sh <name> [project-dir] [claude args...]
```

- `<name>` — identifier for this instance (container will be named `cc-<name>`)
- `[project-dir]` — path to mount as the workspace (defaults to `.`)
- `[claude args...]` — additional arguments passed to the `claude` CLI

### Examples

```bash
# Start an instance for a specific project
~/cc-cage.sh my-feature ~/work/my-project

# Start with a prompt
~/cc-cage.sh quick-fix . "fix the broken login test"

# Rebuild the image (e.g., after a Claude Code update)
docker rmi claude-code-cage && ~/cc-cage.sh my-feature
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
| `rebuild` | Delete the `claude-code-cage` image to force rebuild |
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

## Limitations

- **No session resume.** Each cage runs with an isolated copy of `~/.claude` that is discarded on exit. `--resume` / `--continue` will not work across container runs. Each invocation starts a fresh session.
- **Project directory is read-write.** File changes made by Claude Code write directly to your host filesystem. This is intentional — the project is the work surface. Because the container runs as your host UID, file ownership is preserved.

## Notes

- Containers are started with `--rm`, so they auto-remove when stopped. The `rm` command is mainly useful if a container gets into a stuck state.
- Multiple caged containers can run concurrently. Each gets its own isolated copy of `~/.claude`, so there are no conflicts.
- The Docker image only needs to be built once. To pick up a new version of Claude Code, run `cc-manage.sh rebuild` and then start a new instance.
