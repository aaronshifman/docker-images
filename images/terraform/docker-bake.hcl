target "docker-metadata-action" {}

variable "IMAGE" {
  default = "terraform"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=hashicorp/terraform
  default = "1.15.1"
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
    "org.opencontainers.image.description": "Terraform image"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
