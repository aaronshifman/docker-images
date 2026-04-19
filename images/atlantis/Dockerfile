FROM dhi.io/golang:1-debian13-dev@sha256:39947402d8e52fcaeb8f8a3b00f4377414464fb89437c7ba67358cf4c5caaac9 AS build

ARG VERSION

RUN git clone --branch v${VERSION} --depth 1 https://github.com/runatlantis/atlantis.git
WORKDIR /go/atlantis

RUN --mount=type=cache,target=/go/pkg/mod \
  go mod graph | awk '{if ($1 !~ "@") print $2}' | xargs go get

RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath -ldflags "-s -w -X 'main.version=${VERSION}' -X 'main.commit=$(git rev-parse HEAD)' -X 'main.date=$(git log -1 --format=%cI)'" -v -o atlantis .

FROM build AS scan

RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  go install golang.org/x/vuln/cmd/govulncheck@latest && govulncheck ./...

FROM ghcr.io/aaronshifman/terraform:1.14.8@sha256:f3cf56746afc11c1279a2c29d368e8be3a474ebb5e6a151ff9287352304ac499 AS terraform
FROM scratch AS run

WORKDIR /
COPY --from=scan /go/atlantis/atlantis /atlantis
COPY --from=scan /go/atlantis/LICENSE /LICENSE

COPY --from=terraform /terraform /terraform

ENTRYPOINT [ "/atlantis" ]
