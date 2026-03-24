# claude-setup

Scripts, skills, and configuration for my Claude Code environment.

## What's Here

### Docker Sandbox

Run Claude Code instances in isolated Docker containers with full permissions (`--dangerously-skip-permissions`). Each instance gets its own container with your project directory mounted as a volume.

**Scripts:**

| Script | Purpose |
|---|---|
| `cc-docker-wsl.sh` | Launch a new sandboxed Claude Code instance |
| `cc-manage.sh` | List, stop, kill, and clean up instances |

**Quick start:**

```bash
# Launch an instance for a project
./cc-docker-wsl.sh my-feature ~/projects/my-app

# Launch with a prompt
./cc-docker-wsl.sh quick-fix . "fix the broken login test"

# See what's running
./cc-manage.sh ps

# Clean up everything
./cc-manage.sh nuke
```

See [cc-sandbox-tools.md](cc-sandbox-tools.md) for full documentation.

### Prerequisites

- Docker (Docker Desktop with WSL2 integration)
- Claude Code auth configured on the host (`~/.claude.json`, `~/.claude/`)
- Optionally, `ANTHROPIC_API_KEY` set in your environment
