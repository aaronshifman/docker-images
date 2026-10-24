target "docker-metadata-action" {}

variable "IMAGE" {
  default = "renovate"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
  default = "44.181.4"
}

variable "HELM_VERSION" {
  // renovate: datasource=github-releases depName=helm/helm extractVersion=^v(?<version>.+)$
  default = "4.2.1"
}

variable "KUSTOMIZE_VERSION" {
  // renovate: datasource=github-releases depName=kubernetes-sigs/kustomize extractVersion=^kustomize/v(?<version>.+)$
  default = "5.8.1"
}

group "default" {
  targets = [ "image" ]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION           = "${VERSION}"
    HELM_VERSION      = "${HELM_VERSION}"
    KUSTOMIZE_VERSION = "${KUSTOMIZE_VERSION}"
  }
  tags = ["${IMAGE}:${VERSION}"]
  labels = {
    "org.opencontainers.image.description": "Renovate with tools"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
