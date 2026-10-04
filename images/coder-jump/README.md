# coder-jump

A tiny always-on **tailnet jump host** for reaching [Coder](https://coder.com)
workspaces over [Tailscale](https://tailscale.com) from a device you can't
configure SSH on (e.g. an iPad).

It runs Tailscale SSH + the Coder CLI. You Tailscale-SSH into it (keyless —
authenticated by tailnet identity/ACLs), land in a shell, and run
`coder ssh <workspace>` to get a **fully Coder-brokered session** (git auth,
user secrets, dotfiles — everything Coder injects), which a direct Tailscale SSH
into the workspace container cannot provide.

```
iPad ──(Tailscale SSH, keyless)──▶ coder-jump ──(coder ssh)──▶ Coder-brokered workspace
```

## What's inside

- `tailscale` + `tailscaled` (userspace networking — no `/dev/net/tun`/`NET_ADMIN`).
- The `coder` CLI, pinned to match your Coder server (currently **2.37.3** — keep
  these in step).

## Configuration

The container is driven entirely by environment variables:

| Variable              | Required | Default      | Description                                                        |
| --------------------- | -------- | ------------ | ------------------------------------------------------------------ |
| `TS_AUTHKEY`          | yes      | —            | Tailscale auth key for the jump node (ideally tagged, e.g. `tag:jump`). |
| `CODER_URL`           | yes      | —            | Your Coder server URL (in-cluster service or external https).      |
| `CODER_SESSION_TOKEN` | yes      | —            | A long-lived Coder token (see below). Used by `coder ssh`.         |
| `TS_HOSTNAME`         | no       | `coder-jump` | Tailnet hostname for the jump node.                                |
| `JUMP_USER`           | no       | `coder`      | Local user Tailscale SSH logs you in as.                           |
| `TS_EXTRA_ARGS`       | no       | —            | Extra args passed to `tailscale up`.                               |

### Create the Coder token

```sh
coder tokens create --name coder-jump --lifetime 8760h   # 1 year
```

## Deploy on Kubernetes

```sh
# 1. Tailscale auth key for the jump node
kubectl create secret generic coder-jump-tailscale -n coder \
  --from-literal=authkey='tskey-auth-...'

# 2. Long-lived Coder token
kubectl create secret generic coder-jump-token -n coder \
  --from-literal=token="$(coder tokens create --name coder-jump --lifetime 8760h)"

# 3. Deploy (edit CODER_URL in deployment.yaml first if needed)
kubectl apply -f deploy/deployment.yaml
```

No Service/ports are required — Tailscale handles all ingress.

### Tailnet ACL

Allow your iPad (or your user) to SSH to the jump node as `coder`. In your
Tailscale ACL `ssh` block, use `"action": "accept"` (not `"check"`, which forces
a browser re-auth that won't work unattended), e.g.:

```jsonc
"ssh": [
  {
    "action": "accept",
    "src":    ["autogroup:member"],
    "dst":    ["tag:jump"],
    "users":  ["coder"]
  }
]
```

## Usage from the iPad

1. Make sure the iPad is on your tailnet (Tailscale app connected).
2. From any SSH client, connect to the jump node's MagicDNS name as `coder`:
   `ssh coder@coder-jump` — Tailscale authenticates the connection; no SSH key needed.
3. In the jump shell:
   ```sh
   coder list                 # see your workspaces
   coder ssh <workspace>      # drop into a fully brokered session
   ```
