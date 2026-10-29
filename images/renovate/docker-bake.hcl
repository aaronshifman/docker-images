target "docker-metadata-action" {}

variable "IMAGE" {
  default = "renovate"
}

variable "VERSION" {
  // renovate: datasource=docker depName=ghcr.io/renovatebot/renovate
  default = "44.190.0"
}

variable "HELM_VERSION" {
  // renovate: datasource=github-releases depName=helm/helm extractVersion=^v(?<version>.+)$
  default = "4.3.1"
}

variable "KUSTOMIZE_VERSION" {
  // renovate: datasource=github-releases depName=kubernetes-sigs/kustomize extractVersion=^kustomize/v(?<version>.+)$
  default = "5.8.3"
}

variable "NODE_VERSION" {
  // renovate: datasource=node-version depName=node
  default = "24.22.2"
}

variable "COREPACK_VERSION" {
  // renovate: datasource=npm depName=corepack
  default = "0.36.0"
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
    NODE_VERSION      = "${NODE_VERSION}"
    COREPACK_VERSION  = "${COREPACK_VERSION}"
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
