FROM dhi.io/golang:1-debian13-dev@sha256:39947402d8e52fcaeb8f8a3b00f4377414464fb89437c7ba67358cf4c5caaac9 AS build

ARG VERSION

RUN git clone --branch v${VERSION} --depth 1 https://github.com/hashicorp/terraform.git
WORKDIR /go/terraform

# bump grpc to address GO-2026-4762, 
# bump go-getter to address CVE-2026-4660
# otel needs to be bumped to address CVE-2026-39883 but not compatible
RUN --mount=type=cache,target=/go/pkg/mod \
  go get \
  google.golang.org/grpc@v1.79.3 && \
  go mod tidy

RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  CGO_ENABLED=0 \ 
  GOOS=${TARGETOS} \
  GOARCH=${TARGETARCH} \
  go build -trimpath -ldflags "-s -w" -v -o terraform .

FROM build AS scan

RUN --mount=type=cache,target=/go/pkg/mod \
  --mount=type=cache,target=/root/.cache/go-build \
  go install golang.org/x/vuln/cmd/govulncheck@v1.2.0 && govulncheck ./...

FROM scratch AS run

USER nobody:nogroup

WORKDIR /
COPY --from=scan /go/terraform/terraform /terraform
COPY --from=scan /go/terraform/LICENSE /LICENSE

ENTRYPOINT [ "/terraform" ]
