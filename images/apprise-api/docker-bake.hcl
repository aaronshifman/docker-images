target "docker-metadata-action" {}

variable "IMAGE" {
  default = "apprise-api"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=caronc/apprise-api
  default = "v1.2.0"
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
    "org.opencontainers.image.description": "Apprise api server built to not have supervisord or nginx in the same container"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
