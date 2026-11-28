FROM ghcr.io/renovatebot/renovate:45.3.2@sha256:d0358088501c7665688673c8932474b02517941703a16e970e8b4fcf235299cb

ARG VERSION

ARG HELM_VERSION
ARG KUSTOMIZE_VERSION
ARG NODE_VERSION
ARG COREPACK_VERSION

USER root
RUN install-tool helm "${HELM_VERSION}" \
  && install-tool kustomize "${KUSTOMIZE_VERSION}" \
  && install-tool node "${NODE_VERSION}" \
  && install-tool corepack "${COREPACK_VERSION}"

COPY --from=docker.io/mikefarah/yq:4.54.1@sha256:4b3d9475d65571d28cbb19544d3820ec2945e4c8b2f18279394282b8dc3a592e /usr/bin/yq /usr/local/bin/yq

USER 12021
