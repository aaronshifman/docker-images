FROM ghcr.io/renovatebot/renovate:44.198.3@sha256:bf344aa39d5b592ec728e1db5c3e1d940a5093a89a4598073efcb18d592d121c

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

COPY --from=docker.io/mikefarah/yq:4.54.3@sha256:7834187596ad56fd5a81436114e0b0b9dd54c91bb43946d1f7145b2be5f9c3d2 /usr/bin/yq /usr/local/bin/yq

USER 12021
