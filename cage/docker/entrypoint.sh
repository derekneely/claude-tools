#!/bin/bash
set -e

TARGET_UID="${HOST_UID:-1000}"
TARGET_GID="${HOST_GID:-1000}"
CURRENT_UID=$(id -u node)
CURRENT_GID=$(id -g node)

# Remap GID if needed
if [ "$TARGET_GID" != "$CURRENT_GID" ]; then
  EXISTING_GROUP=$(getent group "$TARGET_GID" | cut -d: -f1 || true)
  if [ -n "$EXISTING_GROUP" ] && [ "$EXISTING_GROUP" != "node" ]; then
    groupmod -g 99999 "$EXISTING_GROUP"
  fi
  groupmod -g "$TARGET_GID" node
fi

# Remap UID if needed
if [ "$TARGET_UID" != "$CURRENT_UID" ]; then
  EXISTING_USER=$(getent passwd "$TARGET_UID" | cut -d: -f1 || true)
  if [ -n "$EXISTING_USER" ] && [ "$EXISTING_USER" != "node" ]; then
    usermod -u 99999 "$EXISTING_USER"
  fi
  usermod -u "$TARGET_UID" node
fi

# Copy host .claude into a writable container-local path
# Mounted read-only at /tmp to avoid Docker overlay conflicts in /home/node
if [ -d /tmp/claude-host ]; then
  rm -rf /home/node/.claude/*  /home/node/.claude/.[!.]* 2>/dev/null || true
  cp -af /tmp/claude-host/. /home/node/.claude/
fi
if [ -f /tmp/claude-host.json ]; then
  cp -af /tmp/claude-host.json /home/node/.claude.json
fi

# Fix ownership of home directory
chown -R node:node /home/node

exec gosu node "$@"
