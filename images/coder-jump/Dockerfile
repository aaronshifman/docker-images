# syntax=docker/dockerfile:1
FROM debian:13-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a

ARG VERSION
ARG VENDOR
# Coder CLI version -- keep in step with your Coder server version.
ARG CODER_VERSION=2.37.3
# renovate: ignore for now -- bumped manually
ARG TAILSCALE_VERSION=1.102.4

ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=1000

LABEL org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.vendor="${VENDOR}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# Minimal runtime deps. curl/ca-certificates to fetch binaries; sudo so the
# (non-root) container can launch tailscaled as root -- Tailscale SSH requires
# the daemon to run as root to open login sessions.
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  openssh-client \
  sudo \
  && rm -rf /var/lib/apt/lists/*

# Login user for Tailscale SSH sessions, with passwordless sudo so the
# entrypoint can start tailscaled as root.
RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
  && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}" \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
  && chmod 0440 "/etc/sudoers.d/${USERNAME}"

# Tailscale (static multi-arch tarball).
RUN arch="$(dpkg --print-architecture)" \
  && curl -fsSL "https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_${arch}.tgz" -o /tmp/tailscale.tgz \
  && tar -xzf /tmp/tailscale.tgz -C /tmp \
  && mv "/tmp/tailscale_${TAILSCALE_VERSION}_${arch}/tailscale" /usr/local/bin/tailscale \
  && mv "/tmp/tailscale_${TAILSCALE_VERSION}_${arch}/tailscaled" /usr/local/bin/tailscaled \
  && rm -rf /tmp/tailscale.tgz "/tmp/tailscale_${TAILSCALE_VERSION}_${arch}"

# Coder CLI (pinned, multi-arch).
RUN arch="$(dpkg --print-architecture)" \
  && curl -fsSL "https://github.com/coder/coder/releases/download/v${CODER_VERSION}/coder_${CODER_VERSION}_linux_${arch}.tar.gz" -o /tmp/coder.tgz \
  && tar -xzf /tmp/coder.tgz -C /usr/local/bin ./coder \
  && rm /tmp/coder.tgz \
  && chmod 0755 /usr/local/bin/coder

# Persist/read the Coder session from a writable tmpfs path (works under
# readOnlyRootFilesystem without chowning the home dir). Exported to login
# shells so Tailscale SSH sessions find the session the entrypoint created.
ENV CODER_CONFIG_DIR=/tmp/coderv2
RUN printf 'export CODER_CONFIG_DIR=/tmp/coderv2\n' > /etc/profile.d/coder.sh

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod 0755 /usr/local/bin/entrypoint

# Run as the non-root coder user; the entrypoint uses sudo to start tailscaled
# as root (required by Tailscale SSH). k8s may override via runAsUser.
USER coder

ENTRYPOINT ["/usr/local/bin/entrypoint"]
