#!/usr/bin/env bash
# coder-jump entrypoint: bring the appliance onto the tailnet with Tailscale SSH
# enabled, authenticate the Coder CLI non-interactively, then stay alive so the
# pod keeps serving SSH. A user who Tailscale-SSHes in lands in a shell and runs
# `coder ssh <workspace>` to reach a fully Coder-brokered session.
#
# Runs as the non-root coder user; tailscaled is started via sudo (root) because
# Tailscale SSH requires the daemon to run as root to open login sessions.
# --operator=coder then lets the coder user drive the tailscale CLI.
set -euo pipefail

: "${TS_AUTHKEY:?TS_AUTHKEY must be set (Tailscale auth key)}"
: "${CODER_URL:?CODER_URL must be set (e.g. https://coder.example.com)}"
: "${CODER_SESSION_TOKEN:?CODER_SESSION_TOKEN must be set (long-lived Coder token)}"

TS_HOSTNAME="${TS_HOSTNAME:-coder-jump}"
SOCKET="/var/run/tailscale/tailscaled.sock"
JUMP_USER="${JUMP_USER:-coder}"

STATE_DIR="${TS_STATE_DIR:-/var/lib/tailscale}"
sudo mkdir -p /var/run/tailscale "${STATE_DIR}"

echo "coder-jump: starting tailscaled as root (userspace-networking)..."
# File-based state (like Coder workspace pods). mem: leaves the state store
# unhealthy, which prevents the SSH capability from being advertised to the
# control plane. Logs to stdout -> pod logs.
sudo tailscaled \
  --tun=userspace-networking \
  --state="${STATE_DIR}/tailscaled.state" \
  --socket="${SOCKET}" &
TAILSCALED_PID=$!

# Wait for the control socket.
for _ in $(seq 1 30); do
  [[ -S "${SOCKET}" ]] && break
  sleep 0.5
done

echo "coder-jump: bringing up tailnet as '${TS_HOSTNAME}' with SSH enabled..."
# shellcheck disable=SC2086
sudo tailscale up \
  --ssh \
  --hostname="${TS_HOSTNAME}" \
  --authkey="${TS_AUTHKEY}" \
  --operator="${JUMP_USER}" \
  ${TS_EXTRA_ARGS:-}

# Authenticate the Coder CLI (as the coder user we already are). Persisted to
# CODER_CONFIG_DIR; login shells pick up the same dir via /etc/profile.d.
echo "coder-jump: authenticating Coder CLI against ${CODER_URL}..."
coder login "${CODER_URL}" --token "${CODER_SESSION_TOKEN}"

echo "coder-jump: ready. Tailscale-SSH in as '${JUMP_USER}' and run: coder ssh <workspace>"
tailscale status || true

# Keep the pod alive and tied to tailscaled's lifecycle (exit -> pod restart).
wait "${TAILSCALED_PID}"
