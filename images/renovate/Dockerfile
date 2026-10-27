FROM ghcr.io/renovatebot/renovate:44.181.7@sha256:4f5a2621afd6629fda621e5c66221d1000f0ef3330ec14c828d7e8d357f03522

ARG VERSION

ARG HELM_VERSION
ARG KUSTOMIZE_VERSION

USER root
RUN install-tool helm "${HELM_VERSION}" \
  && install-tool kustomize "${KUSTOMIZE_VERSION}"

COPY --from=docker.io/mikefarah/yq:4.54.1@sha256:4b3d9475d65571d28cbb19544d3820ec2945e4c8b2f18279394282b8dc3a592e /usr/bin/yq /usr/local/bin/yq

USER 12021
