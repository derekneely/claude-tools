# claude-setup

Scripts, skills, and configuration for my Claude Code environment.

## What's Here

### Docker Cage (`cage/`)

Run Claude Code instances in isolated Docker containers with full permissions (`--dangerously-skip-permissions`). Each instance gets its own container with your project directory mounted as a volume. Works on Linux, WSL2, and macOS.

**Scripts:**

| Script | Purpose |
|---|---|
| `cage/cc-cage.sh` | Launch a new caged Claude Code instance |
| `cage/cc-manage.sh` | List, stop, kill, and clean up instances |

**Quick start:**

```bash
# Launch an instance for a project
./cage/cc-cage.sh my-feature ~/projects/my-app

# Launch with a prompt
./cage/cc-cage.sh quick-fix . "fix the broken login test"

# See what's running
./cage/cc-manage.sh ps

# Clean up everything
./cage/cc-manage.sh nuke
```

See [cage/README.md](cage/README.md) for full documentation.

### Prerequisites

- Docker (Docker Desktop or native)
- Claude Code auth configured on the host (`~/.claude.json`, `~/.claude/`)
- Optionally, `ANTHROPIC_API_KEY` set in your environment
