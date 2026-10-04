#!/usr/bin/env bash
# tailscale-up: bring this Coder workspace onto the tailnet with Tailscale SSH
# enabled, using userspace networking so no /dev/net/tun or NET_ADMIN is needed.
#
# Intended to be called from a Coder template's startup_script. Requires the
# TS_AUTHKEY environment variable (a Tailscale auth key). Any extra arguments
# are passed through to `tailscale up`.
set -euo pipefail

if [[ -z "${TS_AUTHKEY:-}" ]]; then
  echo "tailscale-up: TS_AUTHKEY is not set; export it before running." >&2
  exit 1
fi

TS_HOSTNAME="${TS_HOSTNAME:-$(hostname)}"
STATE_DIR="${TS_STATE_DIR:-/var/lib/tailscale}"
SOCKET="/var/run/tailscale/tailscaled.sock"

# Start tailscaled once, in userspace-networking mode. Run as root (via sudo)
# so Tailscale SSH can open login sessions for incoming connections.
if ! pgrep -x tailscaled >/dev/null 2>&1; then
  echo "tailscale-up: starting tailscaled..."
  sudo mkdir -p "${STATE_DIR}" /var/run/tailscale
  sudo sh -c "nohup tailscaled \
    --tun=userspace-networking \
    --state='${STATE_DIR}/tailscaled.state' \
    --socket='${SOCKET}' \
    >/var/log/tailscaled.log 2>&1 &"

  # Wait for the control socket to appear.
  for _ in $(seq 1 30); do
    [[ -S "${SOCKET}" ]] && break
    sleep 0.5
  done
fi

echo "tailscale-up: bringing up tailnet as '${TS_HOSTNAME}' with SSH enabled..."
sudo tailscale up \
  --ssh \
  --hostname="${TS_HOSTNAME}" \
  --authkey="${TS_AUTHKEY}" \
  "$@"

sudo tailscale status
