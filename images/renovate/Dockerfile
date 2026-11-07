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

COPY --from=docker.io/mikefarah/yq:4.54.2@sha256:5d56494617dce8311106e905aac5c080a2087c905a7f7de2984db2e2cc60ab2e /usr/bin/yq /usr/local/bin/yq

USER 12021
