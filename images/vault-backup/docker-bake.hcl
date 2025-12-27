target "docker-metadata-action" {}

variable "IMAGE" {
  default = "vault-backup"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=hashicorp/vault
  default = "1.21.1"
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
    "org.opencontainers.image.description": "Backup vault and upload to a s3 bucket"
  }
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
