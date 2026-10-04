target "docker-metadata-action" {}

variable "IMAGE" {
  default = "coder-base"
}

variable "VERSION" {
  default = "0.1.0"
}

variable "TAILSCALE_VERSION" {
  default = "1.102.4"
}

variable "MISE_VERSION" {
  default = "2026.10.2"
}

group "default" {
  targets = ["image"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION           = "${VERSION}"
    TAILSCALE_VERSION = "${TAILSCALE_VERSION}"
    MISE_VERSION      = "${MISE_VERSION}"
  }
  tags = ["${IMAGE}:${VERSION}"]
  labels = {
    "org.opencontainers.image.description" : "Base devcontainer"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
