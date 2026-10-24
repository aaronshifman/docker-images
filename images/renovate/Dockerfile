FROM ghcr.io/renovatebot/renovate:44.181.4@sha256:e2440463a0fff07e43875643324f8b57f6c3a9a8365332b7183989514f81e9ee

ARG VERSION

ARG HELM_VERSION
ARG KUSTOMIZE_VERSION

USER root
RUN install-tool helm "${HELM_VERSION}" \
  && install-tool kustomize "${KUSTOMIZE_VERSION}"

COPY --from=docker.io/mikefarah/yq:4.54.1@sha256:4b3d9475d65571d28cbb19544d3820ec2945e4c8b2f18279394282b8dc3a592e /usr/bin/yq /usr/local/bin/yq

USER 12021
