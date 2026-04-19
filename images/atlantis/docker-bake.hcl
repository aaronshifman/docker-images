target "docker-metadata-action" {}

variable "IMAGE" {
  default = "atlantis"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=runatlantis/atlantis
  default = "0.41.0"
}

group "default" {
  targets = [ "image" ]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  tags = ["${IMAGE}:${VERSION}"]
  labels = {
    "org.opencontainers.image.description": "Atlantis image"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
