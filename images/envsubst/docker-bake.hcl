target "docker-metadata-action" {}

variable "IMAGE" {
  default = "envsubst"
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
    "org.opencontainers.image.description": "Basic image to run envsubst"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
