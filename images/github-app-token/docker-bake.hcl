target "docker-metadata-action" {}

variable "IMAGE" {
  default = "github-app-token"
}

variable "VERSION" {
  default = "0.1.0"
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
    "org.opencontainers.image.description": "Generate a github app token from a private key"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
