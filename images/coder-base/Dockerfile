# syntax=docker/dockerfile:1
FROM debian:13-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a

ARG VERSION
ARG VENDOR
# renovate: ignore for now -- bumped manually
ARG TAILSCALE_VERSION=1.102.4
# renovate: ignore for now -- bumped manually
ARG MISE_VERSION=2026.10.2

ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=1000

LABEL org.opencontainers.image.version="${VERSION}" \
  org.opencontainers.image.vendor="${VENDOR}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=en_US.UTF-8 \
  LC_ALL=en_US.UTF-8

# Base system packages. git is installed here because it has no mise backend;
# curl is required for the Coder agent to bootstrap itself at runtime.
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  build-essential \
  ca-certificates \
  curl \
  git \
  gnupg \
  iproute2 \
  less \
  locales \
  openssh-client \
  procps \
  stow \
  sudo \
  unzip \
  xz-utils \
  && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
  && locale-gen \
  && rm -rf /var/lib/apt/lists/*

# Non-root workspace user with passwordless sudo (Coder + mise convention).
RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
  && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}" \
  && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
  && chmod 0440 "/etc/sudoers.d/${USERNAME}"

# tailscale
RUN arch="$(dpkg --print-architecture)" \
  && curl -fsSL "https://pkgs.tailscale.com/stable/tailscale_${TAILSCALE_VERSION}_${arch}.tgz" -o /tmp/tailscale.tgz \
  && tar -xzf /tmp/tailscale.tgz -C /tmp \
  && mv "/tmp/tailscale_${TAILSCALE_VERSION}_${arch}/tailscale" /usr/local/bin/tailscale \
  && mv "/tmp/tailscale_${TAILSCALE_VERSION}_${arch}/tailscaled" /usr/local/bin/tailscaled \
  && rm -rf /tmp/tailscale.tgz "/tmp/tailscale_${TAILSCALE_VERSION}_${arch}"

COPY tailscale-up.sh /usr/local/bin/tailscale-up
RUN chmod 0755 /usr/local/bin/tailscale-up

# mise manages the dev toolchain. Everything lives OUTSIDE /home/coder because
# Coder mounts a persistent volume over the home directory, which would shadow
# anything baked into it. Binary -> /usr/local/bin, config -> /etc/mise,
# installed tools + shims -> /opt/mise.
ENV MISE_DATA_DIR=/opt/mise \
    MISE_CONFIG_DIR=/etc/mise \
    MISE_TRUSTED_CONFIG_PATHS=/etc/mise \
    PATH=/opt/mise/shims:/usr/local/bin:$PATH

RUN curl -fsSL https://mise.run | MISE_VERSION="v${MISE_VERSION}" MISE_INSTALL_PATH=/usr/local/bin/mise sh \
  && chmod 0755 /usr/local/bin/mise

COPY mise.toml /etc/mise/config.toml
COPY mise.lock /etc/mise/mise.lock

# Install the toolchain (as root, into /opt/mise) pinned by mise.lock, then hand
# ownership to the coder user so they can `mise use` more tools at runtime
# without sudo, and wire up shell activation system-wide (login shells via
# profile.d, interactive shells via bash.bashrc).
# hadolint ignore=SC2016
RUN mise install --yes \
  && mise reshim \
  && echo 'eval "$(mise activate bash)"' > /etc/profile.d/mise.sh \
  && echo 'eval "$(mise activate bash)"' >> /etc/bash.bashrc \
  && chown -R coder:coder /opt/mise /etc/mise

USER coder
WORKDIR /home/coder

CMD ["bash"]
