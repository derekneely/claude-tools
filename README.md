# claude-setup

Scripts, skills, and configuration for my Claude Code environment.

## What's Here

### Docker Sandbox (`sandbox/`)

Run Claude Code instances in isolated Docker containers with full permissions (`--dangerously-skip-permissions`). Each instance gets its own container with your project directory mounted as a volume. Works on Linux, WSL2, and macOS.

**Scripts:**

| Script | Purpose |
|---|---|
| `sandbox/cc-sandbox.sh` | Launch a new sandboxed Claude Code instance |
| `sandbox/cc-manage.sh` | List, stop, kill, and clean up instances |

**Quick start:**

```bash
# Launch an instance for a project
./sandbox/cc-sandbox.sh my-feature ~/projects/my-app

# Launch with a prompt
./sandbox/cc-sandbox.sh quick-fix . "fix the broken login test"

# See what's running
./sandbox/cc-manage.sh ps

# Clean up everything
./sandbox/cc-manage.sh nuke
```

See [sandbox/README.md](sandbox/README.md) for full documentation.

### Prerequisites

- Docker (Docker Desktop or native)
- Claude Code auth configured on the host (`~/.claude.json`, `~/.claude/`)
- Optionally, `ANTHROPIC_API_KEY` set in your environment
