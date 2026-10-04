target "docker-metadata-action" {}

variable "IMAGE" {
  default = "coder-jump"
}

# Tracks the Coder CLI version baked into the image.
variable "VERSION" {
  default = "2.37.3"
}

variable "TAILSCALE_VERSION" {
  default = "1.102.4"
}

group "default" {
  targets = ["image"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION           = "${VERSION}"
    CODER_VERSION     = "${VERSION}"
    TAILSCALE_VERSION = "${TAILSCALE_VERSION}"
  }
  tags = ["${IMAGE}:${VERSION}"]
  labels = {
    "org.opencontainers.image.description" : "Tailnet jump host: Tailscale SSH + Coder CLI for reaching Coder-brokered workspace sessions"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
