# coder-base

Base image for [Coder](https://coder.com) workspaces, built on Debian 13.

Ships an interactive dev environment plus [Tailscale](https://tailscale.com) so
you can SSH into the workspace over your tailnet.

## What's inside

- **Shell user:** non-root `coder` (uid/gid 1000) with passwordless `sudo`.
- **Dev tools (via [mise](https://mise.jdx.dev)):** neovim, tmux, ripgrep, fd,
  fzf, lazygit.
- **Languages (via mise):** Go, Python, Node.js (LTS).
- **From apt:** git (no mise backend), curl, openssh-client, and supporting
  utilities.
- **Tailscale:** `tailscale` + `tailscaled` static binaries, run in
  userspace-networking mode (no `/dev/net/tun` or `NET_ADMIN` required).

Tool versions are pinned in [`mise.lock`](./mise.lock) for reproducible builds.

## Tailscale SSH

The image does **not** auto-start Tailscale (Coder replaces the container
entrypoint with its agent). Instead it ships `/usr/local/bin/tailscale-up`,
which you call from your Coder template's `startup_script`:

```sh
# in your Coder template's startup_script
export TS_AUTHKEY="tskey-auth-..."   # a Tailscale auth key
export TS_HOSTNAME="my-workspace"    # optional; defaults to $(hostname)
tailscale-up
```

`tailscale-up` starts `tailscaled` in userspace-networking mode and runs
`tailscale up --ssh`, enabling SSH to the workspace over the tailnet. Extra
arguments are passed straight through to `tailscale up`
(e.g. `tailscale-up --accept-routes`).

### Environment variables

| Variable       | Required | Default        | Description                          |
| -------------- | -------- | -------------- | ------------------------------------ |
| `TS_AUTHKEY`   | yes      | —              | Tailscale auth key.                  |
| `TS_HOSTNAME`  | no       | `$(hostname)`  | Tailnet hostname for the workspace.  |
| `TS_STATE_DIR` | no       | `/var/lib/tailscale` | Where tailscaled stores state. |

## Updating pinned versions

- Tailscale and mise versions live in `docker-bake.hcl` (and as defaults in the
  `Dockerfile`); bump them manually.
- Tool versions are refreshed by regenerating the lockfile:

  ```sh
  mise install   # from images/coder-base, updates mise.lock
  ```
